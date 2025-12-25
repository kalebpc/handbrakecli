
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
    ./handbrake -Encoding -Preset1 'Roku 1080p30' -Preset2 'Roku 480p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed'

.EXAMPLE
    ./handbrake -Encoding -Preset1 'Roku 1080p30' -Preset2 'Roku 480p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -CheckDirectorySilent

.EXAMPLE
    ./handbrake -Encoding -Preset1 'Roku 1080p30' -Preset2 'Roku 480p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -CheckDirectorySilent -RobocopyThreads 32

.EXAMPLE
    ./handbrake -Copying -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -Movflags '+faststart'

.EXAMPLE
    ./handbrake -Copying -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -CheckDirectorySilent

.EXAMPLE
    ./handbrake -Copying -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -CheckDirectorySilent -RobocopyThreads 128

.EXAMPLE
    ./handbrake.ps1 -Encoding -Preset1 'Roku 1080p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -CheckDirectorySilent -Notify "file",".env"

.EXAMPLE
    ./handbrake.ps1 -Encoding -Preset1 'Roku 1080p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed' -CheckDirectorySilent -Notify "discordUsername","https://discord.com/api/finishRestOfWebhookUriHere"

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
    [String]$Movflags,
    [Parameter(ParameterSetName = "Encoding", HelpMessage="Send script updates to discord webhook. Example: 'username','webhookUri' ; Example: 'file','webhookfile.ext' to load 'username' and 'webhookUri' from file.")]
    [Parameter(ParameterSetName = "Copying", HelpMessage="Send script updates to discord webhook. Example: 'username','webhookUri' ; Example: 'file','webhookfile.ext' to load 'username' and 'webhookUri' from file.")]
    [String[]]$Notify
)



