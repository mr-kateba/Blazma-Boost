function Get-WinUtilMemorySensor {
    <#
    .SYNOPSIS
        Reads how much memory is in use and the speed the modules run at

    .DESCRIPTION
        Windows does not expose memory module temperatures, so only use and speed are read.
        SpeedMHz is the configured speed of the fastest module, or $null when unknown.
    #>

    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop | Select-Object -First 1
    $totalKB = [double]$os.TotalVisibleMemorySize
    $freeKB = [double]$os.FreePhysicalMemory

    $speed = $null
    try {
        $speed = (@(Get-CimInstance -ClassName Win32_PhysicalMemory -ErrorAction Stop) | ForEach-Object {
            if ($_.ConfiguredClockSpeed) { $_.ConfiguredClockSpeed } else { $_.Speed }
        } | Measure-Object -Maximum).Maximum
    } catch {
        Write-Verbose "Could not read the memory speed: $($_.Exception.Message)"
    }

    [pscustomobject]@{
        UsedGB       = [math]::Round(($totalKB - $freeKB) / 1MB, 1)
        TotalGB      = [math]::Round($totalKB / 1MB, 1)
        UsagePercent = if ($totalKB -gt 0) { [math]::Round(100 * ($totalKB - $freeKB) / $totalKB) } else { $null }
        SpeedMHz     = if ($speed) { $speed } else { $null }
    }
}
