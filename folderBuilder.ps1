
<#PSScriptInfo

.VERSION 1.0

.GUID fece1cf4-e15e-4684-82e4-02da2f25f3db

.AUTHOR https://github.com/kalebpc

.COMPANYNAME 

.COPYRIGHT 2025 https://github.com/kalebpc/handbrakecli

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES None

.REQUIREDSCRIPTS None

.EXTERNALSCRIPTDEPENDENCIES None

.RELEASENOTES


#>

<# 

.SYNOPSIS
    Move and rename files into new folders based on file names. Rename files in subdirectories to same as subdirectory.
.DESCRIPTION 
    Get files inside Source path, trailing characters after '(YEAR)', make new folder with new file name, move and rename file into new folder.
    
    Without using '-Rename':
    Example Expected file names     :   Movie Name Here (2005).ext
                                        Movie Name Here (2009) - trailer.ext
                                        Movie Name Here (2010)-extras.ext

    Example Expected output         :   Movie Name Here (2005)
                                            Movie Name Here (2005).ext

                                        Movie Name Here (2009)
                                            Movie Name Here (2009).ext
                                        
                                        Movie Name Here (2010)
                                            Movie Name Here (2010).ext
    Using '-Rename':
    Example Expected file names     :   Movie Name Here (2001)
                                            something here.ext
                                            and here as well.ext

                                        Movie Name Here (2009)
                                            another name here (500).ext
                                        
                                        Movie Name Here (2010)
                                            likewise here - trailer.ext

    Example Expected output         :   Movie Name Here (2001)
                                            Movie Name Here (2001)(2).ext
                                            Movie Name Here (2001).ext

                                        Movie Name Here (2009)
                                            Movie Name Here (2009).ext
                                        
                                        Movie Name Here (2010)
                                            Movie Name Here (2010).ext
        
.PARAMETER Path
    Enter path to movie trailers.

.PARAMETER Rename
    Flag to rename file inside folder to same as directory.

.INPUTS
    NONE

.OUTPUTS
    NONE

.EXAMPLE
./folderBuilder -Path 'G:\Videos\Movies'
Starting Directory tree :       G:\Videos\Movies
                                    movie (2005) - trailer.mp4
                                    movie (2005).mp4
                                    Movie Name (2008).ext
Ending Directory tree   :       G:\Videos\Movies
                                    movie (2005)
                                        movie (2005)(2).mp4
                                        movie (2005).mp4
                                
                                    Movie Name (2008)
                                        Movie Name (2008).ext

.EXAMPLE
./folderBuilder -Path 'G:\Videos\Movies' -Rename
Starting Directory tree :       G:\Videos\Movies
                                    movienamehere(4000).txt
                                
                                    movie (2005)
                                        movie name(5000).mp4
                                        text here.mp4
                                
                                    Movie Name (2008)
                                        other name here (1999).ext
Ending Directory tree   :   G:\Videos\Movies
                                    movienamehere(4000).txt
                                
                                    movie (2005)
                                        movie (2005) (2).mp4
                                        movie (2005).mp4
                                
                                    Movie Name (2008)
                                        Movie Name (2008).ext

#>


