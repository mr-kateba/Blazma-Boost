function Show-WinUtilRestartNotice {
    <#
    .SYNOPSIS
        Tells the user which of the tweaks just applied or undone need a restart

    .DESCRIPTION
        Tweaks marked "RestartRequired": "true" in config/tweaks.json only take effect after
        Windows restarts. Nothing is shown when none of the given tweaks is marked.

    .PARAMETER Tweaks
        The tweak keys that were applied or undone
    #>

    param([string[]]$Tweaks)

    $names = @($Tweaks | Where-Object { $sync.configs.tweaks.$_.RestartRequired -eq "true" } | ForEach-Object { "- $($sync.configs.tweaks.$_.Content)" })
    if ($names.Count -eq 0) {
        return
    }

    Show-WinUtilMessage -Message "Restart your PC to finish these changes:`n$($names -join "`n")" -Icon "Information" | Out-Null
}
