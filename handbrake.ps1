
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

.REQUIREDSCRIPTS Add-LogAndPrint.ps1 Confirm-UserWebHook.ps1 Send-Message.ps1 

.EXTERNALSCRIPTDEPENDENCIES HandBrakeCLI 

.RELEASENOTES handbrake.ps1 © 2025 https://github.com/kalebpc/handbrakecli

#>

<#

.SYNOPSIS
    Encode files using HandBrakeCLI.

.DESCRIPTION
    Requires 'HandBrake CLI'
    handbrake.ps1 script will recursively copy directories, re-encode or copy source files to destination then move folder from 'Source' to 'Processed'.

.PARAMETER Help
    Show help/usage.

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

.PARAMETER CheckDirectory
    Number of minutes to wait between scanning Source directory folders for 'Ready file'.

.PARAMETER Notify
    Send script updates to discord webhook.
        Example:    'username','webhookUri'.
        Example:    'file','webhookfile.ext'.   Loads 'username' and 'webhookUri' from file.
                    
        webhookfile.ext contents:   'username' = 'yourusernamehere'
                                    'webhookUri' = 'https://discord.com/api/webhooks/yourwebhookhere'

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    ./handbrake -Preset1 'Roku 1080p30' -Preset2 'Roku 480p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed'

.EXAMPLE
    ./handbrake -Preset1 'Roku 1080p30' -Preset2 'Roku 480p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed'

.EXAMPLE
    ./handbrake.ps1 -Preset1 'Roku 1080p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -Notify "file",".env"

.EXAMPLE
    ./handbrake.ps1 -Preset1 'Roku 1080p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -Notify "discordUsername","https://discord.com/api/finishRestOfWebhookUriHere"

#>


[CmdletBinding(DefaultParameterSetName = "Encoding")]
param(
    [Parameter(ParameterSetName = "Help")]
    [Switch]$Help,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the name of the handbrakegui preset to use for 'movie/trailers/etc'. Examples: 'Roku 1080p30'.")]
    [String]$Preset1,
    [Parameter(ParameterSetName = "Encoding", HelpMessage="Enter the name of the handbrakegui preset to use for 'extras'. Examples: 'Roku 480p30'.")]
    [String]$Preset2,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the path to directory of input folders.")]
    [String]$Source,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the path to directory of output folders.")]
    [String]$Destination,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the extension of input files.")]
    [String]$SourceExt,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the extension of output files.")]
    [String]$DestinationExt,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the file found in a source folder to designate when it is ready to be processed.")]
    [String]$Ready,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the fully qulified path of the folder to move source folders to after processing.")]
    [String]$Processed,
    [Parameter(ParameterSetName = "Encoding", HelpMessage="Enter the number of minutes to wait between folders that are ready to be processed.")]
    [Int32]$Pause = 1,
    [Parameter(ParameterSetName = "Encoding", HelpMessage="Enter the number of minutes to wait between scanning Source directory folders for 'Ready file'.")]
    [Int32]$CheckDirectory = 1,
    [Parameter(ParameterSetName = "Encoding", HelpMessage="Send script updates to discord webhook. Example: 'username','webhookUri' ; Example: 'file','webhookfile.ext' to load 'username' and 'webhookUri' from file.")]
    [String[]]$Notify
)

function Complete-Path { param([String]$P) return "$PWD$($P.Substring(1))" }
function Help {
   "Usage: `
    ./handbrake -Preset1 <string> [-Preset2 <string>] -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options] `
    ./handbrake -Help`n `

Options: `
    -Pause                  - Number of minutes to wait between folders ready to be processed. `
    -CheckDirectory         - Number of minutes to wait between scanning Source directory folders for 'Ready' file. `
    -Notify                 - Send script updates to discord webhook.
                                Example             : 'username','https://discord.com/api/webhooks/yourwebhookhere'
                                Example from file   : 'file','webhookfile.ext'`n `
Example: `
    ./handbrake -Preset1 'Roku 1080p30' -Preset2 'Roku 480p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed'`n"
    Exit
}

If ($help) { Help }
# Remove trailing whitespace
$Source = $Source.Trim()
$Destination = $Destination.Trim()
$Processed = $Processed.Trim()
$SourceExt = $SourceExt.Trim()
$DestinationExt = $DestinationExt.Trim()
$Ready = $Ready.Trim()
$Preset1 = $Preset1.Trim()
$Preset2 = $Preset2.Trim()
$userName = ""
$webHookUri = ""
"Preset1: '{0}'`nPreset2: '{1}'`n" -f $Preset1,$Preset2

