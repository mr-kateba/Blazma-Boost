function Save-WinUtilPreferences {
    <#
    .SYNOPSIS
        Remembers the theme, package manager and font size for the next launch

    .DESCRIPTION
        Written to %LocalAppData%\winutil\preferences.json. A failure only means the next launch
        starts with the defaults, so it is logged and never interrupts the user.
    #>

    try {
        $path = Join-Path (Join-Path $env:LocalAppData "winutil") "preferences.json"
        New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force | Out-Null
        [ordered]@{
            theme          = $sync.preferences.theme
            packagemanager = $sync.preferences.packagemanager
            fontScale      = if ($sync.ContainsKey("FontScaleFactor")) { [double]$sync.FontScaleFactor } else { 1.0 }
        } | ConvertTo-Json | Set-Content -LiteralPath $path -Encoding UTF8
    } catch {
        Write-WinUtilLog -Level "WARN" -Component "Preferences" -Message "Could not save preferences: $($_.Exception.Message)"
    }
}