function Exit-Script {
    [CmdletBinding(DefaultParameterSetName = "Exiting")]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Reason,
        [Parameter(Mandatory = $true, HelpMessage = "0 = Print success, exitcode and exit.`n1 = Print reason, help, exitcode and exit.`n2 = Print reason, exitcode and exit.`nAny other number = Print nothing and exit.`n")]
        [Int32]$Exitcode,
        [Parameter(HelpMessage = "Path to script help function.")]
        [String]$ScriptHelp
    )
    If ( $ScriptHelp -ieq "" -and $Exitcode -eq 1 ) {
        $Exitcode = 2
    } Else {
        $ScriptHelp = $ScriptHelp + " -Help"
    }
    Switch ($Exitcode) {
        # Print success,exitcode and exit
        0 { "`nFinished Successfully.`n`nExit 0" ; Exit }
        # Print reason,help,exitcode and exit
        1 { "`n{0}`n" -f $Reason ; Powershell -C "&{ $ScriptHelp }" ; "`nExit {0}" -f $Exitcode ; Exit }
        # Print reason,exitcode and exit
        2 { "`n{0}`n" -f $Reason ; "`nExit {0}" -f $Exitcode ; Exit }
        # Print nothing and exit
        Default { Exit }
    }
}
function Add-LogAndPrint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Message to print to screen and add to log file.")]
        [String]$Content,
        [Parameter(HelpMessage = "Path to log file")]
        [String]$Path
    )
    "`n[$(Get-Date -Format "yyyy.MM.dd - hh:mm:ss tt")] {0}`n" -f $Content
    If ( $Path -ine "" ) { If ( Test-Path -Path $Path ) { Add-Content -Path $Path -Value "`n------------`n[$(Get-Date -Format "yyyy.MM.dd - hh:mm:ss tt")] $Content`n------------`n" } Else { "`nError printing to log file." } }
}
function Send-Message {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Message to send.")]
        [String]$Content,
        [Parameter(Mandatory = $true, HelpMessage = "Discord username.")]
        [String]$Username,
        [Parameter(Mandatory = $true, HelpMessage = "Enter webhook https address. Example: 'https://discord.com/api/webhooks/restofyourwebhookhere'.")]
        [String]$Webhookuri
    )
    [String]$response = "Success."
    $body = @{
        'username' = $Username
        'content' = $Content
    }
    Try {
        Invoke-RestMethod -Uri $Webhookuri -Method 'post' -Body $body
    } Catch {
        $response = "Error sending post to 'Webhookuri'.`n  StatusCode: {0}`n  StatusDescription: {1}`n" -f $_.Exception.Response.StatusCode.value__, $_.Exception.Response.StatusDescription
    }
    return $response
}
function Confirm-UserWebHook {
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Example: 'username','webhookUri' ; Example from file: 'file','webhookfile.ext'")]
        [String[]]$ArgumentList
    )
    [PSCustomObject]$result = @{
        'Verified' = $false
        'Username' = ''
        'Webhookuri' = ''
    }
    If ( $ArgumentList.Length -gt 1 ) {
        If ( $ArgumentList[0] -ieq "file" ) {
            # Check if file exists.
            If ( Test-Path -Path $ArgumentList[1].Trim() ) {
                # File exists.
                ForEach ( $line In $(Get-Content -Path $ArgumentList[1]) ) {
                    $temp1, $temp2 = $($line -split "=", 2).Trim()
                    $temp1, $temp2 = $($temp1, $temp2).Trim("'")
                    $temp1, $temp2 = $($temp1, $temp2).Trim('"')
                    If ( $temp1 -ieq "username" ) {
                        "Found 'username'."
                        $result.Username = $temp2
                    } ElseIf ( $temp1 -ieq "webhookUri" ) {
                        "Found 'webhookUri'."
                        $result.Webhookuri = $temp2
                    }
                }
            }
        } ElseIf ( $ArgumentList[1] -ieq "file" ) {
            # Check if file exists.
            If ( Test-Path -Path $ArgumentList[0].Trim() ) {
                # File exists.
                ForEach ( $line In $(Get-Content -Path $ArgumentList[0]) ) {
                    $temp1, $temp2 = $($line -split "=", 2).Trim()
                    $temp1, $temp2 = $($temp1, $temp2).Trim("'")
                    $temp1, $temp2 = $($temp1, $temp2).Trim('"')
                    If ( $temp1 -ieq "username" ) {
                        "Found 'username'."
                        $result.Username = $temp2
                    } ElseIf ( $temp1 -ieq "webhookUri" ) {
                        "Found 'webhookUri'."
                        $result.Webhookuri = $temp2
                    }
                }
            }
        } Else {
            # Handle direct username, webhook entry.
            If ( $ArgumentList[0] -imatch "^https\:.*discord\.com.*api" ) {
                "Found 'username'."
                $result.UserName = $ArgumentList[1].Trim()
                "Found 'webhookUri'."
                $result.Webhookuri = $ArgumentList[0].Trim()
            } Else {
                "Found 'username'."
                $result.Username = $ArgumentList[0].Trim()
                "Found 'webhookUri'."
                $result.Webhookuri = $ArgumentList[1].Trim()
            }
        }
        If ( $result.Username -ine "" -and $result.Webhookuri -ine "" ) { $result.Verified = $true }
    }
    return $result
}
function Complete-Path { param([String]$P) return "$PWD$($P.Substring(1))" }
function Help {
   "Usage: `
    ./handbrake -Encoding -Preset1 <string> [-Preset2 <string>] -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options] `
    ./handbrake -Copying -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Ready <string> -Processed <string> [Options] `
    ./handbrake -Help`n `

Options: `
    -Pause                  - Number of minutes to wait between folders ready to be processed. `
    -RobocopyThreads        - Number of cpu threads for Robocopy to use when copying directory tree. `
    -CheckDirectory         - Number of minutes to wait between scanning Source directory folders for 'Ready' file. `
    -CheckDirectorySilent   - Flag to suppress the 'Sleeping for $CheckDirectory mins.' output in terminal. `
    -Movflags               - Set FFmpeg -movflags switch. `
    -Notify                 - Send script updates to discord webhook.
                                Example             : 'username','https://discord.com/api/webhooks/yourwebhookhere'
                                Example from file   : 'file','webhookfile.ext'`n `
