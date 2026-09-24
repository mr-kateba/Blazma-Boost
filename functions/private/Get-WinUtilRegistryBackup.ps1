function Get-WinUtilRegistryBackup {
    <#
    .SYNOPSIS
        Returns the value a tweak found before it changed a registry value, or $null

    .PARAMETER Remove
        Forget the value once it is read, because undo has put it back
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Tweak,
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Name,

        [switch]$Remove
    )

    try {
        $backupPath = Join-Path (Join-Path $env:LocalAppData "winutil") "registry-backup.json"
        if (-not (Test-Path -LiteralPath $backupPath)) {
            return $null
        }

        $backup = Get-Content -LiteralPath $backupPath -Raw | ConvertFrom-Json
        $key = "$Tweak|$Path|$Name"
        $entry = $backup.PSObject.Properties[$key]
        if (-not $entry) {
            return $null
        }

        if ($Remove) {
            $backup.PSObject.Properties.Remove($key)
            $backup | ConvertTo-Json | Set-Content -LiteralPath $backupPath -Encoding UTF8
        }
        return $entry.Value
    } catch {
        Write-WinUtilLog -Level "WARN" -Component "Registry" -Message "Could not read the registry backup for $Tweak`: $($_.Exception.Message)"
        return $null
    }
}
