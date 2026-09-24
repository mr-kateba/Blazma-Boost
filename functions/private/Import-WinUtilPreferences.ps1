function Import-WinUtilPreferences {
    <#
    .SYNOPSIS
        Restores the preferences saved by Save-WinUtilPreferences over the defaults

    .DESCRIPTION
        Only known values are taken, so a damaged or hand-edited file can never put an invalid
        theme, package manager or font size into effect.
    #>

    $path = Join-Path (Join-Path $env:LocalAppData "winutil") "preferences.json"
    if (-not (Test-Path -LiteralPath $path)) {
        return
    }

    try {
        $saved = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    } catch {
        Write-WinUtilLog -Level "WARN" -Component "Preferences" -Message "Ignoring unreadable preferences: $($_.Exception.Message)"
        return
    }

    if ($saved.theme -in @("Auto", "Dark", "Light")) {
        $sync.preferences.theme = [string]$saved.theme
    }
    if ($saved.packagemanager -in @("Winget", "Choco")) {
        $sync.preferences.packagemanager = [string]$saved.packagemanager
    }
    $fontScale = $saved.fontScale -as [double]
    if ($fontScale -ge 0.75 -and $fontScale -le 2.0 -and $fontScale -ne 1.0) {
        # Invoke-WinutilThemeChange reapplies this when the window's theme is first applied
        $sync.FontScaleFactor = $fontScale
    }
}