Example: `
    ./handbrake -Encoding -Preset1 'Roku 1080p30' -Preset2 'Roku 480p30' -Source 'G:/Downloads' -Destination 'G:/Videos' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed'`n"
    Return
}



If ($help) { Help ; Exit-Script -Reason "Show Help." -ExitCode 3 }
# Remove trailing whitespace
$Source = $Source.Trim()
$Destination = $Destination.Trim()
$Processed = $Processed.Trim()
$SourceExt = $SourceExt.Trim()
$DestinationExt = $DestinationExt.Trim()
$Ready = $Ready.Trim()
$Preset1 = $Preset1.Trim()
$Preset2 = $Preset2.Trim()
$Movflags = $Movflags.Trim()
$userName = ""
$webHookUri = ""
If ($Copying) { "Moveflags: '{0}'`n" -f $Movflags } Else { "Preset1: '{0}'`nPreset2: '{1}'`n" -f $Preset1,$Preset2 }

# TODO ...
# Need to find a way to figure out if destination is in the same path of source.
# There is a issue where if the destination folder is in same directory of the source causes a recursion fault.

# TODO ...
# Add keeping track of how long a folder takes to finish. Notify, print, and log calculated time.

# Set install path.
[String]$installPath = "$ENV:LOCALAPPDATA\Scripts\HandBrake"
[String]$log = "$installPath\logs\handbrake.log"
# Verify paths.
If ( ! $(Test-Path -Path $installPath) ) { New-Item -ItemType "Directory" -Path $installPath -Force }
If ( $Source -ne "" ) { If ( ! $(Test-Path -Path $Source) ) { Exit-Script -Reason "System cannot find '$Source'." -Exitcode 1 -ScriptHelp $(Complete-Path -P "./handbrake.ps1") } Else { "Verified 'Source' path." } } Else { Exit-Script -Reason "System cannot find '$Source'." -Exitcode 1 -ScriptHelp $(Complete-Path -P "./handbrake.ps1") }
If ( $Destination -ne "" ) { If ( ! $(Test-Path -Path $Destination) ) { New-Item -ItemType "Directory" -Path $Destination -Force } Else { "Verified 'Destination' path." } } ELSE { Exit-Script -Reason "System cannot find '$Destination'." -Exitcode 1 -ScriptHelp $(Complete-Path -P "./handbrake.ps1") }
# Complete paths.
If ( $(Split-Path -Path $Source -Parent) -ieq "." ) { "Relative source path detected...Resolving to absolute path..." ; $Source = Complete-Path -P $Source ; "Done." }
If ( $(Split-Path -Path $Destination -Parent) -ieq "." ) { "Relative destination path detected...Resolving to absolute path..." ; $Destination = Complete-Path -P $Destination ; "Done." }
# Create logs path.
If ( ! $(Test-Path -Path $(Split-Path -Path $log -Parent)) ) { New-Item -ItemType "Directory" -Path $(Split-Path -Path $log -Parent) -Force } Else { "Verified 'logs' path." }
# Create processed path.
If ( $Processed -ne "" ) { If ( ! $(Test-Path -Path $Processed) ) { New-Item -ItemType "Directory" -Path $Processed -Force } Else { "Verified 'Processed' path.`n" } } Else { Exit-Script -Reason "System cannot find '$Processed'." -Exitcode 1 -ScriptHelp $(Complete-Path -P "./handbrake.ps1") }
# Validate extensions input.
If ( $SourceExt -ieq "" -or $DestinationExt -ieq "" ) { Exit-Script -Reason "SourceExt '$SourceExt' or DestinationExt '$DestinationExt' is empty string." -ExitCode 1 -ScriptHelp $(Complete-Path -P "./handbrake.ps1") }

# TODO ...
# Need to add input validation for file extensions that are supported by HandBrakeCLI.

