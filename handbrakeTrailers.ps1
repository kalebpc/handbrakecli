
<#PSScriptInfo

.VERSION 1.0

.GUID a4f9b8af-f49a-4642-bd8e-3410ae9f7661

.AUTHOR https://github.com/kalebpc

.COMPANYNAME 

.COPYRIGHT 2025 https://github.com/kalebpc/handbrakecli

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS Add-LogAndPrint.ps1 Confirm-UserWebHook.ps1 Send-Message.ps1

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 Create folders in Destination with the same name as files. Use HandBrakeCLI to encode files from Source to new folders in Destination. 

.PARAMETER Help
    Show help.

.PARAMETER Encoding
    Flag to encode files from source.

.PARAMETER Preset
    Enter the name of the handbrakegui preset to use. Example: 'Roku 1080p30'.

.PARAMETER Source
    Enter the path to directory of input folders.

.PARAMETER Destination
    Enter the path to directory of output folders.

.PARAMETER SourceExt
    Enter the extension of input files.

.PARAMETER DestinationExt
    Enter the extension of output files.

.PARAMETER Processed
    Path to movie folders.

.PARAMETER Notify
    <string[]>
    Send script updates to discord webhook.
        Example:    'username','webhookUri'.
        Example:    'file','webhookfile.ext'.   Loads 'username' and 'webhookUri' from file.
                    
        webhookfile.ext contents:   'username' = 'yourusernamehere'
                                    'webhookUri' = 'https://discord.com/api/webhooks/yourwebhookhere'

.PARAMETER CheckMovies
    Enter the fully qulified path of the folder to move source files to after processing.

.EXAMPLE
    ./handbrakeTrailers.ps1 -Encoding -Preset1 'Roku 1080p30' -Source 'G:/Downloads' -Destination 'G:/Videos/Movie Trailers' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed/Movie Trailers'

.EXAMPLE
    ./handbrakeTrailers.ps1 -Preset1 'Roku 1080p30' -Source 'G:/Downloads' -Destination 'G:/Videos/Movie Trailers' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed/Movie Trailers'

.EXAMPLE
    ./handbrakeTrailers.ps1 -Preset1 'Roku 1080p30' -Source 'G:/Downloads' -Destination 'G:/Videos/Movie Trailers' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed/Movie Trailers' -Notify "discordUsername","https://discord.com/api/finishRestOfWebhookUriHere"

.EXAMPLE
    ./handbrakeTrailers.ps1 -Preset1 'Roku 1080p30' -Source 'G:/Downloads' -Destination 'G:/Videos/Movie Trailers' -SourceExt 'mkv' -DestinationExt 'mp4' -Ready 'Ready.txt' -Processed 'G:/Videos/Post-Processed/Movie Trailers' -Notify "file",".env"

#> 


[CmdletBinding(DefaultParameterSetName = "Encoding")]
param(
    [Parameter(ParameterSetName = "Help")]
    [Switch]$Help,
    [Parameter(ParameterSetName = "Encoding")]
    [Switch]$Encoding = $true,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the name of the handbrakegui preset to use. Example: 'Roku 1080p30'.")]
    [String]$Preset,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the path to directory of input folders.")]
    [String]$Source,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the path to directory of output folders.")]
    [String]$Destination,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the extension of input files.")]
    [String]$SourceExt,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the extension of output files.")]
    [String]$DestinationExt,
    [Parameter(Mandatory = $true, ParameterSetName = "Encoding", HelpMessage="Enter the fully qulified path of the folder to move source files to after processing.")]
    [String]$Processed,
    [Parameter(ParameterSetName = "Encoding", HelpMessage="Send script updates to discord webhook. Example: 'username','webhookUri' ; Example: 'file','webhookfile.ext' to load 'username' and 'webhookUri' from file.")]
    [String[]]$Notify,
    [Parameter(ParameterSetName = "Encoding", HelpMessage="Path to movie folders.")]
    [String]$CheckMovies
)

