
<#

    Verifies username, webhookuri.

    Example :

        $result = ./Confirm-UserWebHook.ps1 -ArgumentList "file",".env"
    
    Example :

        $result = ./Confirm-UserWebHook.ps1 -ArgumentList "discordusername","https://discord.com/api/webhooks/restofyourwebhookhere"
    
    Example :

        $setup = @(
            "discordusername"
            "https://discord.com/api/webhooks/restofyourwebhookhere"
        )
        $result = ./Confirm-UserWebHook.ps1 -ArgumentList $setup
    
    Example :

        $setup = @(
            "file",
            ".env"
        )
        $result = ./Confirm-UserWebHook.ps1 -ArgumentList $setup

    Example Pipeline Input :

        $result = "discordusername","https://discord.com/api/webhooks/restofyourwebhookhere" | ./Confirm-UserWebHook.ps1

    Example Pipeline Input :

        $result = "file",".env" | ./Confirm-UserWebHook.ps1

    Example Pipeline Input :
    
        $setup = @(
            "file",
            ".env"
        )
        $result = $setup | ./Confirm-UserWebHook.ps1

#>

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
    function Set-UserHook {
        [CmdletBinding()]
        param([String]$S)
        # Check if file exists.
        If ( Test-Path -Path $S ) {
            # File exists.
            ForEach ( $line In $(Get-Content -Path $S) ) {
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
    }
    If ( $ArgumentList[0] -ieq "file" ) {
        Set-UserHook -S $ArgumentList[1].Trim()
    } ElseIf ( $ArgumentList[1] -ieq "file" ) {
        Set-UserHook -S $ArgumentList[0].Trim()
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
