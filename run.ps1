# handbrake.ps1 © 2025 https://github.com/kalebpc/handbrakecli
[String]$in = "G:\Videos\MKV Videos"
[String]$out = "G:\Videos\Jellyfin\Movies"
[String]$preset = "Roku 480p30 Modded"
Start-Process -FilePath "powershell" -ArgumentList @("/c","`$host.ui.RawUI.WindowTitle = 'handbrake.ps1' ; ./handbrake.ps1 -Preset '$preset' -Encoding -Source '$in' -Destination '$out'")
