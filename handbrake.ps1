# handbrake.ps1 © 2025 https://github.com/kalebpc/handbrakecli
<#
    .SYNOPSIS
    Copy or encode files using ffmpeg or handbrakeCLI.
    .DESCRIPTION
    Requires 'FFmpeg', 'HandBrake CLI'
    handbrake.ps1 script will recursively copy directories, re-encode or copy source files to destination then move source folder to $Processed.
    .EXAMPLE
    ./handbrake -Source 'C:/Users/Username/Downloads' -Destination 'C:/Users/Username/Videos' -Encoding 'Roku 1080p30'
#>
[CmdletBinding(DefaultParameterSetName = "Encoding")]
param(
    [Parameter(ParameterSetName = "Help", HelpMessage="Show help/usage.")]
    [Switch]$Help,
    [Parameter(HelpMessage="Enter the path to directory of input files.")]
    [String]$Source = "G:\Videos\MKV Videos",
    [Parameter(HelpMessage="Enter the path to directory of output files.")]
    [String]$Destination = "G:\Videos\Jellyfin\Movies",
    [Parameter(HelpMessage="Enter the extension of input files.")]
    [String]$SourceExt = "mkv",
    [Parameter(HelpMessage="Enter the extension of output files.")]
    [String]$DestinationExt = "mp4",
    [Parameter(HelpMessage="Enter the file to designate when a folder inside source directory is ready to be processed.")]
    [String]$Ready = "Ready.txt",
    [Parameter(HelpMessage="Enter the number of minutes to wait between folders processed.")]
    [Int32]$Pause = 1,
    [Parameter(HelpMessage="Enter the name of the folder to move source folders to after processing.")]
    [String]$Processed = [String]::Concat($(Split-Path -Path $Source -Qualifier), "/Temp-PostProcessed"),
    [Parameter(HelpMessage="Enter the fully qulified path to logs.")]
    [String]$Log = "$ENV:USERPROFILE/AppData/Local/Programs/handbrake/logs",
    [Parameter(HelpMessage="Enter the name of the log file including extension '.log'.")]
    [String]$LogFile = "handbrake.log",
    [Parameter(HelpMessage="Enter the number of threads for Robocopy to use when copying directory tree.")]
    [Int32]$RobocopyThreads = 4,
    [Parameter(HelpMessage="Enter the number of minutes to wait between running a check in Source directory folders for 'Ready file'.")]
    [Int32]$CheckDirectory = 1,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the name of the handbrakegui preset to use. Ex. 'Roku 1080p30'.")]
    [String]$Preset,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Flag if encoding files from source to destination.")]
    [Switch]$Encoding,
    [Parameter(Mandatory = $true, ParameterSetName = "Copying", HelpMessage="Flag if copying files from source to destination.")]
    [Switch]$Copying
)
function Help { "Syntax:`n`n$($(Get-Help ./handbrake) | ForEach { $_ })`nUsage:`n  ./handbrake -Source <string> -Destination <string> ...`nExample:`n  ./handbrake -Source 'C:/Users/Username/Downloads' -Destination 'C:/Users/Username/Videos' -Encoding 'Roku 1080p30'" ; Return }
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
# Verify paths.
If ( $Source -ne "" ) { If ( ! $(Test-Path -Path $Source) ) { Exiting -Reason "System cannot find '$Source'." -Exitcode 1 } Else { "Verified source path." } } Else { Exiting -Reason "System cannot find '$Source'." -Exitcode 1 }
If ( $Destination -ne "" ) { If ( ! $(Test-Path -Path $Destination) ) { Exiting -Reason "System cannot find '$Destination'." -Exitcode 1 } Else { "Verified destination path." } } ELSE { Exiting -Reason "System cannot find '$Destination'." -Exitcode 1 }
# Complete paths.
function Complete-Path { param([String]$P) return "$PWD$($P.Substring(1))" }
If ( $(Split-Path -Path $Source -Parent) -ieq "." ) { "Relative source path detected...Resolving to absolute path..." ; $Source = Complete-Path -P $Source ; "Done." }
If ( $(Split-Path -Path $Destination -Parent) -ieq "." ) { "Relative destination path detected...Resolving to absolute path..." ; $Destination = Complete-Path -P $Destination ; "Done." }
# Create directories if not existing.
If ( ! $(Test-Path -Path $Log) ) { New-Item -ItemType "Directory" -Path $Log -Force }
# Assemble log path/file.
$logPathFile = "$Log/$LogFile"
If ( ! $(Test-Path -Path $Processed) ) { New-Item -ItemType "Directory" -Path $Processed -Force }
# Verify ffmpeg installed for copying.
If ($Copying) {
    If ( $(Get-Package | Where { $_.Name -ieq "FFmpeg"}).Name -ieq "FFmpeg" ) {
        "Found 'FFmpeg'."
        Add-Content -Path "$logPathFile" -Value "`n------------`nFound 'FFmpeg'.`n------------`n"
    } Else {
        "'FFmpeg' not found."
        Add-Content -Path "$logPathFile" -Value "`n------------`n'FFmpeg' not found.`n------------`n"
        Exiting -Reason "FFmpeg not installed.`nInstall 'FFmpeg' to copy files." -Exitcode 2
    }
} Else {
    # Verify handbrakeCLI installed for encoding.
    If ( $(Get-Package | Where { $_.Name -ieq "HandBrake CLI"}).Name -ieq "HandBrake CLI" ) {
        "Found 'HandBrake CLI'."
        Add-Content -Path "$logPathFile" -Value "`n------------`nFound 'HandBrake CLI'.`n------------`n"
    } Else {
        "'HandBrake CLI' not found."
        Add-Content -Path "$logPathFile" -Value "`n------------`n'HandBrake CLI' not found.`n------------`n"
        Exiting -Reason "'HandBrake CLI' not installed.`nInstall 'HandBrake CLI' to copy files." -Exitcode 2
    }
}
function Get-ReadyDirectory {
    [String[]]$readyDirectories = Get-ChildItem -Path $Source -Recurse -Include $Ready | Split-Path -Parent
    ForEach ( $directory In $readyDirectories ) {
        $readyDirectory = Split-Path -Path $directory -Leaf
        "`nCopying directory tree for '{0}'..." -f $directory
        Robocopy "$directory" "$Destination`\$readyDirectory" /mt:$($RobocopyThreads) /e /z /xf "*.*" /xx /unilog+:$logPathFile
        # Find mkv files.
        ForEach ( $sfp In $(Get-ChildItem -Path "$directory" -Recurse -Include "*.$SourceExt") ) {
            $in = $sfp.FullName
            $out = $($sfp.FullName).Replace($Source,$Destination)
            $out = $out.Replace($SourceExt,$DestinationExt)
            If ($Copying) {
                # Change containers.
                "`nCopying - Container Change:`nin  : {0}`nout : {1}" -f $in, $out
                Add-Content -Path "$logPathFile" -Value "`n------------`nCopying - Container Change:`nin: '$in'`nout: '$out'.`n------------`n"
                ffmpeg -i $in -map 0 -c:v copy -c:a copy -c:s copy $out
            }
            If ($Encoding) {
                # Encode files.
                If ( $Preset -ine "" ) {
                    "Encoding: $Preset`nin  : {0}`nout : {1}`n" -f $in, $out
                    Add-Content -Path "$logPathFile" -Value "`n------------`nEncoding: $Preset`nin: '$in'`nout: '$out'.`n------------`n"
                    HandBrakeCLI --preset-import-gui -Z "$Preset" -i "$in" -o "$out"
                } Else { Exiting -Reason "No preset found for Encoding: '$Preset'." -Exitcode 1 }
            }
        }
        # Move processed folder to $Processed.
        Move-Item -Path "$directory" -Destination "$Processed"
        "`nMoved '{0}' to '{1}'." -f $directory, $Processed
        Add-Content -Path "$logPathFile" -Value "`n------------`nMoved '$directory' to '$Processed'.`n------------`n"
        "Paused for {0} mins to allow graceful exit." -f $Pause
        Add-Content -Path "$logPathFile" -Value "`n------------`nPaused for $Pause mins to allow graceful exit.`n------------`n"
        Start-Sleep -Seconds ($Pause * 60)
    }
}
$CheckDirectory = 1
# Time to wait in between running a check on source directory.
While ($true) { Get-ReadyDirectory ; "Sleeping for {0} mins." -f $CheckDirectory ; Start-Sleep -Seconds ($CheckDirectory * 60) }
