<#
    Rename 'Folders' with names found in 'NewNames' list.

    Example :
        ./Rename-Folders -Folders $(Get-ChildItem -Path "G:\Movies" -Exclude "*imdbid*") -NewNames $(Get-ChildItem -Path "G:\Movies updated")

    Example :
        ./Rename-Folders -Folders $(Get-ChildItem -Path "G:\Movies" -Exclude "*imdbid*") -NewNames $(Get-Content -Path "G:\fileWithUpdatedNames.txt")
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to folders.")]
    [String[]]$Folders,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "List with updated folder names.")]
    [String[]]$NewNames
)
[Int64]$folderCount = $Folders.Count
[Int64]$count = 0
ForEach ( $folder In $Folders ) {
    $title = $($(Split-Path -Path $folder -Leaf) -replace "\(.*$","").Trim()
    "$folder"
    ForEach ( $name In $NewNames ) {
        If ( $name -ilike "*$title*" ) {
            If ( ! $(Test-Path -Path "$(Split-Path -Path $folder -Parent)\$name" ) ) {
                Rename-Item -Path "$folder" -NewName "$name"
                $count+=1
            }
        }
    }
}
"`nTotal folders     : '{0}'`nProcessed folders : '{1}'" -f $folderCount, $count
