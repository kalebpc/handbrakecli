
<#PSScriptInfo

.VERSION 1.0

.GUID c8bf4fc2-1023-4e6d-bc0c-76acb642733b

.AUTHOR https://github.com/kalebpc

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES FFmpeg, HandBrakeCLI

.RELEASENOTES handbrake.ps1 © 2025 https://github.com/kalebpc/handbrakecli

#>

<#

.SYNOPSIS
    Copy or encode files using FFmpeg and HandBrakeCLI.

.DESCRIPTION
    Requires 'FFmpeg' or 'Jellyfin FFmpeg' and 'HandBrake CLI'
    handbrake.ps1 script will recursively copy directories, re-encode or copy source files to destination then move folder from 'Source' to 'Processed'.

.PARAMETER Help
    Show help/usage.

.PARAMETER Encoding
    Flag if encoding files from source to destination.

.PARAMETER Copying
    Flag if copying files from source to destination.

.PARAMETER Preset1
    Enter the name of the handbrakegui preset to use for 'movie/trailers/etc'. Examples: 'Roku 1080p30'.

.PARAMETER Preset2
    Enter the name of the handbrakegui preset to use for 'extras'. Examples: 'Roku 480p30'.

.PARAMETER Source
    Enter the path to directory of input folders.

.PARAMETER Destination
    Enter the path to directory of output folders.

.PARAMETER SourceExt
    Enter the extension of input files.
    Example: 'mkv'

.PARAMETER DestinationExt
    Enter the extension of output files.
    Example: 'mp4'

.PARAMETER Ready
    Enter the file found in a source folder to designate when it is ready to be processed.
    Example: 'Ready.txt'

.PARAMETER Processed
    Enter the fully qulified path of the folder to move source folders to after processing.
    Example: 'G:/Videos/Post-Processed'

.PARAMETER Pause
    Number of minutes to wait between folders that are ready to be processed.

.PARAMETER RobocopyThreads
    Number of cpu threads for Robocopy to use when copying directory tree. MIN:1 MAX:128

.PARAMETER CheckDirectory
    Number of minutes to wait between scanning Source directory folders for 'Ready file'.

.PARAMETER CheckDirectorySilent
    Suppress the 'Sleeping for 'CheckDirectory' mins.' output in terminal.

.PARAMETER Movflags
    Set FFmpeg 'movflags' switch.

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    ./handbrake -Encoding -Preset 'Roku 1080p30','Roku 480p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed'

.EXAMPLE
    ./handbrake -Encoding -Preset 'Roku 1080p30','Roku 480p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -CheckDirectorySilent

.EXAMPLE
    ./handbrake -Encoding -Preset 'Roku 1080p30','Roku 480p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -CheckDirectorySilent -RobocopyThreads 32

.EXAMPLE
    ./handbrake -Copying -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -Movflags '+faststart'

.EXAMPLE
    ./handbrake -Copying -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -CheckDirectorySilent

.EXAMPLE
    ./handbrake -Copying -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -CheckDirectorySilent -RobocopyThreads 128

#>


