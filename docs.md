# yukimi

```
Anime/Manga command-line interface backed up by Tenka.

Usage: yukimi <command> [arguments]

Global options:
-h, --help          Print this usage information.
    --json          
    --[no-]color    (defaults to on)

Available commands:
  anime      Anime related commands.
  manga      Manga related commands.
  settings   Display the app settings.
  tenka      Tenka modules utility command.
  terminal   Opens the app in a sub-terminal.
  version    Display the app information.

Run "yukimi help <command>" for more information about a command.
```

## yukimi help

```
Display help information for yukimi.

Usage: yukimi help [command]
-h, --help    Print this usage information.

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
-h, --help               Print this usage information.
-l, --locale             
-m, --module             
    --no-cache           
-d, --[no-]download      
-p, --play               
-e, --episodes           
-o, --destination        
-q, --quality            
    --fallbackQuality    

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
-h, --help             Print this usage information.
-l, --locale           
-m, --module           
    --no-cache         
-d, --[no-]download    
-v, --view             
-c, --chapters         
-o, --destination      

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
-h, --help                         Print this usage information.
    --[no-]default                 
    --[no-]ignoreSSLCertificate    
    --[no-]setMpvPath              
    --animeDestination             
    --mangaDestination             
    --customMpvPath                

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
