function Set-WinUtilStartupApp {
    <#
    .SYNOPSIS
        Enables or disables one startup program the way Task Manager does

    .DESCRIPTION
        Writes the program's StartupApproved record: 02 followed by zeros for enabled, or 03 and
        the time it was disabled for disabled. The program's own Run entry or shortcut is left
        alone, so enabling it again restores it exactly. A Store app gets its startup task State
        (2 enabled, 1 disabled by the user) and a scheduled task is enabled or disabled.

    .PARAMETER App
        An entry from Get-WinUtilStartupApps

    .PARAMETER Enabled
        Whether the program should start with Windows
    #>

    param(
        [Parameter(Mandatory)]$App,
        [Parameter(Mandatory)][bool]$Enabled
    )

    switch ($App.Kind) {
        "Store" {
            $null = New-ItemProperty -LiteralPath $App.StateKey -Name "State" -Value $(if ($Enabled) { 2 } else { 1 }) -PropertyType DWord -Force -ErrorAction Stop
        }
        "Task" {
            if ($Enabled) {
                $null = Enable-ScheduledTask -TaskName $App.TaskName -TaskPath $App.TaskPath -ErrorAction Stop
            } else {
                $null = Disable-ScheduledTask -TaskName $App.TaskName -TaskPath $App.TaskPath -ErrorAction Stop
            }
        }
        default {
            Set-WinUtilStartupApproved -App $App -Enabled $Enabled
        }
    }
    Write-WinUtilLog -Component "Startup" -Message "$(if ($Enabled) { 'Enabled' } else { 'Disabled' }) startup program $($App.Name)"
}

function Set-WinUtilStartupApproved {
    <#
    .SYNOPSIS
        Writes a Run entry's or Startup-folder shortcut's StartupApproved record
    #>

    param(
        [Parameter(Mandatory)]$App,
        [Parameter(Mandatory)][bool]$Enabled
    )

    $state = New-Object byte[] 12
    if ($Enabled) {
        $state[0] = 2
    } else {
        $state[0] = 3
        [BitConverter]::GetBytes([DateTime]::UtcNow.ToFileTimeUtc()).CopyTo($state, 4)
    }

    if (-not (Test-Path -LiteralPath $App.ApprovedKey)) {
        $null = New-Item -Path $App.ApprovedKey -Force -ErrorAction Stop
    }
    $null = New-ItemProperty -LiteralPath $App.ApprovedKey -Name $App.ValueName -Value $state -PropertyType Binary -Force -ErrorAction Stop
}
