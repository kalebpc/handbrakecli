# Handbrake.ps1

## What this code does

This code will recursively copy directories, re-encode or copy source files to destination then move source directory to temp/trash/backup folder.

## Usage

There are different options to use this script.

Option 1
1. Modifiy run.ps1 to have your source and destination directories
```
$in = "G:\path\to\in-folder"
$out = "G:\path\to\out-folder"
```
2. Create shortcut to 'run.ps1'.
3. Right-click shortcut.
4. Modifiy 'Target' under shortcut tab to include `powershell.exe` in front of the path.

- Target: `powershell.exe C:\Users\Username\Documents\run.ps1`
5. Click OK to save and close.
6. Double-click to run which will start handbrake.ps1.

Option 2
1. Modifiy run.ps1 to have your source and destination directories
```
$in = "G:\path\to\in-folder"
$out = "G:\path\to\out-folder"
```
2. Run run.ps1
```
./run.ps1
```

Option 3
```
./handbrake [path2SourceFolder] [path2DestinationFolder]
```

