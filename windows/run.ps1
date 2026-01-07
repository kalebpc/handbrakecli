# handbrake.ps1 © 2025 https://github.com/kalebpc/handbrakecli

[Boolean]$notifying = $true
[String]$preset1 = "Creator 1080p30 webm"
[String]$preset2 = "Roku 480p30 Modded 20rf"
# [String]$source = "F:\MKV Videos"
[String]$source = "C:\Users\kaleb\Downloads"
[String]$destination = "G:\Jellyfin\Movies"
[String]$sourceExt = "mkv"
[String]$destinationExt = "mp4"
[String]$ready = "Ready.txt"
[String]$processed = "G:\Temp-PostProcessed"
[String[]]$notify = "file",".env"
If ($notifying) {
    Start-Process -FilePath "powershell" -ArgumentList @("/c", "`$host.ui.RawUI.WindowTitle = 'handbrake.ps1' ; ./handbrake.ps1 -Preset1 '$preset1' -Preset2 '$preset2' -Source '$source' -Destination '$destination' -SourceExt '$sourceExt' -DestinationExt '$destinationExt' -Ready '$ready' -Processed '$processed' -Notify $($notify[0]),$($notify[1])")
} Else {
    Start-Process -FilePath "powershell" -ArgumentList @("/c", "`$host.ui.RawUI.WindowTitle = 'handbrake.ps1' ; ./handbrake.ps1 -Preset1 '$preset1' -Preset2 '$preset2' -Source '$source' -Destination '$destination' -SourceExt '$sourceExt' -DestinationExt '$destinationExt' -Ready '$ready' -Processed '$processed'")
}