[CmdletBinding(DefaultParameterSetName = "Encoding")]
param(
    [Parameter(ParameterSetName = "Help")]
    [Switch]$Help,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding")]
    [Switch]$Encoding = $true,
    [Parameter(Mandatory = $true, ParameterSetName = "Copying")]
    [Switch]$Copying,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the name of the handbrakegui preset to use for 'movie/trailers/etc'. Examples: 'Roku 1080p30'.")]
    [String]$Preset1,
    [Parameter(ParameterSetName = "Encoding", HelpMessage="Enter the name of the handbrakegui preset to use for 'extras'. Examples: 'Roku 480p30'.")]
    [String]$Preset2,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the path to directory of input folders.")]
    [Parameter(Mandatory = $true, ParameterSetName = "Copying", HelpMessage="Enter the path to directory of input folders.")]
    [String]$Source,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the path to directory of output folders.")]
    [Parameter(Mandatory = $true, ParameterSetName = "Copying", HelpMessage="Enter the path to directory of output folders.")]
    [String]$Destination,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the extension of input files.")]
    [Parameter(Mandatory = $true, ParameterSetName = "Copying", HelpMessage="Enter the extension of input files.")]
    [String]$SourceExt,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the extension of output files.")]
    [Parameter(Mandatory = $true, ParameterSetName = "Copying", HelpMessage="Enter the extension of output files.")]
    [String]$DestinationExt,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the file found in a source folder to designate when it is ready to be processed.")]
    [Parameter(Mandatory = $true, ParameterSetName = "Copying", HelpMessage="Enter the file found in a source folder to designate when it is ready to be processed.")]
    [String]$Ready,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the fully qulified path of the folder to move source folders to after processing.")]
    [Parameter(Mandatory = $true, ParameterSetName = "Copying", HelpMessage="Enter the fully qulified path of the folder to move source folders to after processing.")]
    [String]$Processed,
    [Parameter(ParameterSetName = "Encoding", HelpMessage="Enter the number of minutes to wait between folders that are ready to be processed.")]
    [Parameter(ParameterSetName = "Copying", HelpMessage="Enter the number of minutes to wait between folders that are ready to be processed.")]
    [Int32]$Pause = 1,
    [Parameter(ParameterSetName = "Encoding", HelpMessage="Enter the number of cpu threads for Robocopy to use when copying directory tree.")]
    [Parameter(ParameterSetName = "Copying", HelpMessage="Enter the number of cpu threads for Robocopy to use when copying directory tree.")]
    [Int32]$RobocopyThreads = 4,
    [Parameter(ParameterSetName = "Encoding", HelpMessage="Enter the number of minutes to wait between scanning Source directory folders for 'Ready file'.")]
    [Parameter(ParameterSetName = "Copying", HelpMessage="Enter the number of minutes to wait between scanning Source directory folders for 'Ready file'.")]
    [Int32]$CheckDirectory = 1,
    [Parameter(ParameterSetName = "Encoding", HelpMessage="Suppress the 'Sleeping for 'CheckDirectory' mins.' output in terminal.")]
    [Parameter(ParameterSetName = "Copying", HelpMessage="Suppress the 'Sleeping for 'CheckDirectory' mins.' output in terminal.")]
    [Switch]$CheckDirectorySilent,
    [Parameter(ParameterSetName = "Copying", HelpMessage="Set FFmpeg -movflags switch.")]
    [String]$Movflags
)
function Help {
   "Usage: `
    ./handbrake -Encoding -Preset <string[]> -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options] `
    ./handbrake -Copying -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options] `
    ./handbrake -Help`n `

Options: `
    -Pause                - Number of minutes to wait between folders ready to be processed. `
    -RobocopyThreads      - Number of cpu threads for Robocopy to use when copying directory tree. `
    -CheckDirectory       - Number of minutes to wait between scanning Source directory folders for 'Ready' file. `
    -CheckDirectorySilent - Flag to suppress the 'Sleeping for $CheckDirectory mins.' output in terminal. `
    -Movflags             - Set FFmpeg -movflags switch.`n `
Example: `
    ./handbrake -Encoding -Preset 'Roku 1080p30','Roku 480p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed'`n"
    Return
}
function Exiting {
    [CmdletBinding()]
    param(
        [String]$Reason,
        [Int32]$Exitcode
    )
    Switch ($Exitcode) {
        0 { "`nFinished Successfully.`n`nExit 0" ; Exit }
        1 { "`n{0}`n" -f $Reason ; Help ; "`nExit {0}" -f $Exitcode ; Exit }
        2 { "`n{0}`n" -f $Reason ; "`nExit {0}" -f $Exitcode ; Exit }
        Default { Exit }
    }
}
If ($help) { Help ; Exiting -Reason "Show Help." -ExitCode 3 }
# Remove trailing whitespace
$Source = $Source.TrimEnd()
$Destination = $Destination.TrimEnd()
$Processed = $Processed.TrimEnd()
$SourceExt = $SourceExt.TrimEnd()
$DestinationExt = $DestinationExt.TrimEnd()
$Ready = $Ready.TrimEnd()
$Preset1 = $Preset1.TrimEnd()
$Preset2 = $Preset2.TrimEnd()
$Movflags = $Movflags.TrimEnd()
If ($Copying) { "Moveflags: '{0}'`n" -f $Movflags } Else { "Preset1: '{0}'`nPreset2: '{1}'`n" -f $Preset1,$Preset2 }

# TODO ...
# Need to find a way to figure out if destination is in the same path of source.
# There is a issue where if the destination folder is in same directory of the source causes a recursion fault.

