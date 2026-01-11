# handbrake.ps1 © 2025 https://github.com/kalebpc/handbrakecli

[Boolean]$notifying = $true
[String]$preset1 = "1080p30 mp4"
[String]$source = "E:\MKV Videos"
[String]$destination = "G:\Jellyfin\Movies"
[String]$sourceExt = "mkv"
[String]$destinationExt = "mp4"
[String]$ready = "Ready.txt"
[String]$processed = "G:\Temp-PostProcessed"
[String[]]$notify = "file",".env"
If ($notifying) {
    Start-Process -FilePath "powershell" -ArgumentList @("/c", "`$host.ui.RawUI.WindowTitle = 'handbrake.ps1' ; ./handbrake.ps1 -Preset1 '$preset1' -Source '$source' -Destination '$destination' -SourceExt '$sourceExt' -DestinationExt '$destinationExt' -Ready '$ready' -Processed '$processed' -Notify $($notify[0]),$($notify[1])")
} Else {
    Start-Process -FilePath "powershell" -ArgumentList @("/c", "`$host.ui.RawUI.WindowTitle = 'handbrake.ps1' ; ./handbrake.ps1 -Preset1 '$preset1' -Source '$source' -Destination '$destination' -SourceExt '$sourceExt' -DestinationExt '$destinationExt' -Ready '$ready' -Processed '$processed'")
}
