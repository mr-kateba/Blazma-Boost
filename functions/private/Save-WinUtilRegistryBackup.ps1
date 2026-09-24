function Save-WinUtilRegistryBackup {
    <#
    .SYNOPSIS
        Records a registry value before a tweak changes it, so undo can put back what the user had

    .DESCRIPTION
        The tweak config only knows the Windows default (OriginalValue). Undo used to write that
        default, which could turn a setting off that the user had turned on. The first value seen
        for each tweak, path and name is kept; applying a tweak again does not overwrite it.
        A value that did not exist is recorded as <RemoveEntry>.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Tweak,
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Name
    )

    try {
        $backupPath = Join-Path (Join-Path $env:LocalAppData "winutil") "registry-backup.json"
        $backup = @{}
        if (Test-Path -LiteralPath $backupPath) {
            (Get-Content -LiteralPath $backupPath -Raw | ConvertFrom-Json).PSObject.Properties | ForEach-Object {
                $backup[$_.Name] = $_.Value
            }
        }

        $key = "$Tweak|$Path|$Name"
        if ($backup.ContainsKey($key)) {
            return
        }

        $current = $null
        if (Test-Path -Path $Path) {
            $current = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
        }
        $backup[$key] = if ($null -eq $current) { "<RemoveEntry>" } else { [string]$current }

        New-Item -ItemType Directory -Path (Split-Path -Parent $backupPath) -Force | Out-Null
        $backup | ConvertTo-Json | Set-Content -LiteralPath $backupPath -Encoding UTF8
    } catch {
        # Without a backup, undo falls back to OriginalValue as before; never block the tweak
        Write-WinUtilLog -Level "WARN" -Component "Registry" -Message "Could not back up $Path\$Name for $Tweak`: $($_.Exception.Message)"
    }
}
