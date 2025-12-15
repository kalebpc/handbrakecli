# Handbrake.ps1

## What this code does

This code will recursively copy directories, re-encode or copy source files to destination then move source directory to temp/trash/backup folder.

## Usage

There are different options to use this script.

Option 1
1. Create shortcut to 'handbrake.ps1'.
2. Right-click shortcut.
3. Modifiy 'Target' under shortcut tab to include `powershell.exe` in front of the path.
4. Add parameters after path to powershell file.

- Target: `powershell.exe C:\Users\Username\Documents\handbrake.ps1 -Preset 'Presetname' -Encoding -Source 'G:\path\to\in-folder' -Destination 'G:\path\to\out-folder'`
5. Click OK to save and close.
6. Double-click to run.

Option 2
1. Modifiy run.ps1 to have your source, destination directories and preset if encoding.
```
$in = "G:\path\to\in-folder"
$out = "G:\path\to\out-folder"
$preset = "Roku 480p30"
```
2. Run run.ps1
```
./run.ps1
```

Option 3
```
./handbrake -Preset "Presetname" -Encoding -Source "G:\path\to\in-folder" -Destination "G:\path\to\out-folder"

handbrake.ps1 -Preset <string> -Encoding [-Help] [-Source <string>] [-Destination <string>] [-SourceExt <string>] [-DestinationExt <string>] [-Ready <string>] [-Pause <int>] [-Processed <string>] [-Log <string>] [-LogFile <string>] [-RobocopyThreads <int>] [-CheckDirectory <int>] [<CommonParameters>]

./handbrake -Copying -Source "G:\path\to\in-folder" -Destination "G:\path\to\out-folder"

handbrake.ps1 -Copying [-Help] [-Source <string>] [-Destination <string>] [-SourceExt <string>] [-DestinationExt <string>] [-Ready <string>] [-Pause <int>] [-Processed <string>] [-Log <string>] [-LogFile <string>] [-RobocopyThreads <int>] [-CheckDirectory <int>] [<CommonParameters>]
```
