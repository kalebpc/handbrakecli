# handbrake.ps1 © 2025 https://github.com/kalebpc/handbrakecli
$in = "G:\Videos\MKV Videos"
$out = "G:\Videos\Jellyfin\Movies"
Start-Process -FilePath "powershell" -ArgumentList @("/c","`$host.ui.RawUI.WindowTitle = 'handbrake.ps1' ; ./handbrake.ps1 '$in' '$out'")
