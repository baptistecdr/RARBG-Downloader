# RARBG-Downloader
Search and download torrent on RARBBG because CLI is faster than GUI.

## Prequisites

### Perl Module :
* Error (cpan install Error)
* Rarbg::torrentapi (cpan install Rarbg::torrentapi)

## Installation

```sh
mv rarbg-downloader.pl /usr/local/bin/
chown root:staff /usr/local/bin/rarbg-downloader.pl
chmod 755 /usr/local/bin/rarbg-downloader.pl
```

## Execution

RARBG-Downloader can simply be run by this command:

```sh
rarbg-downloader.pl --search "Rick And Morty S03E01"
```
By default RARBG-Downloader will extract the magnet file in the current directory. Of course you can choose what result you want to download. RARBG-Downloader will search, by default, in the TV HD Episodes.

### Available parameters
This is all the parameters avalaible in RARBG-Downloader.

| Parameters        | Shortcuts | Descriptions  | Mandatory | Default Value |
|-------------------|-----------|---------------|-----------|---------------|
| --search          | -s        | Search a torrent by his name     | Yes | |
| --download-path   | -dp       | Where to export the magnet file  | No | Current directory |
| --category        | -c        | The category to search the torrents  | No | 41 |
| --limit           | -l        | Max records you want to get  | No | 25 |
| --ranked          | -r        | Search only for ranked torrents (scene release, rarbg release, rartv release)  | No | false |
| --yes             | -y        | Download all results without asking to download   | No | false |
| --debug           | -d        | Active the debug mode (more log)   | No | false |
