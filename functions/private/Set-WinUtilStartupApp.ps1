function Set-WinUtilStartupApp {
    <#
    .SYNOPSIS
        Enables or disables one startup program the way Task Manager does

    .DESCRIPTION
        Writes the program's StartupApproved record: 02 followed by zeros for enabled, or 03 and
        the time it was disabled for disabled. The program's own Run entry or shortcut is left
        alone, so enabling it again restores it exactly.

    .PARAMETER App
        An entry from Get-WinUtilStartupApps

    .PARAMETER Enabled
        Whether the program should start with Windows
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
    Write-WinUtilLog -Component "Startup" -Message "$(if ($Enabled) { 'Enabled' } else { 'Disabled' }) startup program $($App.Name)"
}