# Set install path.
[String]$installPath = "$ENV:LOCALAPPDATA\Scripts\HandBrake"
[String]$log = "$installPath\logs\handbrake.log"
# Verify paths.
If ( ! $(Test-Path -Path $installPath) ) { New-Item -ItemType "Directory" -Path $installPath -Force }
If ( $Source -ne "" ) { If ( ! $(Test-Path -Path $Source) ) { Exiting -Reason "System cannot find '$Source'." -Exitcode 1 } Else { "Verified 'Source' path." } } Else { Exiting -Reason "System cannot find '$Source'." -Exitcode 1 }
If ( $Destination -ne "" ) { If ( ! $(Test-Path -Path $Destination) ) { New-Item -ItemType "Directory" -Path $Processed -Force } Else { "Verified 'Destination' path." } } ELSE { Exiting -Reason "System cannot find '$Destination'." -Exitcode 1 }
# Complete paths.
function Complete-Path { param([String]$P) return "$PWD$($P.Substring(1))" }
If ( $(Split-Path -Path $Source -Parent) -ieq "." ) { "Relative source path detected...Resolving to absolute path..." ; $Source = Complete-Path -P $Source ; "Done." }
If ( $(Split-Path -Path $Destination -Parent) -ieq "." ) { "Relative destination path detected...Resolving to absolute path..." ; $Destination = Complete-Path -P $Destination ; "Done." }
# Create logs path.
If ( ! $(Test-Path -Path $(Split-Path -Path $log -Parent)) ) { New-Item -ItemType "Directory" -Path $(Split-Path -Path $log -Parent) -Force } Else { "Verified 'logs' path." }
# Create processed path.
If ( $Processed -ne "" ) { If ( ! $(Test-Path -Path $Processed) ) { New-Item -ItemType "Directory" -Path $Processed -Force } Else { "Verified 'Processed' path.`n" } } Else { Exiting -Reason "System cannot find '$Processed'." -Exitcode 1 }
# Verify ffmpeg installed for copying.
If ($Copying) {
    If ( $(Get-Package | Where { $_.Name -like "*FFmpeg"}).Name -like "*FFmpeg" ) {
        "Found 'FFmpeg'.`n"
        Add-Content -Path "$log" -Value "`n------------`nFound 'FFmpeg'.`n------------`n"
    } Else {
        "'FFmpeg' not found.`n"
        Add-Content -Path "$log" -Value "`n------------`n'FFmpeg' not found.`n------------`n"
        Exiting -Reason "FFmpeg not installed.`nInstall 'FFmpeg' to copy files." -Exitcode 2
    }
} Else {
    # Verify handbrakeCLI installed for encoding.
    If ( $(Get-Package | Where { $_.Name -ieq "HandBrake CLI"}).Name -ieq "HandBrake CLI" ) {
        "Found 'HandBrake CLI'.`n"
        Add-Content -Path "$log" -Value "`n------------`nFound 'HandBrake CLI'.`n------------`n"
    } Else {
        "'HandBrake CLI' not found.`n"
        Add-Content -Path "$log" -Value "`n------------`n'HandBrake CLI' not found.`n------------`n"
        Exiting -Reason "'HandBrake CLI' not installed.`nInstall 'HandBrake CLI' to copy files." -Exitcode 2
    }
}
function Get-ReadyDirectory {
    [String[]]$readyDirectories = Get-ChildItem -Path $Source -Recurse -Include $Ready | Split-Path -Parent
    ForEach ( $directory In $readyDirectories ) {
        $readyDirectory = Split-Path -Path $directory -Leaf
        "`nCopying directory tree for '{0}'..." -f $directory
        Robocopy "$directory" "$Destination`\$readyDirectory" /mt:$($RobocopyThreads) /e /z /xf "*.*" /xx /unilog+:$log
        # Find mkv files.
        ForEach ( $sfp In $(Get-ChildItem -Path "$directory" -Recurse -Include "*.$SourceExt") ) {
            $in = $sfp.FullName
            $out = $($sfp.FullName).Replace($Source,$Destination)
            $out = $out.Replace($SourceExt,$DestinationExt)
            If ($Copying) {
                function Print-Output {
                    param(
                        [Switch]$CC,
                        [Switch]$MF
                    )
                    If ($CC) {
                        If ($MF) {
                            "`nCopying - Container Change - Movflags : {2}`nin  : {0}`nout : {1}" -f $in, $out, $Movflags
                            Add-Content -Path "$log" -Value "`n------------`nCopying - Container Change - Movflags: $Movflags`nin: '$in'`nout: '$out'.`n------------`n"
                        } Else {
                            "`nCopying - Container Change :`nin  : {0}`nout : {1}" -f $in, $out
                            Add-Content -Path "$log" -Value "`n------------`nCopying - Container Change:`nin: '$in'`nout: '$out'.`n------------`n"
                        }
                    } Else {
                        If ($MF) {
                            "`nCopying - Movflags : {2}`nin  : {0}`nout : {1}" -f $in, $out, $Movflags
                            Add-Content -Path "$log" -Value "`n------------`nCopying - Movflags: $Movflags`nin: '$in'`nout: '$out'.`n------------`n"
                        } Else {
                            "`nCopying :`nin  : {0}`nout : {1}" -f $in, $out
                            Add-Content -Path "$log" -Value "`n------------`nCopying:`nin: '$in'`nout: '$out'.`n------------`n"
                        }
                    }
                }
                If ($SourceExt -ieq $DestinationExt) {
                    # Copy without changing container.
                    If ($Movflags -ine "") {
                        If ($DestinationExt -ieq "mp4") {
                            Print-Output -MF
                            ffmpeg -i "$in" -map 0 -c:v copy -c:a copy -c:s mov_text -movflags "$Movflags" "$out"
                        } Else {
                            Print-Output -MF
                            ffmpeg -i "$in" -map 0 -c:v copy -c:a copy -c:s copy -movflags "$Movflags" "$out"
                        }
                    } Else {
                        Print-Output
                        ffmpeg -i "$in" -map 0 -c:v copy -c:a copy -c:s copy "$out"
                    }
                } Else {
                    # Change containers.
                    If ($Movflags -ine "") {
                        If ($DestinationExt -ieq "mp4") {
                            Print-Output -CC -MF
                            ffmpeg -i "$in" -map 0 -c:v copy -c:a copy -c:s mov_text -movflags "$Movflags" "$out"
                        } Else {
                            Print-Output -CC -MF
                            ffmpeg -i "$in" -map 0 -c:v copy -c:a copy -c:s copy -movflags "$Movflags" "$out"
                        }
                    } Else {
                        Print-Output -CC
                        ffmpeg -i "$in" -map 0 -c:v copy -c:a copy -c:s copy "$out"
                    }
                }
            } Else {
                # Encode files.
                If ( $Preset1 -ine "" ) {
                    If ( $Preset2 -ine "" ) {
                        If ( $in -imatch "extras" ) {
                            "Encoding Extras: {2}`nin  : {0}`nout : {1}`n" -f $in, $out, $Preset2
                            Add-Content -Path "$log" -Value "`n------------`Encoding Extras: $Preset2`nin: '$in'`nout: '$out'.`n------------`n"
                            HandBrakeCLI --preset-import-gui -Z "$Preset2" -i "$in" -o "$out"
                        } Else {
                            "Encoding Movie/trailer: {2}`nin  : {0}`nout : {1}`n" -f $in, $out, $Preset1
                            Add-Content -Path "$log" -Value "`n------------`Encoding Movie/trailer: $Preset1`nin: '$in'`nout: '$out'.`n------------`n"
                            HandBrakeCLI --preset-import-gui -Z "$Preset1" -i "$in" -o "$out"
                        }
                    } Else {
                        "Encoding: {2}`nin  : {0}`nout : {1}`n" -f $in, $out, $Preset1
                        Add-Content -Path "$log" -Value "`n------------`Encoding: $Preset1`nin: '$in'`nout: '$out'.`n------------`n"
                        HandBrakeCLI --preset-import-gui -Z "$Preset1" -i "$in" -o "$out"
                    }
                } Else { Exiting -Reason "No preset found for Preset1: '$Preset1'." -Exitcode 1 }
            }
        }
        # Move processed folder to $Processed.
        Move-Item -Path "$directory" -Destination "$Processed"
        "`nMoved '{0}' to '{1}'." -f $directory, $Processed
        Add-Content -Path "$log" -Value "`n------------`nMoved '$directory' to '$Processed'.`n------------`n"
        "Paused for {0} mins to allow graceful exit." -f $Pause
        Add-Content -Path "$log" -Value "`n------------`nPaused for $Pause mins to allow graceful exit.`n------------`n"
        Start-Sleep -Seconds ($Pause * 60)
    }
}
If ($CheckDirectorySilent) {
    While ($true) { Get-ReadyDirectory ; Start-Sleep -Seconds ($CheckDirectory * 60) }
} Else {
    While ($true) { Get-ReadyDirectory ; "Sleeping for {0} mins." -f $CheckDirectory ; Start-Sleep -Seconds ($CheckDirectory * 60) }
}

