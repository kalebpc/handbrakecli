# handbrake.ps1 © 2025 https://github.com/kalebpc/handbrakecli

[Boolean]$notifying = $true
[Boolean]$shows = $true
[String]$preset1 = "1080p30 mp4"
# [String]$source = "D:\MKV Videos"
[String]$source = "D:\MKV Shows"
# [String]$destination = "G:\Jellyfin\Movies"
[String]$destination = "G:\Jellyfin\Shows"
[String]$sourceExt = "mkv"
[String]$destinationExt = "mp4"
[String]$ready = "Ready.txt"
[String]$processed = "G:\Temp-PostProcessed"
[String[]]$notify = "file","../.env"
If ($notifying) {
    If ($shows) {
        Start-Process -FilePath "powershell" -ArgumentList @("/c", "`$host.ui.RawUI.WindowTitle = 'handbrake.ps1' ; ./handbrake.ps1 -Preset1 '$preset1' -Source '$source' -Shows -Destination '$destination' -SourceExt '$sourceExt' -DestinationExt '$destinationExt' -Ready '$ready' -Processed '$processed' -Notify $($notify[0]),$($notify[1])")
    } Else {
        Start-Process -FilePath "powershell" -ArgumentList @("/c", "`$host.ui.RawUI.WindowTitle = 'handbrake.ps1' ; ./handbrake.ps1 -Preset1 '$preset1' -Source '$source' -Destination '$destination' -SourceExt '$sourceExt' -DestinationExt '$destinationExt' -Ready '$ready' -Processed '$processed' -Notify $($notify[0]),$($notify[1])")
    }
} Else {
    If ($shows) {
        Start-Process -FilePath "powershell" -ArgumentList @("/c", "`$host.ui.RawUI.WindowTitle = 'handbrake.ps1' ; ./handbrake.ps1 -Preset1 '$preset1' -Source '$source' -Shows -Destination '$destination' -SourceExt '$sourceExt' -DestinationExt '$destinationExt' -Ready '$ready' -Processed '$processed'")
    } Else {
        Start-Process -FilePath "powershell" -ArgumentList @("/c", "`$host.ui.RawUI.WindowTitle = 'handbrake.ps1' ; ./handbrake.ps1 -Preset1 '$preset1' -Source '$source' -Destination '$destination' -SourceExt '$sourceExt' -DestinationExt '$destinationExt' -Ready '$ready' -Processed '$processed'")
    }
}
