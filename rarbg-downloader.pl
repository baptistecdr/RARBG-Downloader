#!/usr/bin/env perl
use strict;
use warnings;

use Error qw(:try :warndie);
use Sys::Syslog qw(:standard :macros);
use Getopt::Long;
use Rarbg::torrentapi;
use Cwd;

my $DEFAULT_DOWNLOAD_PATH = cwd();
my $DEFAULT_CATEGORY_ID = "41"; # TVHD Episodes
my $DEFAULT_LIMIT_RESULT = 25;
my $DEFAULT_RANKED = 0; # Find all
my $DEFAULT_DOWNLOAD_ALL_RESULTS = 0;
my $DEBUG = 0;

try {
    my $search_value = undef;
    my $download_path = $DEFAULT_DOWNLOAD_PATH;
    my $category_id = $DEFAULT_CATEGORY_ID;
    my $limit_result = $DEFAULT_LIMIT_RESULT;
    my $ranked = $DEFAULT_RANKED;
    my $download_all_results = $DEFAULT_DOWNLOAD_ALL_RESULTS;
    my $debug = $DEBUG;

    GetOptions(
        "search|s=s" => \$search_value,
        "download-path|dp=s" => \$download_path,
        "category|c=s" => \$category_id,
        "ranked|r" => \$ranked,
        "yes|y" => \$download_all_results,
        "limit|l=i" => $limit_result,
        "debug" => \$debug,
        "help" => \&help
    );

    openlog("rarbg-downloader", "perror", LOG_LOCAL0);
    setlogmask(~LOG_MASK(LOG_DEBUG)) unless $debug == 1;
    syslog(LOG_INFO, "Started");

    throw Error::Simple("You need to specify a search value !") unless defined $search_value;
    throw Error::Simple("Your search value is not valid !") unless $search_value =~ /^[\w\s\[\].-]+$/;
    if($limit_result != 25 || $limit_result != 50 || $limit_result != 100){
        $limit_result = $DEFAULT_LIMIT_RESULT;
        syslog(LOG_WARNING, "You can only limit by 25, 50 or 100. Default value will be use : $DEFAULT_LIMIT_RESULT");
    }

    throw Error::Simple("Download folder invalid") unless (defined $download_path && -d $download_path && $download_path =~ m#^[\w\s/\\.-]+$#);
    my $tapi = Rarbg::torrentapi->new();
    syslog(LOG_DEBUG, "Searching '$search_value' on RARBG");
    my $search = search_torrent($tapi, $search_value, $category_id, $limit_result, $ranked);

    if(!defined($search) || ref($search) eq "Rarbg::torrentapi::Error"){
        syslog(LOG_WARNING, "No result found for '$search_value'");
    } else {
        my @results = @{$search};
        syslog(LOG_DEBUG, scalar(@results) . " results found for '$search_value'");
        foreach my $result (@results){
            if($download_all_results == 0) {
                print "Do you want to download " . $result->title . " ? [Y/n] ";
                my $response = <STDIN>;
                chomp $response;
                if($response =~ /^(y|yes)$/i) {
                    download_torrent($download_path, $result);
                }
            } else {
                download_torrent($download_path, $result);
            }
        }
    }
    syslog(LOG_INFO, "Finished");
} catch Error with {
    my $ex = shift;
    syslog(LOG_ERR, "%s", $ex);
};

sub help {
    print "RARBG-Downloader - Search and download torrent on RARBBG\n";
    print "-dp  --download-path Where to export the magnet file\n";
    print "                         Default value : Current Directory\n";
    print "-s   --search        Search a torrent by his name\n";
    print "-c   --category      Which category do you want to search a torrent\n";
    print "                         Possible value : See on RARBG\n";
    print "                         Default value : 41 (TV HD Episodes)\n";
    print "-l   --limit         Max records you want to get\n";
    print "                         Possible value : 25, 50, 100\n";
    print "                         Default value : 25\n";
    print "-r   --ranked        Search only for ranked torrents (scene release, rarbg release, rartv release)\n";
    print "                         Default value : False\n";
    print "-y   --yes           Download all results without asking to download\n";
    print "-d   --debug         Show more log\n";
    exit 0;
}


sub search_torrent {
    my $tapi = shift;
    my $search = shift;
    my $category_id = shift;
    my $limit = shift;
    my $ranked = shift;

    return $tapi->search({
            search_string => $search,
            category      => $category_id,
            sort          => "last",
            limit         => $limit,
            ranked  => $ranked
        });
}

sub download_torrent {
    my $download_path = shift;
    my $torrent = shift;

    my $torrentname = $torrent->title;
    my $filename = "$torrentname.magnet";
    throw Error::Simple("Unable to write the file '$filename'") unless open(my $magnet_file, ">",
        "$download_path/$filename");
    syslog(LOG_INFO, "Extracting magnet link for '$torrentname'");
    print($magnet_file $torrent->download);
    close($magnet_file);
}
