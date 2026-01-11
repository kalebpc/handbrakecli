
<#

    random script for starting services.

#>

[CmdletBinding()]
param(

    [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
    [String]$Service,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String[]]$Argumentlist

)

Switch -Wildcard ($Service) {

    default { "No service started." ; Exit }
    
}