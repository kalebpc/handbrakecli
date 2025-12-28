# Main_Scripts

#### [handbrake.ps1](#handbrake)

#### [handbrakeTrailers.ps1](#handbraketrailers)

#### [Copy-Trailers.ps1](#copy-trailers)

# Required_Scripts

#### Add-LogAndPrint.ps1

#### Confirm-UserWebHook.ps1

#### Send-Message.ps1

# Extra_Scripts

#### Get-imdbID.ps1

#### Rename-Folders.ps1

#### run.ps1

#### Jellyfin-MakeStorage.ps1

#### Jellyfin-ValidateStorage.ps1

#### [Back to Top](#main_scripts)
# Handbrake

#### [Source Directory Setup](#source_directory_setup)

#### [Usage](#usage)

## What this code does

This code will recursively copy directories, encode source files to destination then move folder from 'Source' to 'Processed'.

## Help

`./handbrake -Help`

#### Use 'Get-Help' cmdlet to get detailed help.
```
Get-Help ./handbrake

Get-Help ./handbrake -full

Get-Help ./handbrake -detailed

Get-Help ./handbrake -examples
```
## Source_Directory_Setup
Example of what 'Source' Directory should resemble with 'Read.txt' file to mark it ready to process.
```
C:\EXAMPLE_SOURCE_FOLDER
+---Movie Title (Year) [imdbid-IMDBIDHERE]
|   |   Movie Title (Year) [imdbid-IMDBIDHERE].mkv
|   |   Ready.txt
|   |
|   +---extras
|   |        Movie Title (Year) [imdbid-IMDBIDHERE] - 1.mkv
|   |
|   \---trailers
|           Movie Title (Year) [imdbid-IMDBIDHERE] - 1.mkv
|           Movie Title (Year) [imdbid-IMDBIDHERE] - 2.mkv
|           Movie Title (Year) [imdbid-IMDBIDHERE] - 3.mkv
|
\---Spider-Man (2002) [imdbid-IMDBIDHERE]
    |   Ready.txt
    |   Spider-Man (2002) [imdbid-IMDBIDHERE].mkv
    |   Spider-Man (2002) [imdbid-IMDBIDHERE] - trailer.mkv
    |
    \---extras
            Spider-Man (2002) [imdbid-IMDBIDHERE] - extra.mkv
```
[More info on movie directory setup](https://jellyfin.org/docs/general/server/media/movies/) for [Jellyfin](https://jellyfin.org/).

## Usage
```
./handbrake -Preset1 <string> [-Preset2 <string>] -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options]

./handbrake [-Help] [<CommonParameters>]
```
Option 1
1. Create shortcut to 'run.ps1'.
2. Right-click shortcut.
3. Modifiy 'Target' under shortcut tab to include `powershell.exe` in front of the path.
5. Click OK to save and close.
4. Update parameters in 'run.ps1' powershell file.
6. Double-click shortcut to run 'handbrake.ps1'.
7. Once running, make new text file named 'Ready.txt' in a folder inside 'Source' directory and the script will find and begin processing the files it finds with the 'sourceExt' extension.

Option 2

Run from powershell terminal.
```
./handbrake -Preset1 <string> [-Preset2 <string>] -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options]
```
#### [Back to Top](#main_scripts)
# HandbrakeTrailers

Encode movie trailers.

Todo ...

#### [Back to Top](#main_scripts)
# Copy-Trailers

Copy movie trailers from 'movie trailers' folders to respective movie folder if it exists.

Todo ...

#### [Back to Top](#main_scripts)
