# handbrake.ps1 © 2025 https://github.com/kalebpc/handbrakecli
[String]$preset1 = "Roku 480p30 Modded"
[String]$preset2 = "Roku 480p30"
[String]$source = "G:\Videos\MKV Videos"
[String]$destination = "G:\Videos\Jellyfin\Movies"
[String]$sourceExt = "mkv"
[String]$destinationExt = "mp4"
[String]$ready = "Ready.txt"
[String]$processed = [String]::Concat($(Split-Path -Path $source -Qualifier), "/Temp-PostProcessed")
Start-Process -FilePath "powershell" -ArgumentList @("/c", "`$host.ui.RawUI.WindowTitle = 'handbrake.ps1' ; ./handbrake.ps1 -Encoding -Preset1 '$preset1' -Preset2 '$preset2' -Source '$source' -Destination '$destination' -SourceExt '$sourceExt' -DestinationExt '$destinationExt' -Ready '$ready' -Processed '$processed' -CheckDirectorySilent")
