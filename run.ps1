# handbrake.ps1 © 2025 https://github.com/kalebpc/handbrakecli
[String]$in = "G:\Videos\MKV Videos"
[String]$out = "G:\Videos\Jellyfin\Movies"
[Int32]$pause = 5
Start-Process -FilePath "powershell" -ArgumentList @("/c","`$host.ui.RawUI.WindowTitle = 'handbrake.ps1' ; ./handbrake.ps1 '$in' '$out' $pause")
