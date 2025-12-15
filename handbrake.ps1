# handbrake.ps1 © 2025 https://github.com/kalebpc/handbrakecli
# 'Roku 480p30 Modded' preset.
# This code will recursively copy directories, re-encode source files to destination then move source directory to temp/trash/backup folder.
# ./handbrake [path2SourceFolder] [path2DestinationFolder.*]
function Help { "usage:`n       ./handbrake [path2SourceFolder] [path2DestinationFolder]`n" ; Return }
function Exiting {
    [CmdletBinding()]
    param(
        [String]$Reason,
        [Int32]$Exitcode
    )
    Switch ($Exitcode) {
        0 { "`nFinished Successfully.`n`nExit 0" ; Exit }
        1 { "`n{0}`n" -f $Reason ; Help ; "`nExit {0}" -f $Exitcode ; Exit }
        Default { Exit }
    }
}
# Exit if no paths in args.
If ( $args.Length -lt 1 ) { Exiting -Reason "No file paths given." -Exitcode 1 }
$sourceFilePath, $destinationFilePath = $args[0], $args[1]
# Verify paths.
If ( ! $(Test-Path -Path $sourceFilePath) ) { Exiting -Reason "System cannot find '$sourceFilePath'." -Exitcode 1 } Else { "Verified source path." }
If ( ! $(Test-Path -Path $destinationFilePath) ) { Exiting -Reason "System cannot find '$destinationFilePath'." -Exitcode 1 } Else { "Verified destination path." }
function Complete-Path {
    [CmdletBinding()]
    param(
        [String]$P
    )
    return "$PWD$($P.Substring(1))"
}
If ( $(Split-Path -Path $sourceFilePath -Parent) -ieq "." ) { 
    "Relative source path detected...Resolving to absolute path..." ; $sourceFilePath = Complete-Path -P $sourceFilePath ; "Done."
}
If ( $(Split-Path -Path $destinationFilePath -Parent) -ieq "." ) { 
    "Relative destination path detected...Resolving to absolute path..." ; $destinationFilePath = Complete-Path -P $destinationFilePath ; "Done."
}
$logPath = "$ENV:USERPROFILE/AppData/Local/Programs/handbrake/logs"
If ( ! $(Test-Path -Path $logPath) ) { New-Item -ItemType "Directory" -Path $logPath -Force }
$processedPath = "$(Split-Path -Path $sourceFilePath -Qualifier)/Temp-PostProcessed"
If ( ! $(Test-Path -Path $processedPath) ) { New-Item -ItemType "Directory" -Path $processedPath -Force }
$readyFile = "Readyy.txt"
$threads = 4
$pause = 5
$logFile = "$logPath/robocopyProcess.log"
function Get-ReadyDirectory {
    [String[]]$readyDirectories = Get-ChildItem -Path $sourceFilePath -Recurse -Include $readyFile | Split-Path -Parent
    ForEach ( $directory In $readyDirectories ) {
        $readyDirectory = Split-Path -Path $directory -Leaf
        "Copying directory tree for '{0}'..." -f $directory
        Robocopy "$directory" "$destinationFilePath`\$readyDirectory" /mt:$($threads) /e /z /xf "*.*" /xx /unilog+:$logFile
        # Find mkv files.
        ForEach ( $sfp In $(Get-ChildItem -Path "$directory" -Recurse -Include "*.mkv") ) {
            $in = $sfp.FullName
            $out = $($sfp.FullName).Replace($sourceFilePath,$destinationFilePath)
            "Encoding:`nin  : {0}`nout : {1}`n" -f $in, $out
            Add-Content -Path "$logFile" -Value "`n------------`nEncoding:`nin: '$in'`nout: '$out'.`n------------`n"
            # Encode files
            HandBrakeCLI --preset-import-gui -Z "Roku 480p30 Modded" -i "$in" -o "$out"
        }
        # Move processed folder to Temp-PostProcessed.
        Move-Item -Path "$directory" -Destination "$processedPath"
        "Moved '{0}' to '{1}'." -f $directory, $processedPath
        Add-Content -Path "$logFile" -Value "`n------------`nMoved '$directory' to '$processedPath'.`n------------`n"
        "Paused for {0} mins to allow graceful exit." -f $pause
        Add-Content -Path "$logFile" -Value "`n------------`nPaused for $pause mins to allow graceful exit.`n------------`n"
        Start-Sleep -Seconds ($pause * 60)
    }
}
$minutes = 1
# Time to wait in between running a check on source directory.
While ($true) { Get-ReadyDirectory ; Start-Sleep -Seconds ($minutes * 60) }
