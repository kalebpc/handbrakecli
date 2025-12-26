
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Message to print to screen and add to log file.")]
    [String]$Content,
    [Parameter(HelpMessage = "Path to log file")]
    [String]$Path
)
"`n[$(Get-Date -Format "yyyy.MM.dd - hh:mm:ss tt")] {0}`n" -f $Content
If ( $Path -ine "" ) { If ( Test-Path -Path $Path ) { Add-Content -Path $Path -Value "`n------------`n[$(Get-Date -Format "yyyy.MM.dd - hh:mm:ss tt")] $Content`n------------`n" } Else { "`nError printing to log file." } }
