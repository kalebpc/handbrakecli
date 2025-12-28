
<#PSScriptInfo

.VERSION 1.0

.GUID 9f47b056-f91d-40bd-9cb8-ea418f5ce02e

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
    Check storage folders and files against known correct values using regex. 

.PARAMETER Recurse
    Recursive file validation.

.PARAMETER PrintValid
    Make script print valid file names along with the invalid ones.

.PARAMETER ValidNames
    List of names to add to accepted name lists.

.EXAMPLE
    ./Jellyfin-ValidateStorage.ps1 -LiteralPath 'G:\Jellyfin\' -Recurse

.EXAMPLE
    ./Jellyfin-ValidateStorage.ps1 -LiteralPath 'G:\Jellyfin\' -Recurse -ValidNames "Name","Another Name"

.EXAMPLE
    ./Jellyfin-ValidateStorage.ps1 -LiteralPath 'G:\Jellyfin\' -PrintValid

.EXAMPLE
    "C:\Users\kaleb\Desktop\Jellyfin" | .\Jellyfin-ValidateStorage.ps1 -ValidNames $(Get-Content -literalpath "./validnames.txt") -Recurse

.EXAMPLE
    "C:\Users\kaleb\Desktop\Jellyfin" | .\Jellyfin-ValidateStorage.ps1 -PrintValid

#> 


[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [String]$LiteralPath,
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Switch]$Recurse,
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Switch]$PrintValid,
    [Parameter(ValueFromPipelineByPropertyName = $true, Helpmessage = "List of names to add to accepted name lists.")]
    [String[]]$ValidNames
)

If ( ! $(Test-Path -LiteralPath $LiteralPath) ) { "System can not find '{0}'" -f $LiteralPath ; Exit }

[String[]]$libraryFolderNames = @(
    "Movies",
    "Music",
    "Shows",
    "Books",
    "Home Videos and Photos",
    "Music Videos",
    "Mixed Movies and Shows",
    "Radio",
    "Live TV",
    "behind the scenes",
    "deleted scenes"
    "interviews",
    "scenes",
    "samples",
    "shorts",
    "featurettes",
    "clips",
    "other",
    "extras",
    "trailers",
    "Movie Trailers",
    "Videos and Photos"
)

If ( $ValidNames.Count -gt 0 ) {
    ForEach ( $x In $ValidNames ) {
        $libraryFolderNames+=$x.Trim()
    }
}

function Validate-Folder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [System.IO.DirectoryInfo]$Foldr
    )
    [Boolean]$output = $false
    [String[]]$idTypes = @("imdbid","tmdbid","tvdbid")
    [Boolean]$idtype = $false
    ForEach ( $id In $idTypes ) {
        If ( $Foldr -imatch $id ) { $idType = $true }
    }
    If ($idType) {
        # Validate with ids.
        If ( $Foldr.Name -match "^[^\s].*\s\((?!\s)\d{4}\)\s\[imdbid\-[t]{2}\d{7,24}\]$" -or $Foldr.Name -match "^[^\s].*\s\((?!\s).{0,24}\s(?!\s)\d{4}\)\s\[imdbid\-[t]{2}\d{7,24}\]$" -or $Foldr.Name -match "^[^\s].*\s\((?!\s).{0,24}\s(?!\s)\d{4}\-(?!\d)?\d{0,4}\)\s\[imdbid\-[t]{2}\d{7,24}\]$" ) {
            If ($PrintValid) {
                "Valid Folder Name             : {0}" -f $Foldr.FullName
            }
        } Else {
            "Invalid Folder Name           : {0}" -f $Foldr.FullName
        }
    } Else {
        # Validate without ids.
        If ( $Foldr.Name -match "^[^\s].*\s\((?!\s)\d{4}\)$" -or $Foldr.Name -match "^[^\s].*\s\((?!\s).{0,24}\s(?!\s)\d{4}\)$" -or $Foldr.Name -match "^[^\s].*\s\((?!\s).{0,24}\s(?!\s)\d{4}\-(?!\d)?\d{0,4}\)$" ) {
            If ($PrintValid) {
                "Valid Folder Name             : {0}" -f $Foldr.FullName
            }
        } ElseIf ( $Foldr.Name -inotin $libraryFolderNames -and $Foldr.Name -inotmatch "season" ) {
            "Invalid Folder Name           : {0}" -f $Foldr.FullName
        } ElseIf ($PrintValid) {
            "Valid Folder Name             : {0}" -f $Foldr.FullName
        }
    }
}

[String[]]$libraryFileNames = @(
    "logo",
    "poster",
    "thumb",
    "folder",
    "backdrop"
)

If ( $ValidNames.Count -gt 0 ) {
    ForEach ( $x In $ValidNames ) {
        $libraryFileNames+=$x.Trim()
    }
}

function Validate-File {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [System.IO.FileInfo]$Foldr
    )
    [Boolean]$output = $false
    [String[]]$idTypes = @("imdbid","tmdbid","tvdbid")
    [Boolean]$idtype = $false
    ForEach ( $id In $idTypes ) {
        If ( $Foldr -imatch $id ) { $idType = $true }
    }
    If ($idType) {
        # Validate with ids.
        If ( $Foldr.Name -match "^[^\ ].*\ \((?!\ )\d{4}\)\ \[imdbid\-[t]{2}\d{7,24}\].*\..+$" -or $Foldr.Name -match "^[^\ ].*\ \((?!\ ).{0,24}\s(?!\ )\d{4}\)\ \[imdbid\-[t]{2}\d{7,24}\].*\..+$" -or $Foldr.Name -match "^[^\ ].*\ \((?!\ ).{0,24}\ (?!\ )\d{4}\-(?!\d)?\d{0,4}\)\ \[imdbid\-[t]{2}\d{7,24}\].*\..+$" ) {
            If ($PrintValid) {
                "Valid  File  Name             : {0}" -f $Foldr.FullName
            }
        } Else {
            "Invalid File Name             : {0}" -f $Foldr.FullName
        }
    } Else {
        # Validate without ids.
        If ( $($Foldr.Name -replace "(\b\.\b)(?!.*\1).*$","") -iin $libraryFileNames -or $Foldr.Name -match "^[^\s].*\s\((?!\s)\d{4}\).*\..+$" -or $Foldr.Name -match "^[^\s].*\s\((?!\s).{0,24}\s(?!\s)\d{4}\).*\..+$" -or $Foldr.Name -match "^[^\s].*\s\((?!\s).{0,24}\s(?!\s)\d{4}\-(?!\d)?\d{0,4}\).*\..+$" ) {
            If ($PrintValid) {
                "Valid  File  Name             : {0}" -f $Foldr.FullName
            }
        } Else {
            "Invalid File Name             : {0}" -f $Foldr.FullName
        }
    }
}

If ($Recurse) {
    $folders = Get-ChildItem -LiteralPath $LiteralPath -Recurse
    ForEach ( $folder In $folders ) {
        If ($folder.PSIsContainer) {
            Validate-Folder $folder
        } Else {
            Validate-File $folder
        }
    }
} Else {
    $folders = Get-ChildItem -LiteralPath $LiteralPath
    ForEach ( $folder In $folders ) {
        If ($folder.PSIsContainer) {
            Validate-Folder $folder
        } Else {
            Validate-File $folder
        }
    }
}
