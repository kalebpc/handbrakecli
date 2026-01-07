
<#

    random script for encoding my movies from mp4 to webm because that seems to be the best encoding for direct playing on jellyfin.

    NOTE!
        Script uses a global var [String[]].

        [String[]]$Global:completedFiles+=$x.FullName

#>

[CmdletBinding()]
param(

    [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
    [String]$Folder,

    [Parameter(Position = 1, HelpMessage="Send script updates to discord webhook. Example: 'username','webhookUri' ; Example: 'file','webhookfile.ext' to load 'username' and 'webhookUri' from file.")]
    [String[]]$Notify

)

[String]$log = "$Env:LocalAppData\Scripts\HandBrake\Services\logs\Service-EncodeMp4toWebm.log"

[String]$temp = $log | Split-Path -Parent

If ( ! $(Test-Path -LiteralPath $temp) ) { New-Item -Path $temp -ItemType "Directory" -Force }

"Log located at:`n  '{0}'`n" -f $log

function Add-Log {
    
    [CmdletBinding()]
    param(

        [Parameter(Mandatory = $true, Position = 0)]
        [String]$Content,

        [Parameter(Mandatory = $true, Position = 1)]
        [String]$Logpath

    )

    $temp = "`n------------`n[{0}] {1}`n------------`n" -f $(Get-Date -Format "yyyy.MM.dd - hh:mm:ss tt"), $Content

    $temp | Out-File -LiteralPath $Logpath -Encoding unicode -Append
    
}

function Format-Time {
    
    [CmdletBinding()]
    param(

        [Parameter(Mandatory = $true, Position = 0)]
        [System.TimeSpan]$T

    )

    return $("{0} hours {1} minutes {2} seconds {3} milliseconds" -f $T.Hours, $T.Minutes, $T.Seconds, $T.Milliseconds)

}

function Format-TimeLog {
    
    [CmdletBinding()]
    param(

        [Parameter(Mandatory = $true, Position = 0)]
        [String]$S

    )

    return $("[{0}] {1}" -f $(Get-Date -Format "yyyy.MM.dd - hh:mm:ss tt"), $S)

}

[Boolean]$send = $false

If ( $Notify.Count -gt 1 ) {

    [PSCustomObject]$result = ./Confirm-UserWebHook $Notify

    If ($result.Verified) { $send = $true ; $response = ./Send-Message -Content $(Format-TimeLog "Service-EncodeMp4toWebm Started.") -Username $result.Username -Webhookuri $result.Webhookuri ; If ( $response -inotlike "Success*" ) { $response } } Else { "Could not verify '{0}','{1}'." -f $Notify[0], $Notify[1] ; Exit }

}

function Run {

    function Replace-Extension {
    
        [CmdletBinding()]
        param(

            [Parameter(Mandatory = $true, Position = 0)]
            [String]$S

        )

        return $($S -replace "(\.\b)(?!.*\1).*$",".webm")

    }

    function Get-NextFile {
    
        ForEach ( $x In $(Get-ChildItem -LiteralPath $Folder -Recurse -Depth 1 | Where { $_.Name -imatch "^.*\.mp4" } | Sort-Object) ) {

            [String]$temp = Replace-Extension $x.FullName

            If ( ! $(Test-Path -LiteralPath $temp) -and $x.FullName -inotin $completedFiles ) {

                return $x

            }

        }

    }

    [System.IO.FileInfo]$x = Get-NextFile

    [String]$temp = "Started: '{0}'." -f $x.FullName

    [String]$tmp = "logs\{0}.log" -f $($x.Name -replace " \[.*\] ?-? ?","_encode_")

    [String]$tmp = $tmp -replace "\.mp4",".webm"

    [String]$templog = $log -replace "logs.*", $tmp

    If ( Test-Path -LiteralPath $templog ) { [String[]]$Global:completedFiles+=$x.FullName ; "Already completed : '{0}'." -f $templog; return }

    " " | Out-File -LiteralPath $templog -Encoding unicode

    Add-Log $temp $templog

    Format-TimeLog $temp

    [String]$temp = Format-TimeLog $("Started: '{0}'." -f $x.Name)

    If ($send) { $response = ./Send-Message -Content $temp -Username $result.Username -Webhookuri $result.Webhookuri ; If ( $response -inotlike "Success*" ) { $response } }

    [System.DateTime]$starttime = Get-Date

    # HandbrakeCLI --preset-import-gui -Z "Creator 1080p30 webm" --start-at seconds:0 --stop-at seconds:5 -i $x.FullName -o $(Replace-Extension $x.FullName) 2>> $log
    HandbrakeCLI --preset-import-gui -Z "Creator 1080p30 webm" -i $x.FullName -o $(Replace-Extension $x.FullName) 2>> $templog

    [System.DateTime]$endtime = Get-Date

    [String]$finished = "Finished '{0}' in {1}." -f $x.Name, $(Format-Time $(New-TimeSpan -Start $starttime -End $endtime))

    [String]$temp = Format-TimeLog $finished

    $temp

    If ($send) { $response = ./Send-Message -Content $temp -Username $result.Username -Webhookuri $result.Webhookuri ; If ( $response -inotlike "Success*" ) { $response } }

    Add-Log $finished $templog

    [String[]]$Global:completedFiles+=$x.FullName

}

[Int32]$minutes = 1

While ($true) { Run ; Format-Timelog $("Sleeping for {0} minutes." -f $minutes) ; Start-Sleep -Seconds $($minutes*60)}
