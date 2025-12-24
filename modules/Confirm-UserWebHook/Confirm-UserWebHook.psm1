
function Confirm-UserWebHook {
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Example: 'username','webhookUri' ; Example from file: 'file','webhookfile.ext'")]
        [String[]]$ArgumentList
    )
    [PSCustomObject]$result = @{
        'Verified' = $false
        'Username' = ''
        'Webhookuri' = ''
    }
    If ( $ArgumentList.Length -gt 1 ) {
        If ( $ArgumentList[0] -ieq "file" ) {
            # Check if file exists.
            If ( Test-Path -Path $ArgumentList[1].Trim() ) {
                # File exists.
                ForEach ( $line In $(Get-Content -Path $ArgumentList[1]) ) {
                    $temp1, $temp2 = $($line -split "=", 2).Trim()
                    $temp1, $temp2 = $($temp1, $temp2).Trim("'")
                    $temp1, $temp2 = $($temp1, $temp2).Trim('"')
                    If ( $temp1 -ieq "username" ) {
                        "Found 'username'."
                        $result.Username = $temp2
                    } ElseIf ( $temp1 -ieq "webhookUri" ) {
                        "Found 'webhookUri'."
                        $result.Webhookuri = $temp2
                    }
                }
            }
        } ElseIf ( $ArgumentList[1] -ieq "file" ) {
            # Check if file exists.
            If ( Test-Path -Path $ArgumentList[0].Trim() ) {
                # File exists.
                ForEach ( $line In $(Get-Content -Path $ArgumentList[0]) ) {
                    $temp1, $temp2 = $($line -split "=", 2).Trim()
                    $temp1, $temp2 = $($temp1, $temp2).Trim("'")
                    $temp1, $temp2 = $($temp1, $temp2).Trim('"')
                    If ( $temp1 -ieq "username" ) {
                        "Found 'username'."
                        $result.Username = $temp2
                    } ElseIf ( $temp1 -ieq "webhookUri" ) {
                        "Found 'webhookUri'."
                        $result.Webhookuri = $temp2
                    }
                }
            }
        } Else {
            # Handle direct username, webhook entry.
            If ( $ArgumentList[0] -imatch "^https\:.*discord\.com.*api" ) {
                "Found 'username'."
                $result.UserName = $ArgumentList[1].Trim()
                "Found 'webhookUri'."
                $result.Webhookuri = $ArgumentList[0].Trim()
            } Else {
                "Found 'username'."
                $result.Username = $ArgumentList[0].Trim()
                "Found 'webhookUri'."
                $result.Webhookuri = $ArgumentList[1].Trim()
            }
        }
        If ( $result.Username -ine "" -and $result.Webhookuri -ine "" ) { $result.Verified = $true }
    }
    return $result
}
