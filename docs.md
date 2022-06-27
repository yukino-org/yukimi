# yukimi

```
Anime/Manga command-line interface backed up by Tenka.

Usage: yukimi <command> [arguments]

Global options:
-h, --help          Print this usage information.
    --json          
    --[no-]color    (defaults to on)
    --[no-]debug    

Available commands:
  agree-to-usage-policy   Agree the app's usage policy.
  anime                   Anime related commands.
  manga                   Manga related commands.
  settings                Display the app settings.
  tenka                   Tenka modules utility command.
  terminal                Opens the app in a sub-terminal.
  version                 Display the app information.

Run "yukimi help <command>" for more information about a command.
```

## yukimi help

```
Display help information for yukimi.

Usage: yukimi help [command]
-h, --help    Print this usage information.

Run "yukimi help" to see global options.
```

## yukimi agree-to-usage-policy

```
Agree the app's usage policy.

Usage: yukimi agree-to-usage-policy [arguments]
-h, --help    Print this usage information.
-y, --yes     

Run "yukimi help" to see global options.
```

## yukimi anime

```
Anime related commands.

Usage: yukimi anime <subcommand> [arguments]
-h, --help    Print this usage information.

Available subcommands:
  episode   Display information of an episode.
  info      Get information of an anime.
  search    Search for an anime.

Run "yukimi help" to see global options.
```

### yukimi anime info

```
Get information of an anime.

Usage: yukimi anime info [arguments]
-h, --help                          Print this usage information.
-l, --locale                        
-m, --module                        
    --no-cache                      
-d, --download                      
-p, --play                          
-e, --episodes                      
-o, --destination                   
-s, --sub-destination               
-n, --filename                      
-q, --quality                       [best, worst, 144p, 360p, 480p, 720p, 1080p, unknown]
    --fallbackQuality               [best, worst, 144p, 360p, 480p, 720p, 1080p, unknown]
    --[no-]search                   
-i, --[no-]ignore-existing-files    
    --filter-sources-by             

Run "yukimi help" to see global options.
```

### yukimi anime search

```
Search for an anime.

Usage: yukimi anime search [arguments]
-h, --help      Print this usage information.
-l, --locale    
-m, --module    

Run "yukimi help" to see global options.
```

### yukimi anime episode

```
Display information of an episode.

Usage: yukimi anime episode [arguments]
-h, --help      Print this usage information.
-l, --locale    
-m, --module    

Run "yukimi help" to see global options.
```

## yukimi manga

```
Manga related commands.

Usage: yukimi manga <subcommand> [arguments]
-h, --help    Print this usage information.

Available subcommands:
  chapter   Display information of a chapter.
  info      Get information of an manga.
  page      Display information of a chapter page.
  search    Search for an manga.

Run "yukimi help" to see global options.
```

### yukimi manga info

```
Get information of an manga.

Usage: yukimi manga info [arguments]
-h, --help                          Print this usage information.
-l, --locale                        
-m, --module                        
    --no-cache                      
-d, --download                      
-r, --read                          
-c, --chapters                      
-o, --destination                   
-s, --sub-destination               
-n, --filename                      
-f, --download-format               [pdf (default), image]
    --[no-]search                   
-i, --[no-]ignore-existing-files    

Run "yukimi help" to see global options.
```

### yukimi manga search

```
Search for an manga.

Usage: yukimi manga search [arguments]
-h, --help      Print this usage information.
-l, --locale    
-m, --module    

Run "yukimi help" to see global options.
```

### yukimi manga chapter

```
Display information of a chapter.

Usage: yukimi manga chapter [arguments]
-h, --help      Print this usage information.
-l, --locale    
-m, --module    

Run "yukimi help" to see global options.
```

### yukimi manga page

```
Display information of a chapter page.

Usage: yukimi manga page [arguments]
-h, --help      Print this usage information.
-l, --locale    
-m, --module    

Run "yukimi help" to see global options.
```

## yukimi tenka

```
Tenka modules utility command.

Usage: yukimi tenka <subcommand> [arguments]
-h, --help    Print this usage information.

Available subcommands:
  install     Install one or more Tenka module.
  installed   Display all the installed Tenka modules.
  store       Display all the available extensions on the store.
  uninstall   Uninstall one or more Tenka modules.

Run "yukimi help" to see global options.
```

### yukimi tenka store

```
Display all the available extensions on the store.

Usage: yukimi tenka store [arguments]
-h, --help    Print this usage information.

Run "yukimi help" to see global options.
```

### yukimi tenka install

```
Install one or more Tenka module.

Usage: yukimi tenka install [arguments]
-h, --help    Print this usage information.

Run "yukimi help" to see global options.
```

### yukimi tenka installed

```
Display all the installed Tenka modules.

Usage: yukimi tenka installed [arguments]
-h, --help    Print this usage information.

Run "yukimi help" to see global options.
```

### yukimi tenka uninstall

```
Uninstall one or more Tenka modules.

Usage: yukimi tenka uninstall [arguments]
-h, --help    Print this usage information.

Run "yukimi help" to see global options.
```

## yukimi settings

```
Display the app settings.

Usage: yukimi settings [arguments]
-h, --help                           Print this usage information.
-r, --reset                          [usagePolicy, ignoreSSLCertificate, animePreferredQuality, animeFallbackQuality, animeDownloadDestination, animeDownloadSubDestination, animeDownloadFilename, mangaDownloadDestination, mangaDownloadSubDestination, mangaDownloadFilename, mpvPath]
    --reset-all                      
    --[no-]ignoreSSLCertificate      
    --mpvPath                        
    --animeDownloadDestination       
    --animeDownloadSubDestination    
    --animeDownloadFilename          
    --mangaDownloadDestination       
    --mangaDownloadSubDestination    
    --mangaDownloadFilename          
    --animePreferredQuality          [best, worst, 144p, 360p, 480p, 720p, 1080p, unknown]
    --animeFallbackQuality           [best, worst, 144p, 360p, 480p, 720p, 1080p, unknown]

Run "yukimi help" to see global options.
```

## yukimi terminal

```
Opens the app in a sub-terminal.

Usage: yukimi terminal [arguments]
-h, --help    Print this usage information.

Run "yukimi help" to see global options.
```

## yukimi version

```
Display the app information.

Usage: yukimi version [arguments]
-h, --help    Print this usage information.

Run "yukimi help" to see global options.
```
