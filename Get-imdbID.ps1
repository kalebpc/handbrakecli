
<#

    Get imbdid using OMDb API.

    Example :
        ./Get-imdbID.ps1 -Apikey "YourOMDbApiKey" -Source "Movie Name (2005)", "Another Movie Name (2010)"

    Example Pipeline input :
        # Handle Apikey from file.
        $fileContent = Get-Content -Path ".env" | Where { $_ -imatch "omdbapikey" }
        $keyapi = $($fileContent -split "=")[1].Replace("'","")
        $keyapi = $keyapi.Replace('"','').Trim()

        $temp = [PSCustomObject]@{
            'Apikey' = $keyapi
            'Source' = @(# List of Movie names.)
        }
        $results = $temp | ./Get-imdbID

    Example Source :
        input  :
            "Movie Name (2005)", "Another Movie Name (2010)"

        output :
            $results = @{
                Processed = @("Movie Name (2005) [imdbid-MOVIEIDHERE]", "Another Movie Name (2010) [imdbid-MOVIEIDHERE]")
                Skipped = @()
                Errors = @()
                Debug = @()
            }

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true HelpMessage = "OMDbAPI key or Path to file with key. Example file contents: 'omdbapikey' = 'yourOMDbAPIkey' ")]
    [String]$Apikey,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "List of folder/Movie names.")]
    [String[]]$Source
)

$Apikey = $Apikey.Trim()
$Source = $Source.Trim()
$results = New-Object PSObject
$results | Add-Member -MemberType NoteProperty -Name "Processed" -Value (New-Object System.Collections.Generic.List[String])   
$results | Add-Member -MemberType NoteProperty -Name "Skipped" -Value (New-Object System.Collections.Generic.List[String])   
$results | Add-Member -MemberType NoteProperty -Name "Errors" -Value (New-Object System.Collections.Generic.List[String])   
$results | Add-Member -MemberType NoteProperty -Name "Debug" -Value (New-Object System.Collections.Generic.List[String])   

# Required for [System.Web.HttpUtility]::UrlEncode()
If ( -not ('System.Web.HttpUtility' -as [type]) ) { Add-Type -AssemblyName System.Web }

If ( $Apikey -ine "" -and $Source -ine "" ) {

    ForEach ( $Name In $Source ) {

        # Movie Name (2005) as input example.
        $title, $year = $($Name -split "\(").Trim()
        
        If ( $year.Length -gt 5) { $year = $year -replace "^\D*","" }

        If ( $year -match "\-") { $year, $z = $year -split "-"}

        $year = $($year -replace "\)","").Trim()

        # Title search url.
        If ( $year -ieq "" ) { Add-Content -LiteralPath $Output -Value "$title - Skipped. No Year found." ; return }
        
        $url = "http://www.omdbapi.com/?apikey={0}&t={1}&y={2}" -f $Apikey, [System.Web.HttpUtility]::UrlEncode($title), $year
        $results.Debug.Add($url)
        
        # Rate limit requests.
        Start-Sleep -Seconds 5

        Try {
            $response = Invoke-RestMethod -Uri $url
        } Catch {
            $results.Errors.Add($_)
        }

        [String]$id = $response.imdbID

        If ( $id -imatch "^[tT][tT]" -and $id -ine "" ) {

            $newname = "{0} [imdbid-{1}]" -f $Name, $id

            $results.Processed.Add($newname)

        } Else {
            $results.Skipped.Add($Name)
        }
    }
    return $results
} Else { return "'Source' or 'Apikey' missing." }