# TODO ...
# Need to find a way to figure out if destination is in the same path of source.
# There is a issue where if the destination folder is in same directory of the source causes a recursion fault.

# Set install path.
[String]$installPath = "$ENV:LOCALAPPDATA\Scripts\HandBrake"
[String]$log = "$installPath\logs\handbrake.log"
# Verify paths.
If ( ! $(Test-Path -LiteralPath $installPath) ) { New-Item -ItemType "Directory" -LiteralPath $installPath -Force }
If ( $Source -ne "" ) { If ( ! $(Test-Path -LiteralPath $Source) ) { "System cannot find '{0}'.`n`nExitcode : 1" -f $Source ; Help } Else { "Verified 'Source' path." } } Else { "System cannot find '{0}'.`n`nExitcode : 1" -f $Source ; Help }
If ( $Destination -ne "" ) { If ( ! $(Test-Path -LiteralPath $Destination) ) { New-Item -ItemType "Directory" -LiteralPath $Destination -Force } Else { "Verified 'Destination' path." } } ELSE { "System cannot find '{0}'.`n`nExitcode : 1" -f $Destination ; Help }
# Complete paths.
If ( $(Split-Path -Path $Source -Parent) -ieq "." ) { "Relative source path detected...Resolving to absolute path..." ; $Source = Complete-Path -P $Source ; "Done." }
If ( $(Split-Path -Path $Destination -Parent) -ieq "." ) { "Relative destination path detected...Resolving to absolute path..." ; $Destination = Complete-Path -P $Destination ; "Done." }
# Create logs path.
If ( ! $(Test-Path -LiteralPath $(Split-Path -Path $log -Parent)) ) { New-Item -ItemType "Directory" -LiteralPath $(Split-Path -Path $log -Parent) -Force } Else { "Verified 'logs' path." }
# Create processed path.
If ( $Processed -ne "" ) { If ( ! $(Test-Path -LiteralPath $Processed) ) { New-Item -ItemType "Directory" -LiteralPath $Processed -Force } Else { "Verified 'Processed' path.`n" } } Else { "System cannot find '{0}'.`n`nExitcode : 1" -f $Processed ; Help }
# Validate extensions input.
If ( $SourceExt -ieq "" -or $DestinationExt -ieq "" ) { "SourceExt '{0}' or DestinationExt '{1}' is empty string.`n`nExitcode : 1" -f $SourceExt, $DestinationExt ; Help }

# TODO ...
# Need to add input validation for file extensions that are supported by HandBrakeCLI.

