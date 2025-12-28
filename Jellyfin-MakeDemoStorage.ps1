
<#PSScriptInfo

.VERSION 1.0

.GUID 68ab8547-8af4-4d5d-8003-c3eaf34185a6

.AUTHOR https://github.com/kalebpc/handbrakecli

.COMPANYNAME 

.COPYRIGHT 2025 https://github.com/kalebpc/handbrakecli

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
    Build small mock storage structure to reference when starting Jellyfin server setup. 

#> 

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [String]$LiteralPath
)

$root = "{0}\Jellyfin" -f $LiteralPath

If ( ! $(Test-Path -LiteralPath $root) ) { New-Item -Path $root -ItemType "Directory" -Force }

function New-File {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Folder,
        [Parameter(Mandatory = $true)]
        [String[]]$List
    )
    ForEach ( $listitem In $List ) {
        $tmp = "{0}{1}{2}" -f $root, $Folder, $listitem
        If (! $(Test-Path -LiteralPath $tmp) ) { New-Item -Path $tmp -ItemType "File" -Force }
    }
}

# Movies https://jellyfin.org/docs/general/server/media/movies/
$ext = ".mp4"
$temp = "\Movies"
$title = "\Movie Title (YEAR) [imdbid-ID_HERE]"
$foldr = "{0}{1}{2}" -f $temp, $title, $title
New-File -Folder $foldr -List $ext, $(" - trailer{0}" -f $ext)

$title = "\Another Movie Title (YEAR) [imdbid-ID_HERE]"
New-File -Folder $("{0}{1}{2}" -f $temp, $title, $title) -List $ext

New-File -Folder $("{0}{1}\trailers{2}" -f $temp, $title, $title) -List $(" - trailer{0}" -f $ext)

New-File -Folder $("{0}{1}\extras{2}" -f $temp, $title, $title) -List $(" - extra{0}" -f $ext)

# Music Videos https://jellyfin.org/docs/general/server/media/music-videos/
$temp = "\Music Videos"
$title = "\Artist\Album\Title"
New-File -Folder $("{0}{1}" -f $temp, $title) -List $ext

# Radio 
$temp = "\Radio"
$title = "iHeart Christmas"
$foldr = "{0}\{1}\" -f $temp, $title
$ext = ".strm"
New-File -Folder $("{0}{1}" -f $foldr, $title) -List $ext

New-File -Folder $foldr -List "poster.jpg","logo.jpg","thumb.jpg"

$url = "https://n18b-e2.revma.ihrhls.com/..."
Set-Content -Path $("{0}{1}{2}{3}" -f $root, $foldr, $title, $ext) -Value $url -Force

# Shows https://jellyfin.org/docs/general/server/media/shows/
$temp = "\Shows"
$title = "\The Rookie (TV Series 2018-) [imdbid-tt7587890]"
$ext = ".mp4"
New-File -Folder $("{0}{1}\Season 01{2}" -f $temp, $title, $title) -List $(" - S01E01{0}" -f $ext),$(" - S01E02{0}" -f $ext),$(" - S01E03{0}" -f $ext)
New-File -Folder $("{0}{1}\Season 02{2}" -f $temp, $title, $title) -List $(" - S02E01{0}" -f $ext),$(" - S02E02{0}" -f $ext),$(" - S02E03{0}" -f $ext)