[CmdletBinding()]
param(
    [Parameter(ParameterSetName = "Help")]
    [Switch]$Help,
    [Parameter(Mandatory = $true, ParameterSetName = "Path", HelpMessage = "Enter path to folder with files.")]
    [String]$Path,
    [Parameter(ParameterSetName = "Path", HelpMessage = "Flag to rename file inside directory to same as directory.")]
    [Switch]$Rename
)
function Help {
   "Usage: `
    ./folderBuilder -Path [options] `
    ./folderBuilder -Help`n `
Options: `
    -Rename             - Rename file inside directory to same as directory.`n `
Examples: `
    ./folderBuilder -Path 'G:\Videos\Movies' `
        Starting Directory tree :   G:\Videos\Movies `
                                        movie (2005) - trailer.mp4 `
                                        movie (2005).mp4 `
                                        Movie Name (2008).ext `
        Ending Directory tree   :   G:\Videos\Movies `
                                        movie (2005) `
                                            movie (2005)(2).mp4 `
                                            movie (2005).mp4`n `
                                        Movie Name (2008) `
                                            Movie Name (2008).ext`n `
    ./folderBuilder -Path 'G:\Videos\Movies' -Rename `
        Starting Directory tree :   G:\Videos\Movies `
                                        movienamehere(4000).txt`n `
                                        movie (2005) `
                                            movie name(5000).mp4 `
                                            text here.mp4`n `
                                        Movie Name (2008) `
                                            other name here (1999).ext `
        Ending Directory tree   :   G:\Videos\Movies `
                                        movienamehere(4000).txt`n `
                                        movie (2005) `
                                            movie (2005) (2).mp4 `
                                            movie (2005).mp4`n `
                                        Movie Name (2008) `
                                            Movie Name (2008).ext`n`n"
    Return
}
function Exiting {
    [CmdletBinding()]
    param(
        [String]$Reason,
        [Int32]$Exitcode
    )
    Switch ($Exitcode) {
        0 { "`nFinished Successfully.`n`nExit 0" ; Exit }
        1 { "`n{0}`n" -f $Reason ; Help ; "`nExit {0}" -f $Exitcode ; Exit }
        2 { "`n{0}`n" -f $Reason ; "`nExit {0}" -f $Exitcode ; Exit }
        Default { Exit }
    }
}
If ($help) { Help ; Exiting -Reason "Show Help." -ExitCode 3 }
# Remove trailing whitespace
$Path = $Path.TrimEnd()
# Verify path.
If ( $Path -ine "" ) { If (Test-Path -Path $Path) { "Verified Path." } Else { Exiting -Reason "System could not find '$Path'." -Exitcode 1 } } Else { Exiting -Reason "System could not find '$Path'." -Exitcode 1 }
# Complete paths.
function Complete-Path { param([String]$P) return "$PWD$($P.Substring(1))" }
If ( $(Split-Path -Path $Path -Parent) -ieq "." ) { "Relative source path detected...Resolving to absolute path..." ; $Path = Complete-Path -P $Path ; "Done." }
[String[]]$filesSkipped = @()
[Int64]$skipped = 0
[Int64]$foldersCreated = 0
[Int64]$filesMoved = 0
[Int64]$filesRenamed = 0
# Process files.
If ($Rename) {
    ForEach ( $folder In $(Get-ChildItem -Path "$Path") ) {
        # Only get folders.
        If ( $folder.PSIsContainer ) {
            $count = 1
            ForEach ($file In $(Get-ChildItem -Path "$($folder.FullName)")) {
                If ($count -eq 1) {
                    $newName = "$($folder.Name)" + "$($file.FullName -replace '^.*\.','.')"
                } Else {
                    $newName = "$($folder.Name)" + " ($count)" + "$($file.FullName -replace '^.*\.','.')"
                }
                Rename-Item -Path "$($file.FullName)" -NewName "$newName"
                $count+=1
                $filesRenamed+=1
            }
        }
    }
    "`nFiles Renamed : '{0}'`n" -f $filesRenamed
} Else {
    ForEach ( $file In $(Get-ChildItem -Path "$Path") ) {
        # Only process files not folders.
        If ( !$file.PSIsContainer ) {
            # Check for valid file name structure. Ex. 'Valid Movie Name Here (2009).ext'
            If ( $file.Name -match "^.*\([0-9]{4}\)") {
                "Found valid file: {0}" -f $file
                # Drop all characters after (Year).
                $newFolder = $($file.FullName -replace "\).*",")")
                # Check for duplicate folder name.
                If (Test-Path -Path $newFolder) {
                    # Test for file existing in new folder.
                    If (Test-Path -Path $($newFolder + "\" + $($(Split-Path -Path $newFolder -Leaf) -replace '\..*','') + $($file.Name -replace '^.*\.','.'))) {
                        $count = $(Get-ChildItem -Path "$newFolder" -Include "*$($(Split-Path -Path $newFolder -Leaf) -replace '\..*','')*").Count
                        $count+=1
                        $destination = $($newFolder + "\" + $($(Split-Path -Path $newFolder -Leaf) -replace '\..*','') + "($count)" + $($file.Name -replace '^.*\.','.'))
                    } Else {
                        $destination = $($newFolder + "\" + $($(Split-Path -Path $newFolder -Leaf) -replace '\..*','') + $($file.Name -replace '^.*\.','.'))
                    }
                    Move-Item -Path "$($file.FullName)" -Destination "$destination"
                    $filesMoved+=1
                } Else {
                    # Make new folder.
                    New-Item -Path "$newFolder" -Type "Directory"
                    $foldersCreated+=1
                    # Move file into new folder.
                    $destination = $($newFolder + "\" + $($(Split-Path -Path $newFolder -Leaf) -replace '\..*','') + $($file.Name -replace '^.*\.','.'))
                    Move-Item -Path "$($file.FullName)" -Destination "$destination"
                    $filesMoved+=1
                }
            } Else {
                $filesSkipped+=$file.Name
                $skipped+=1
            }
        }
    }
    If ( $skipped -gt 0 ) {
        "`nError: File(s) did not match expected input. `
Found             : '{0}'. `
Expected examples : 'Movie Name Here (YEAR).ext' `
                    'Movie Name Here (YEAR) - trailer.ext' `
                    'Movie Name Here (YEAR)-extras.ext'`n `
NOTE:   This script will scrap ALL text after '(YEAR)'. `
Examples: `
    ./folderBuilder -Path 'G:\Videos\Movies' `
        Starting Directory tree :   G:\Videos\Movies `
                                        movie (2005) - trailer.mp4 `
                                        movie (2005).mp4 `
                                        Movie Name (2008).ext `
        Ending Directory tree   :   G:\Videos\Movies `
                                        movie (2005) `
                                            movie (2005)(2).mp4 `
                                            movie (2005).mp4 `
                                      `
                                        Movie Name (2008) `
                                            Movie Name (2008).ext`n `
    ./folderBuilder -Path 'G:\Videos\Movies' -Rename `
        Starting Directory tree :   G:\Videos\Movies `
                                        movienamehere(4000).txt `
                                      `
                                        movie (2005) `
                                            movie name(5000).mp4 `
                                            text here.mp4 `
                                      `
                                        Movie Name (2008) `
                                            other name here (1999).ext `
        Ending Directory tree   :   G:\Videos\Movies `
                                        movienamehere(4000).txt `
                                      `
                                        movie (2005) `
                                            movie (2005) (2).mp4 `
                                            movie (2005).mp4 `
                                      `
                                        Movie Name (2008) `
                                            Movie Name (2008).ext `
        `n`n" -f $file
        "Files Skipped:`n"
        ForEach ( $file In $filesSkipped ) {
            "'{0}'" -f $file
        }
    }
    "`nFiles skipped : '{0}'`nFolders created : '{1}'`nFiles moved : '{2}'`n" -f $skipped, $foldersCreated, $filesMoved
}
"Done."
