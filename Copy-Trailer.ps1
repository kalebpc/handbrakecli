
<#PSScriptInfo

.VERSION 1.0

.GUID 48ff3ce6-9d5e-4a12-bbf4-9dc99edb6a01

.AUTHOR https://github.com/kalebpc

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

    Check inside 'Destination' for movie that matches a folder inside 'Source'; If match is found and no trailer exists, copy the trailer to the movie folder renaming to 'trailer'.

.PARAMETER Source

    <string>
    Path to directory holding movie trailers folders.

.PARAMETER Destination

    <string>
    Path to directory holding movie folders.

.PARAMETER Move

    <switch>
    Path to directory holding movie folders.

.PARAMETER Copy

    <switch>
    Path to directory holding movie folders.

.PARAMETER WhatIf

    <switch>
    Path to directory holding movie folders.

.EXAMPLE

    ./Copy-Trailers -Source 'G:\Movie Trailers' -Destination 'G:\Movies'

#> 


[CmdletBinding(DefaultParameterSetName = "Copy")]
Param(
    [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "Move", HelpMessage = "Path to directory holding movie trailers folders.")]
    [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "Copy", HelpMessage = "Path to directory holding movie trailers folders.")]
    [String]$Source,
    [Parameter(Position = 1, Mandatory = $true, ParameterSetName = "Move", HelpMessage = "Path to directory holding movie folders.")]
    [Parameter(Position = 1, Mandatory = $true, ParameterSetName = "Copy", HelpMessage = "Path to directory holding movie folders.")]
    [String]$Destination,
    [Parameter(ParameterSetName = "Copy", HelpMessage = "Copy trailer to corresponding movie folder.")]
    [Switch]$Copy = $true,
    [Parameter(ParameterSetName = "Move", HelpMessage = "Move trailer to corresponding movie folder and delete from movie trailers.")]
    [Switch]$Move,
    [Parameter(ParameterSetName = "Move", HelpMessage = "List trailers that would be moved or copied.")]
    [Parameter(ParameterSetName = "Copy", HelpMessage = "List trailers that would be moved or copied.")]
    [Switch]$WhatIf
)

If ( $Source -ine "" -and $Destination -ine "" ) {
    If ( ! $(Test-Path -Path $Source ) ) { "System could not find '0'." -f $Source ; Exit }
    If ( ! $(Test-Path -Path $Destination ) ) { "System could not find '0'." -f $Destination ; Exit }
    # Complete paths.
    function Complete-Path { param([String]$P) return "$PWD$($P.Substring(1))" }
    If ( $(Split-Path -Path $Source -Parent) -ieq "." ) { "Relative source path detected...Resolving to absolute path..." ; $Source = Complete-Path -P $Source ; "Done." }
    If ( $(Split-Path -Path $Destination -Parent) -ieq "." ) { "Relative destination path detected...Resolving to absolute path..." ; $Destination = Complete-Path -P $Destination ; "Done." }
}
# Return list of movies that dont have trailers but there is a matching trailer in movie trailers folder.
function Get-FolderMatches {
    [System.IO.DirectoryInfo[]]$list = @()
    ForEach ( $folder In $( Get-ChildItem -Path $Destination -Recurse) ) {
        If ( $folder.PSIsContainer -and $folder.FullName -match "[0-9]{4}\)$") {
            $count = 0
            ForEach ( $_ In $(Get-ChildItem -Path $folder.FullName) ) {
                If ( $_.FullName -imatch ".*trailer.*" ) { $count+=1 }
            }
            If ( $count -eq 0 ) {
                If ( Test-Path -Path $($folder.FullName.Replace($Destination,$Source)) ) {
                    $list+=$folder
                }
            }
        }
    }
    return $list
}
function Set-PathDest {
    [CmdletBinding()]
    param(
        [System.IO.DirectoryInfo]$Folder
    )
    $p = $(Get-ChildItem -Path $Folder.FullName.Replace($Destination,$Source)).FullName
    return $p, $($Folder.FullName + "\trailer" + $($(Split-Path -Path $p -Leaf) -replace '.*\.','.'))
}
If ($WhatIf -or $($Copy -eq $false -and $Move -eq $false)) {
    # List missing trailers that would be moved/copied to movie folders.
    $list = Get-FolderMatches
    If ( $list.Length -gt 0 ) {
        ForEach ( $folder In $list ) {
            # $path, $dest = Set-PathDest -Folder $folder
            If ($Move) {
                # Print move and delete actions.
                "Move-Item`n -Path`n $path`n -Destination`n $dest"
                "Remove-Item`n -Path`n $(Split-Path -Path $path -Parent)`n -Force -Recurse -ErrorAction SilentlyContinue`n"
            } Else {
                # Print copy action.
                "Copy-Item`n -Path`n $path`n -Destination`n $dest`n"
            }
        }
    }
} ElseIf ($Move) {
    # Move missing trailers to movie folders and delete trailer folder from 'movie trailers'.
    $list = Get-FolderMatches
    If ( $list.Length -gt 0 ) {
        ForEach ( $folder In $list ) {
            # Move trailers to movie folders and delete folders from 'movie trailers'.
            $path, $dest = Set-PathDest -Folder $folder
            Move-Item -Path $path -Destination $dest
            Remove-Item -Path $(Split-Path -Path $path -Parent) -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
} Else {
    # Copy missing trailers to movie folders.
    $list = Get-FolderMatches
    If ( $list.Length -gt 0 ) {
        ForEach ( $folder In $list ) {
            # Copy trailers to movie folders.
            $path, $dest = Set-PathDest -Folder $folder
            Copy-Item -Path $path -Destination $dest
        }
    }
}
