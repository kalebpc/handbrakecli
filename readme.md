# Handbrake.ps1

## What this code does

This code will recursively copy directories, re-encode or copy source files to destination then move source directory to temp/trash/backup folder.

## Usage

There are different options to use this script.

Option 1
1. Create shortcut to 'handbrake.ps1'.
2. Right-click shortcut.
3. Modifiy 'Target' under shortcut tab to include `powershell.exe` in front of the path.
4. Add source and destination directories after path to powershell file.
5. Optional: Set '[Int]', the time to wait in between directory copy/encodes to allow for graceful exit between jobs. Default is 5 minutes.

- Target: `powershell.exe C:\Users\Username\Documents\handbrake.ps1 'G:\path\to\in-folder' 'G:\path\to\out-folder' [Int]`
6. Click OK to save and close.
7. Double-click to run.

Option 2
1. Modifiy run.ps1 to have your source, destination directories, and graceful exit pause time(minutes).
```
$in = "G:\path\to\in-folder"
$out = "G:\path\to\out-folder"
[Int]$pause = 5
```
2. Run run.ps1
```
./run.ps1
```

Option 3
```
./handbrake [path2SourceFolder] [path2DestinationFolder] [Optional:pauseTimeForGracefulExit]
```
