## Jump to...

[Folderhelper](#folderhelper)

# Handbrake

## What this code does

This code will recursively copy directories, re-encode or copy source files to destination then move folder from 'Source' to 'Processed'.

## Help

`./handbrake -Help`

#### Use 'Get-Help' cmdlet to get detailed help.
```
Get-Help ./handbrake

Get-Help ./handbrake -full

Get-Help ./handbrake -detailed

Get-Help ./handbrake -examples
```
## Source Directory Setup
Example of what 'Source' Directory shold resemble with 'Read.txt' file to mark it ready to process.
```
C:\EXAMPLE_SOURCE_FOLDER
+---Movie Title (Year)
|   |   Movie Title (Year).mkv
|   |   Ready.txt
|   |
|   +---extras
|   |       1.mkv
|   |
|   \---trailers
|           1.mkv
|           2.mkv
|           3.mkv
|
\---Spider-Man (2002)
    |   Ready.txt
    |   Spider-Man (2002).mkv
    |   trailer.mkv
    |
    \---extras
            extra.mkv
```
[More info on movie directory setup](https://jellyfin.org/docs/general/server/media/movies/) for [Jellyfin](https://jellyfin.org/).

## Usage
```
./handbrake -Encoding -Preset <string[]> -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options]

./handbrake -Copying -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options]

./handbrake -Help [<CommonParameters>]
```
Option 1 Encoding
1. Create shortcut to 'run.ps1'.
2. Right-click shortcut.
3. Modifiy 'Target' under shortcut tab to include `powershell.exe` in front of the path.
5. Click OK to save and close.
4. Update parameters in 'run.ps1' powershell file.
6. Double-click shortcut to run 'handbrake.ps1'.
7. Once running, make new text file named 'Ready.txt' in a folder inside 'Source' directory and the script will find and begin processing the files it finds with the 'sourceExt' extension.

Option 2 Encoding

Run from powershell terminal.
```
./handbrake -Encoding -Preset <string[]> -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options]
```

Option 1 Copying
1. Modify parameters in 'run.ps1' powershell file.
2. Create shortcut to 'run.ps1'.
3. Right-click shortcut.
4. Modifiy 'Target' under shortcut tab to include `powershell.exe` in front of the path.
5. Double-click shortcut to run 'handbrake.ps1'.

Option 2 Copying

Run from powershell terminal.
```
./handbrake -Copying -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options]
```

## Jump to...

[Handbrake](#handbrake)

# FolderHelper

## What this code does

Move and rename files into new folders based on file names. Rename files in subdirectories to same as subdirectory.

## Help

`./folderHelper -Help`

#### Use 'Get-Help' cmdlet to get detailed help.
```
Get-Help ./folderHelper

Get-Help ./folderHelper -full

Get-Help ./folderHelper -detailed

Get-Help ./folderHelper -examples
```
## Usage
```
./folderHelper -Path <string> [options]
./folderHelper -Help
```

## Examples

`./folderHelper -Path 'C:\EXAMPLE_SOURCE'`
```
# Source before.

C:\EXAMPLE_SOURCE
    Another Movie Name (2000) - trailer.mkv
    Another Movie Name (2000).mkv
    Another Movie Name (2000)anything here.mkv
    Movie Name (2000) - Copy.mkv
    Movie Name (2000) - trailer.mkv
    Movie Name (2000).mkv

# Source after.

C:\EXAMPLE_SOURCE
+---Another Movie Name (2000)
|       Another Movie Name (2000)(2).mkv
|       Another Movie Name (2000)(3).mkv
|       Another Movie Name (2000).mkv
|
\---Movie Name (2000)
        Movie Name (2000)(2).mkv
        Movie Name (2000)(3).mkv
        Movie Name (2000).mkv
```
`./folderHelper -Path 'C:\EXAMPLE_SOURCE' -Rename`

Jellyfin will refuse to see the video files as movies with the trailer tags on them.
```
# Source before.

C:\MOVIE_TRAILERS
+---Another Movie Name (2000)
|       Another Movie Name (2000)-trailer.mkv
|
\---Movie Name (2000)
        trailer.mkv
```
Now Jellyfin will load the trailers.
```
# Source after.

C:\MOVIE_TRAILERS
+---Another Movie Name (2000)
|       Another Movie Name (2000).mkv
|
\---Movie Name (2000)
        Movie Name (2000).mkv
```