# Verify ffmpeg installed for copying.
If ($Copying) {
    Add-LogAndPrint -Path $log -Content "Checking for 'FFmpeg'..."
    If ( $(Get-Package | Where { $_.Name -like "*FFmpeg"}).Name -like "*FFmpeg" ) {
        Add-LogAndPrint -Path $log -Content "Found 'FFmpeg'"
    } Else {
        Add-LogAndPrint -Path $log -Content "'FFmpeg' not found."
        Exit-Script -Reason "FFmpeg not installed.`nInstall 'FFmpeg' to copy files." -Exitcode 2
    }
} Else {
    Add-LogAndPrint -Path $log -Content "Checking for 'HandBrake CLI'..."
    # Verify handbrakeCLI installed for encoding.
    If ( $(Get-Package | Where { $_.Name -ieq "HandBrake CLI"}).Name -ieq "HandBrake CLI" ) {
        Add-LogAndPrint -Path $log -Content "Found 'HandBrake CLI'"
    } Else {
        Add-LogAndPrint -Path $log -Content "'HandBrake CLI' not found."
        Exit-Script -Reason "'HandBrake CLI' not installed.`nInstall 'HandBrake CLI' to copy files." -Exitcode 2
    }
}
# Setup Notify.
[Boolean]$sendNote = $false
If ( $Notify.Length -gt 1) {
    Add-LogAndPrint -Path $log -Content "Setting up discord webhook..."
    # Truncate Notify to 2 elements.
    $Notify = $Notify[0..1]
    # Complete paths.
    If ( $(Split-Path -Path $Notify[0] -Parent) -ieq "." ) { "Relative destination path detected...Resolving to absolute path..." ; $Notify[0] = Complete-Path -P $Notify[0] ; "Done." }
    If ( $(Split-Path -Path $Notify[1] -Parent) -ieq "." ) { "Relative destination path detected...Resolving to absolute path..." ; $Notify[1] = Complete-Path -P $Notify[1] ; "Done." }
    [PSCustomObject]$result = Confirm-UserWebHook -ArgumentList $Notify
    If ( $result.Verified -eq $true ) {
        $sendNote = $true
        Add-LogAndPrint -Path $log -Content "Notify enabled.`nFound: 'username'`nFound: 'webhookUri'"
        If ($Copying) {
            $response = Send-Message -Content "handbrake.ps1 started copying." -Username $result.Username -Webhookuri $result.Webhookuri
        } Else {
            $response = Send-Message -Content "handbrake.ps1 started encoding." -Username $result.Username -Webhookuri $result.Webhookuri
        }
        # Print and log error if encountered.
        If ( $response -ilike "*Error*" ) { Add-LogAndPrint -Path $log -Content $response }
    } Else {
        $temp1, $temp2 = '',''
        If ( $result.Username -ieq "" ) { $temp1 = "`n'username' not found." }
        If ( $result.Webhookuri -ieq "" ) { $temp2 = "`n'webhookUri' not found." }
        Add-LogAndPrint -Path $log -Content "Notify not enabled.$temp1$temp2"
    }
}
function Run-Loop {
    ForEach ( $directory In $(Get-ChildItem -Path $Source -Recurse -Include $Ready | Split-Path -Parent) ) {
        $readyDirectory = Split-Path -Path $directory -Leaf
        If ($sendNote) {
            $response = Send-Message -Content "Copying directory tree for '$readyDirectory'." -Username $result.Username -Webhookuri $result.Webhookuri
            If ( $response -ilike "*Error*" ) { Add-LogAndPrint -Path $log -Content $response }
        }
        Add-LogAndPrint -Path $log -Content "Copying directory tree for '$directory'..."
        # Copy directory tree.
        $options = @("/mt:$($RobocopyThreads)", "/e", "/z", "/xf", "*.*", "/xx", "/unilog+:$log")
        Robocopy $directory "$Destination`\$readyDirectory" $options
        # Find mkv files.
        ForEach ( $file In $(Get-ChildItem -Path "$directory" -Recurse -Include "*$SourceExt") ) {
            $in = $file.FullName
            $out = $($($file.FullName).Replace($Source,$Destination)).Replace($SourceExt,$DestinationExt)
            # $out = $out.Replace($SourceExt,$DestinationExt)
            If ($Copying) {
                If ($SourceExt -ieq $DestinationExt) {
                    # Copy without changing container.
                    If ($Movflags -ine "") {
                        If ($DestinationExt -ieq "mp4") {
                            Add-LogAndPrint -Path $log -Content "Copying - Movflags: $Movflags`nin  : '$in'`nout : '$out'."
                            ffmpeg -i "$in" -map 0 -c:v copy -c:a copy -c:s mov_text -movflags "$Movflags" "$out"
                        } Else {
                            Add-LogAndPrint -Path $log -Content "Copying - Movflags: $Movflags`nin  : '$in'`nout : '$out'."
                            ffmpeg -i "$in" -map 0 -c:v copy -c:a copy -c:s copy -movflags "$Movflags" "$out"
                        }
                    } Else {
                        Add-LogAndPrint -Path $log -Content "Copying:`nin  : '$in'`nout : '$out'."
                        ffmpeg -i "$in" -map 0 -c:v copy -c:a copy -c:s copy "$out"
                    }
                } Else {
                    # Change containers.
                    If ($Movflags -ine "") {
                        If ($DestinationExt -ieq "mp4") {
                            Add-LogAndPrint -Path $log -Content "Copying - Container Change - Movflags: $Movflags`nin  : '$in'`nout : '$out'."
                            ffmpeg -i "$in" -map 0 -c:v copy -c:a copy -c:s mov_text -movflags "$Movflags" "$out"
                        } Else {
                            Add-LogAndPrint -Path $log -Content "Copying - Container Change - Movflags: $Movflags`nin  : '$in'`nout : '$out'."
                            ffmpeg -i "$in" -map 0 -c:v copy -c:a copy -c:s copy -movflags "$Movflags" "$out"
                        }
                    } Else {
                        Add-LogAndPrint -Path $log -Content "Copying - Container Change:`nin  : '$in'`nout : '$out'."
                        ffmpeg -i "$in" -map 0 -c:v copy -c:a copy -c:s copy "$out"
                    }
                }
            } Else {
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
                            Add-LogAndPrint -Path $log -Content "Encoding Extras: $Preset2`nin  : '$in'`nout : '$out'."
                            Encode $Preset2
                        } Else {
                            Add-LogAndPrint -Path $log -Content "Encoding Movie/trailer: $Preset1`nin  : '$in'`nout : '$out'."
                            Encode $Preset1
                        }
                    } Else {
                        Add-LogAndPrint -Path $log -Content "Encoding: $Preset1`nin  : '$in'`nout : '$out'."
                        Encode $Preset1
                    }
                } Else { Exit-Script -Reason "No preset found for Preset1: '$Preset1'." -Exitcode 1 -ScriptHelp $(Complete-Path -P "./handbrake.ps1") }
            }
        }
        
        # TODO ...
        # Need to figure out how to know when an encode has failed or succeeded.

        # Move folder to $Processed.
        Move-Item -Path "$directory" -Destination "$Processed"
        Add-LogAndPrint -Path $log -Content "Moved '$directory' to '$Processed'."
        Add-LogAndPrint -Path $log -Content "Finished '$readyDirectory'."
        Add-LogAndPrint -Path $log -Content "Paused for '$Pause' mins to allow graceful exit."
        If ($sendNote) {
            $response = Send-Message -Content "Finished '$readyDirectory': $(Get-Date -Format "yyyy.MM.dd - hh:mm:ss tt")`nPaused for '$Pause' mins." -Username $result.Username -Webhookuri $result.Webhookuri
            If ( $response -ilike "*Error*" ) { Add-LogAndPrint -Path $log -Content $response }
        }
        Start-Sleep -Seconds ($Pause * 60)
    }
}
If ($CheckDirectorySilent) {
    While ($true) { Run-Loop ; Start-Sleep -Seconds ($CheckDirectory * 60) }
} Else {
    While ($true) { Run-Loop ; "Sleeping for {0} mins." -f $CheckDirectory ; Start-Sleep -Seconds ($CheckDirectory * 60) }
}
