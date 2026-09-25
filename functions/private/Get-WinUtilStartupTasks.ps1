function Get-WinUtilStartupTasks {
    <#
    .SYNOPSIS
        Lists the scheduled tasks that start a program when the user signs in

    .DESCRIPTION
        Programs such as updaters and launchers often start from a logon task rather than the Run
        keys, so Task Manager's Startup page never shows them. Windows' own tasks (under
        \Microsoft\) are left out.

    .PARAMETER Task
        The tasks to look through; all scheduled tasks when not given
    #>

    param($Task = @(Get-ScheduledTask -ErrorAction SilentlyContinue))

    foreach ($entry in @($Task)) {
        if ("$($entry.TaskPath)" -like "\Microsoft\*") {
            continue
        }
        $atLogon = @($entry.Triggers | Where-Object { $_.CimClass.CimClassName -eq "MSFT_TaskLogonTrigger" }).Count -gt 0
        if (-not $atLogon) {
            continue
        }

        [pscustomobject]@{
            Kind     = "Task"
            Name     = [string]$entry.TaskName
            TaskName = [string]$entry.TaskName
            TaskPath = [string]$entry.TaskPath
            Command  = (@($entry.Actions | ForEach-Object { ("$($_.Execute) $($_.Arguments)").Trim() }) -join "; ")
            Enabled  = "$($entry.State)" -ne "Disabled"
        }
    }
}
