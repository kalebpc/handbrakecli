
<#

    Rename files and subfolder files of movie folders to same as movie folder name.

    Example :
        ./Rename-Files.ps1 -Folders $(Get-ChildItem -LiteralPath 'G:\Movies' -Include "*imdbid*")

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "List of 'DirectoryInfo' objects.")]
    [System.IO.DirectoryInfo[]]$Folders
)
ForEach ( $folder In $Folders ) {
    ForEach ( $file In $(Get-ChildItem -LiteralPath $folder.FullName -Depth 0 -Exclude "*imdbid*") ) {
        $temp = $($folder.Name -replace "\(.*$","").Trim()
        If ( ! $file.PSIsContainer ) {
            If ( $file.Name -inotlike "$temp*" -or $file.Name -inotmatch "\[imdbid\-") {
                # Rename main folder files.
                If ( $($file.Name -replace ".*\)","") -imatch "trailer\." ) {
                    $newname = "{0} - {1}" -f $folder.Name, $($file.Name -replace ".*\)","")
                } ElseIf ( $($file.Name -replace ".*\)","") -match "^\s" ) {
                    $newname = "{0} -{1}" -f $folder.Name, $($file.Name -replace ".*\)","")
                } Else {
                    $newname = "{0}{1}" -f $folder.Name, $($file.Name -replace ".*\)","")
                }
                # "`nRename-Item`n -LiteralPath`n {0}`n -NewName`n {1}" -f $file.FullName, $newname
                Rename-Item -LiteralPath $file.FullName -NewName $newname
            }
        }
        If ($file.PSIsContainer) {
            # Rename subfolder(s) files.
            ForEach ( $fil In $(Get-ChildItem -LiteralPath $file.FullName -Depth 0 -Exclude "*imdbid*") ) {
                If ( $fil.Name -inotlike "$temp*"  -or $fil.Name -inotmatch "\[imdbid\-") {
                    If ( $fil.Name -match ".*\-" ) {
                        $newnam = "{0} - {1}" -f $folder.Name, $($fil.Name -replace ".*\-","")
                    } ElseIf ( $($fil.Name -replace ".*\)","") -match "^\s" ) {
                        $newname = "{0} -{1}" -f $folder.Name, $($fil.Name -replace ".*\)","")
                    } Else {
                        $newnam = "{0} - {1}" -f $folder.Name, $fil.Name
                    }
                    # "`nRename-Item`n -LiteralPath`n {0}`n -NewName`n {1}" -f $fil.FullName, $newnam
                    Rename-Item -LiteralPath $fil.FullName -NewName $newnam
                }
            }
        }
    }
    # # Check for wrong file names.
    # ForEach ( $file In $(Get-ChildItem -LiteralPath $folder.FullName -Depth 1) ) {
    #     $temp = $($folder.Name -replace "\(.*$","").Trim()
    #     If ( $file.Name -inotlike "$temp*" -and $file.PSIsContainer -eq $false ) {
    #         "Error:`nFolder : {0}`nFile   : {1}" -f $folder.Name, $file.FullName
    #     }
    # }
}
