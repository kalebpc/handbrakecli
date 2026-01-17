
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Message to print to screen and add to log file.")]
    [String]$Content,
    [Parameter(HelpMessage = "Path to log file")]
    [String]$Path
)
"`n[$(Get-Date -Format "yyyy.MM.dd - hh:mm:ss tt")] {0}`n" -f $Content
If ( $Path -ine "" ) {
    
    Try {

        Add-Content -LiteralPath $Path -Value "`n------------`n[$(Get-Date -Format "yyyy.MM.dd - hh:mm:ss tt")] $Content`n------------`n" -ErrorAction Stop

    } Catch {

        $Path = "{0}\{1}-{2}" -f $($Path | Split-Path -Parent), $(Get-Random -Minimum 111111111 -Maximum 999999999 ), $($Path | Split-Path -Leaf)
        
        Add-Content -LiteralPath $Path -Value "`n------------`n[$(Get-Date -Format "yyyy.MM.dd - hh:mm:ss tt")] $Content`n------------`n"
    
    }

}
