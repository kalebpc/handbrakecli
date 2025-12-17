# Handbrake.ps1

## What this code does

This code will recursively copy directories, re-encode or copy source files to destination then move folder from 'Source' to 'Processed'.

## Usage

Help

`./handbrake -Help`

#### Use 'Get-Help' cmdlet to get detailed help.
```
Get-Help ./handbrake

Get-Help ./handbrake -full

Get-Help ./handbrake -detailed

Get-Help ./handbrake -examples

help ./handbrake

help ./handbrake -full

help ./handbrake -detailed

help ./handbrake -examples
```
### There are different options to use this script.

Option 1 Encoding
1. Create shortcut to 'run.ps1'.
2. Right-click shortcut.
3. Modifiy 'Target' under shortcut tab to include `powershell.exe` in front of the path.
5. Click OK to save and close.
4. Add parameters to 'run.ps1' powershell file.
```
$preset1 = "Roku 480p30 Modded"
$preset2 = "Roku 480p30"
$source = "G:\Videos\MKV Videos"
$destination = "G:\Videos\Movies"
$sourceExt = "mkv"
$destinationExt = "mp4"
$ready = "Ready.txt"
$processed = "G:\Processed"
```
6. Double-click shortcut to run 'handbrake.ps1'.
7. Once running, make new text file named 'Ready.txt' in a folder inside 'Source' directory and the script will find and begin processing the files it finds with the 'sourceExt' extension.

Option 2 Encoding

Run from powershell terminal.
```
./handbrake -Encoding -Preset <string[]> -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options]
```

Option 1 Copying
1. Modify parameters in 'run.ps1' powershell file.
```
$source = "G:\Videos\MKV Videos"
$destination = "G:\Videos\Movies"
$sourceExt = "mkv"
$destinationExt = "mp4"
$ready = "Ready.txt"
$processed = "G:\Processed"
```
2. Modify Start-Process command in 'run.ps1' to remove 'presets' and replace 'Encoding' with 'Copying'.
```
.../handbrake.ps1 -Copying -Source '$source'...

```
3. Create shortcut to 'run.ps1'.
4. Right-click shortcut.
5. Modifiy 'Target' under shortcut tab to include `powershell.exe` in front of the path.
6. Double-click shortcut to run 'handbrake.ps1'.

Option 2 Copying

Run from powershell terminal.
```
./handbrake -Copying -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options]
```
