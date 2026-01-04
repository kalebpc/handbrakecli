
<#
    Send message to discord webhook.

    Example :
        ./Send-Message -Content "Message to send." -Username "discordusername" -Webhookuri "https://discord.com/api/webhooks/restofyourwebhookhere"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Message to send.")]
    [String]$Content,
    [Parameter(Mandatory = $true, HelpMessage = "Discord username.")]
    [String]$Username,
    [Parameter(Mandatory = $true, HelpMessage = "Enter webhook https address. Example: 'https://discord.com/api/webhooks/restofyourwebhookhere'.")]
    [String]$Webhookuri
)
[String]$response = "Success.`n"
$body = @{
    'username' = $Username
    'content' = $Content
}
Try {
    Invoke-RestMethod -Uri $Webhookuri -Method 'post' -Body $body
} Catch {
    $response = "Error sending post to 'Webhookuri'.`n  StatusCode: {0}`n  StatusDescription: {1}`n" -f $_.Exception.Response.StatusCode.value__, $_.Exception.Response.StatusDescription
}
return $response