function Complete-Path { param([String]$P) return "$PWD$($P.Substring(1))" }
function Help {
   "Usage: `
    ./handbrakeTrailers [-Encoding] -Preset <string> -Source <string> -Destination <string> -SourceExt <string> -DestinationExt <string> -Processed <string> [options] `
    ./handbrakeTrailers [-Help]`n `
Options: `
    -Notify         - Send script updates to discord webhook.
                        Example             : 'username','https://discord.com/api/webhooks/yourwebhookhere'
                        Example from file   : 'file','webhookfile.ext' `
    -CheckMovies    - Path to movie folders. Check movie folders for trailers and compare to trailers folder. `
                                                If movie does not have trailer and trailer exists in 'Destination'. `
                                                copy trailer to movie folder.`n `
Example: `
    ./handbrakeTrailers -Preset 'Roku 1080p30' -Source 'G:/Downloads' -Destination 'G:/Videos/Movie Trailers' -SourceExt 'mkv' -DestinationExt 'mp4' -Processed 'G:/Videos/Post-Processed/Movie Trailers' -Notify 'file','.env'`n"
    Exit
}
If ($help) { Help }
# Remove trailing whitespace
$Preset = $Preset.Trim()
$Source = $Source.Trim()
$Destination = $Destination.Trim()
$SourceExt = $SourceExt.Trim()
$DestinationExt = $DestinationExt.Trim()
$Processed = $Processed.Trim()
$skippedFiles = @()
$processedFiles = 0
$movedFiles = 0
If ( $Preset -ieq "" ) { "Preset is empty string.`n`nExitcode : 1" ; Help }
# Verify paths.
If ( $Source -ine "" ) { If ( ! $(Test-Path -LiteralPath $Source) ) { "System cannot find '{0}'.`n`nExitcode : 1" -f $Source ; Help } Else { "Verified 'Source' path." } } Else { "System cannot find '{0}'.`n`nExitcode : 1" -f $Source ; Help }
If ( $Destination -ine "" ) { If ( ! $(Test-Path -LiteralPath $Destination) ) { New-Item -ItemType "Directory" -LiteralPath $Destination -Force } Else { "Verified 'Destination' path." } } ELSE { "System cannot find '{0}'.`n`nExitcode : 1" -f $Destination ; Help }
If ( $Processed -ne "" ) { If ( ! $(Test-Path -LiteralPath $Processed) ) { New-Item -ItemType "Directory" -LiteralPath $Processed -Force } Else { "Verified 'Processed' path.`n" } } Else { "System cannot find '{0}'.`n`nExitcode : 1" -f $Processed ; Help }
# Complete paths.
If ( $(Split-Path -LiteralPath $Source -Parent) -ieq "." ) { "Relative source path detected...Resolving to absolute path..." ; $Source = Complete-Path -P $Source ; "Done." }
If ( $(Split-Path -LiteralPath $Destination -Parent) -ieq "." ) { "Relative destination path detected...Resolving to absolute path..." ; $Destination = Complete-Path -P $Destination ; "Done." }
# Validate extensions input.
If ( $SourceExt -ieq "" -or $DestinationExt -ieq "" ) { "SourceExt '{0}' or DestinationExt '{1}' is empty string.`n`nExitcode : 1" -f $SourceExt, $DestinationExt ; Help }
# Setup Notify if exist.
[Boolean]$sendNote = $false
If ( $Notify.Length -gt 1) {
    ./Add-LogAndPrint.ps1 -Content "Setting up discord webhook..."
    # Truncate Notify to 2 elements.
    $Notify = $Notify[0..1]
    # Complete paths.
    If ( $(Split-Path -LiteralPath $Notify[0] -Parent) -ieq "." ) { "Relative destination path detected...Resolving to absolute path..." ; $Notify[0] = Complete-Path -P $Notify[0] ; "Done." }
    If ( $(Split-Path -LiteralPath $Notify[1] -Parent) -ieq "." ) { "Relative destination path detected...Resolving to absolute path..." ; $Notify[1] = Complete-Path -P $Notify[1] ; "Done." }
    [PSCustomObject]$result = ./Confirm-UserWebHook.ps1 -ArgumentList $Notify
    If ( $result.Verified -eq $true ) {
        $sendNote = $true
        ./Add-LogAndPrint.ps1 -Content "Notify enabled.`nFound: 'username'`nFound: 'webhookUri'"
        $response = ./Send-Message.ps1 -Content "handbrake.ps1 started encoding." -Username $result.Username -Webhookuri $result.Webhookuri
        # Print and log error if encountered.
        If ( $response -ilike "*Error*" ) { ./Add-LogAndPrint.ps1 -Content $response }
    } Else {
        $temp1, $temp2 = '',''
        If ( $result.Username -ieq "" ) { $temp1 = "`n'username' not found." }
        If ( $result.Webhookuri -ieq "" ) { $temp2 = "`n'webhookUri' not found." }
        ./Add-LogAndPrint.ps1 -Content $("Notify not enabled.{0}{1}" -f $temp1, $temp2)
    }
}
# Create folder in destination, encode file and move file to 'Processed'.
ForEach ($file In $(Get-ChildItem -LiteralPath $Source)) {
    $newDestFolder = $($file.FullName -replace "\.$SourceExt","").Replace($Source, $Destination)
    $in = $file.FullName
    $out = "$newDestFolder\$($file.Name.Replace($SourceExt,$DestinationExt))"
    $move = "$Processed\$(Split-Path -LiteralPath $in -Leaf)"
    # Create new folder in destination if not existing
    If ( ! $(Test-Path -LiteralPath $newDestFolder) ) { New-Item -ItemType "Directory" -LiteralPath $newDestFolder -Force } Else { $skippedFiles+=$(Split-Path -LiteralPath $in -Leaf) ; return }
    Try { HandBrakeCLI --preset-import-gui -Z "$Preset" -i "$in" -o "$out" } Catch { "Error using handbrakecli:`n  {0}`n`nin  : '{1}'`nout : '{2}'`n" -f $_.Exception.Message, $in, $out ; $skippedFiles+=$(Split-Path -LiteralPath $in -Leaf) ; return }
    $processedFiles+=1
    Try { Move-Item -LiteralPath $in -Destination $move } Catch { "Error moving '{0}'." -f $in ; return }
    $movedFiles+=1
}
# Print results.
If ( $skippedFiles.Length -gt 0 ) { "`n`n" ; ForEach ( $_ In $skippedFiles ) { "{0}" -f $_ } }
"handbrakeTrailers Finished.`n{0}'s Processed : '{1}'`n{2}'s Moved     : '{3}'`n{4}'s Skipped   : '{5}'" -f $SourceExt, $processedFiles, $SourceExt, $movedFiles, $SourceExt, $skippedFiles.Count
# Send update to discord.
If ($sendNote) {
    ./Send-Message.ps1 -Content $("handbrakeTrailers Finished.`n{0}'s Processed : '{1}'`n{2}'s Moved     : '{3}'`n{4}'s Skipped   : '{5}'" -f $SourceExt, $processedFiles, $SourceExt, $movedFiles, $SourceExt, $skippedFiles.Count) -Username $result.Username -Webhookuri $result.Webhookuri
}
# CheckMovies
If ( $CheckMovies -ine "" ) { ./Copy-Trailer $Destination $CheckMovies -w ; "`nDone running 'Copy-Trailer.ps1'"}