./Add-LogAndPrint.ps1 -Path $log -Content "Checking for 'HandBrake CLI'..."
# Verify handbrakeCLI installed.
If ( $(Get-Package | Where { $_.Name -ieq "HandBrake CLI"}).Name -ieq "HandBrake CLI" ) {
    ./Add-LogAndPrint.ps1 -Path $log -Content "Found 'HandBrake CLI'"
} Else {
    ./Add-LogAndPrint.ps1 -Path $log -Content "'HandBrake CLI' not found."
    "'HandBrake CLI' not installed.`nInstall 'HandBrake CLI'.`n`nExitcode : 2"
}
# Setup Notify.
[Boolean]$sendNote = $false
If ( $Notify.Length -gt 1) {
    ./Add-LogAndPrint.ps1 -Path $log -Content "Setting up discord webhook..."
    # Truncate Notify to 2 elements.
    $Notify = $Notify[0..1]
    # Complete paths.
    If ( $(Split-Path -LiteralPath $Notify[0] -Parent) -ieq "." ) { "Relative path detected...Resolving to absolute path..." ; $Notify[0] = Complete-Path -P $Notify[0] ; "Done." }
    If ( $(Split-Path -LiteralPath $Notify[1] -Parent) -ieq "." ) { "Relative path detected...Resolving to absolute path..." ; $Notify[1] = Complete-Path -P $Notify[1] ; "Done." }
    [PSCustomObject]$result = ./Confirm-UserWebHook.ps1 -ArgumentList $Notify
    If ( $result.Verified -eq $true ) {
        $sendNote = $true
        ./Add-LogAndPrint.ps1 -Path $log -Content "Notify enabled.`nFound: 'username'`nFound: 'webhookUri'"
        $response = ./Send-Message.ps1 -Content "handbrake.ps1 started." -Username $result.Username -Webhookuri $result.Webhookuri
        # Print and log error if encountered.
        If ( $response -ilike "*Error*" ) { ./Add-LogAndPrint.ps1 -Path $log -Content $response }
    } Else {
        $temp1, $temp2 = '',''
        If ( $result.Username -ieq "" ) { $temp1 = "`n'username' not found." }
        If ( $result.Webhookuri -ieq "" ) { $temp2 = "`n'webhookUri' not found." }
        ./Add-LogAndPrint.ps1 -Path $log -Content $("Notify not enabled.{0}{1}" -f $temp1, $temp2)
    }
}
function Run-Loop {
    ForEach ( $directory In $(Get-ChildItem -LiteralPath $Source -Recurse -Include $Ready | Split-Path -Parent) ) {
        $readyDirectory = Split-Path -LiteralPath $directory -Leaf
        If ($sendNote) {
            $response = ./Send-Message.ps1 -Content $("Copying directory tree for '{0}'." -f $readyDirectory) -Username $result.Username -Webhookuri $result.Webhookuri
            If ( $response -ilike "*Error*" ) { ./Add-LogAndPrint.ps1 -Path $log -Content $response }
        }
        ./Add-LogAndPrint.ps1 -Path $log -Content $("Copying directory tree for '{0}'..." -f $directory)
        # Copy directory tree.
        $options = @("/e", "/z", "/xf", "*.*", "/xx", "/unilog+:$log")
        Robocopy $directory "$Destination\$readyDirectory" $options
        # Find mkv files.
        ForEach ( $file In $(Get-ChildItem -LiteralPath "$directory" -Recurse -Include "*$SourceExt") ) {
            $in = $file.FullName
            $out = $($file.FullName).Replace($Source,$Destination)
            $out = $out.Replace($SourceExt,$DestinationExt)
            function Encode {
                [CmdletBinding()]
                param(
                    [Parameter(Position = 0)]
                    [String]$Preset
                )
                HandBrakeCLI --preset-import-gui -Z $Preset -i $in -o $out
            }
            # Encode files.
            If ( $Preset1 -ine "" ) {
                If ( $Preset2 -ine "" ) {
                    # TODO ... Add config where ANY subfolders are processed with Preset2 but direct folder uses Preset1.
                    If ( $in -imatch "extras" ) {
                        ./Add-LogAndPrint.ps1 -Path $log -Content $("Encoding Extras: {0}`nin  : '{1}'`nout : '{2}'." -f $Preset2, $in, $out)
                        Encode $Preset2
                    } Else {
                        ./Add-LogAndPrint.ps1 -Path $log -Content $("Encoding Movie/trailer: {0}`nin  : '{1}'`nout : '{2}'." -f $Preset1, $in, $out)
                        Encode $Preset1
                    }
                } Else {
                    ./Add-LogAndPrint.ps1 -Path $log -Content $("Encoding: {0}`nin  : '{1}'`nout : '{2}'." -f $Preset1, $in, $out)
                    Encode $Preset1
                }
            } Else { "No preset found for Preset1: '{0}'.`n`nExitcode : 1" -f $Preset1 ; Help }
        }
        # Move folder to $Processed.
        Move-Item -LiteralPath "$directory" -Destination "$Processed"
        ./Add-LogAndPrint.ps1 -Path $log -Content $("Moved '{0}' to '{1}'." -f $directory, $Processed)
        ./Add-LogAndPrint.ps1 -Path $log -Content $("Finished '{0}'." -f $readyDirectory)
        ./Add-LogAndPrint.ps1 -Path $log -Content $("Paused for '{0}' mins to allow graceful exit." -f $Pause)
        If ($sendNote) {
            $response = ./Send-Message.ps1 -Content $("Finished '{0}': {1}`nPaused for '{2}' mins." -f $readyDirectory, $(Get-Date -Format "yyyy.MM.dd - hh:mm:ss tt"), $Pause) -Username $result.Username -Webhookuri $result.Webhookuri
            If ( $response -ilike "*Error*" ) { ./Add-LogAndPrint.ps1 -Path $log -Content $response }
        }
        Start-Sleep -Seconds ($Pause * 60)
    }
}
While ($true) { Run-Loop ; Start-Sleep -Seconds ($CheckDirectory * 60) }
