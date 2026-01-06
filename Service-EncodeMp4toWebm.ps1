
<#

    random script for encoding my movies from mp4 to webm because that seems to be the best encoding for direct playing on jellyfin.

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
    Try {

        $temp = "`n------------`n[{0}] {1}`n------------`n" -f $(Get-Date -Format "yyyy.MM.dd - hh:mm:ss tt"), $Content

        $temp | Out-File -LiteralPath $Logpath -Encoding unicode -Append
    
    } Catch {

        $Logpath -replace "(\.\b)(?!.*\1).*$",$("-{0}" -f $(Get-Date -Format "yyyy.MM.dd-hh.mm.ss-tt.log"))
        
        $temp | Out-File -LiteralPath $Logpath -Encoding unicode -Append
    
    }

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

    Format-TimeLog "Getting new list of folders."

    ForEach ( $folder In $(Get-Childitem -LiteralPath $Folder) ) {

        function Replace-Extension {
        
            [CmdletBinding()]
            param(

                [Parameter(Mandatory = $true, Position = 0)]
                [String]$S

            )

            return $($S -replace "(\.\b)(?!.*\1).*$",".webm")

        }

        [Object[]]$items = Get-ChildItem -LiteralPath "G:\Jellyfin\Movies" -Recurse -Depth 1 | Where { $_.Name -imatch "^.*\.mp4" } | Sort-Object

        If ( $items -ne $null ) {

            ForEach ( $x In $items ) {

                [String]$temp = Replace-Extension $x.FullName

                If ( ! $(Test-Path -LiteralPath $temp) ) {

                    [String]$temp = "Started: '{0}'." -f $x.FullName

                    [String]$tmp = "logs\{0}.log" -f $($x.Name -replace " \[.*\] ?-?","_encode_")

                    [String]$tmp = $tmp -replace "\.mp4",".webm"

                    [String]$templog = $log -replace "logs.*", $tmp

                    " " | Out-File -LiteralPath $templog -Encoding unicode

                    Add-Log $temp $templog

                    Format-TimeLog $temp

                    [String]$temp = Format-TimeLog $("Started: '{0}'." -f $x.Name)

                    If ($send) { $response = ./Send-Message -Content $temp -Username $result.Username -Webhookuri $result.Webhookuri ; If ( $response -inotlike "Success*" ) { $response } }

                    [System.DateTime]$starttime = Get-Date

                    # Encode $items to webm
                    # HandbrakeCLI --preset-import-gui -Z "Creator 1080p30 webm" --start-at seconds:0 --stop-at seconds:5 -i $x.FullName -o $(Replace-Extension $x.FullName) 2>> $log
                    HandbrakeCLI --preset-import-gui -Z "Creator 1080p30 webm" -i $x.FullName -o $(Replace-Extension $x.FullName) 2>> $templog

                    [System.DateTime]$endtime = Get-Date

                    [String]$finished = "Finished '{0}' in {1}." -f $x.Name, $(Format-Time $(New-TimeSpan -Start $starttime -End $endtime))

                    [String]$temp = Format-TimeLog $finished

                    $temp

                    If ($send) { $response = ./Send-Message -Content $temp -Username $result.Username -Webhookuri $result.Webhookuri ; If ( $response -inotlike "Success*" ) { $response } }

                    Add-Log $finished $templog

                    # Short break between files to allow graceful exit.

                    [String]$temp = Format-TimeLog "Sleeping for 1 minute."

                    $temp

                    # If ($send) { $response = ./Send-Message -Content $temp -Username $result.Username -Webhookuri $result.Webhookuri ; If ( $response -inotlike "Success*" ) { $response } }

                    Start-Sleep -Seconds 60
                
                }

            }

        }

    }

}

[Int32]$minutes = 12

While ($true) { Run ; Format-Timelog $("Sleeping for {0} minutes." -f $minutes) ; Start-Sleep -Seconds $($minutes*60)}
