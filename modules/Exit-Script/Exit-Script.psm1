
function Exit-Script {
    [CmdletBinding(DefaultParameterSetName = "Exiting")]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Reason,
        [Parameter(Mandatory = $true, HelpMessage = "0 = Print success, exitcode and exit.`n1 = Print reason, help, exitcode and exit.`n2 = Print reason, exitcode and exit.`nAny other number = Print nothing and exit.`n")]
        [Int32]$Exitcode,
        [Parameter(HelpMessage = "Path to script help function.")]
        [String]$ScriptHelp
    )
    If ( $ScriptHelp -ieq "" -and $Exitcode -eq 1 ) {
        $Exitcode = 2
    } Else {
        $ScriptHelp = $ScriptHelp + " -Help"
    }
    Switch ($Exitcode) {
        # Print success,exitcode and exit
        0 { "`nFinished Successfully.`n`nExit 0" ; Exit }
        # Print reason,help,exitcode and exit
        1 { "`n{0}`n" -f $Reason ; Powershell -C "&{ $ScriptHelp }" ; "`nExit {0}" -f $Exitcode ; Exit }
        # Print reason,exitcode and exit
        2 { "`n{0}`n" -f $Reason ; "`nExit {0}" -f $Exitcode ; Exit }
        # Print nothing and exit
        Default { Exit }
    }
}
