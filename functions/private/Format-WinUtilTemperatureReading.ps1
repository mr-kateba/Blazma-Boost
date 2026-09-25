function Format-WinUtilTemperatureReading {
    <#
    .SYNOPSIS
        Turns the sensor readings into the texts and levels the Temperatures tab shows

    .PARAMETER Gpu
        The result of Get-WinUtilGpuSensor, or $null without an NVIDIA card

    .PARAMETER Cpu
        The result of Get-WinUtilCpuSensor

    .PARAMETER Memory
        The result of Get-WinUtilMemorySensor

    .PARAMETER Disks
        The result of Get-WinUtilDiskHealth, or $null to leave the disks out
    #>

    param($Gpu, $Cpu, $Memory, $Disks)

    $degree = "$([char]0x00B0)C"
    $unknown = "?"

    function Get-HeatLevel([object]$Celsius, [int]$Warm, [int]$Hot) {
        if ($null -eq $Celsius) { return "None" }
        $value = [double]$Celsius
        if ($value -ge $Hot) { "Hot" } elseif ($value -ge $Warm) { "Warm" } else { "Good" }
    }

    function Get-HeatStatus([string]$Level) {
        switch ($Level) {
            "Good" { Get-WinUtilText -Key "TempsGood" -Default "Good" }
            "Warm" { Get-WinUtilText -Key "TempsWarm" -Default "Warm" }
            "Hot" { Get-WinUtilText -Key "TempsHot" -Default "Hot! Check the cooling" }
            default { "" }
        }
    }

    function Get-OrUnknown($Value) {
        if ($null -ne $Value -and "$Value" -ne "") { $Value } else { $unknown }
    }

    $gpuTemperature = if ($Gpu) { $Gpu.TemperatureC }
    $gpuLevel = Get-HeatLevel -Celsius $gpuTemperature -Warm 70 -Hot 83
    $gpuDetails = if ($Gpu) {
        (Get-WinUtilText -Key "TempsGpuDetails" -Default "Load: {0}%`nVideo memory: {1} / {2} MB`nPower: {3} W") -f `
            (Get-OrUnknown $Gpu.LoadPercent), (Get-OrUnknown $Gpu.MemoryUsedMB), (Get-OrUnknown $Gpu.MemoryTotalMB), (Get-OrUnknown $Gpu.PowerW)
    } else {
        Get-WinUtilText -Key "TempsGpuUnavailable" -Default "Live GPU temperature is available for NVIDIA cards only."
    }

    $cpuTemperature = if ($Cpu) { $Cpu.TemperatureC }
    $cpuLevel = Get-HeatLevel -Celsius $cpuTemperature -Warm 70 -Hot 85
    $cpuLoad = (Get-WinUtilText -Key "TempsCpuDetails" -Default "Load: {0}%") -f (Get-OrUnknown $(if ($Cpu) { $Cpu.LoadPercent }))
    $cpuDetails = if ($null -eq $cpuTemperature) {
        "$cpuLoad`n$(Get-WinUtilText -Key "TempsCpuUnavailable" -Default "This PC does not report the processor temperature to Windows.")"
    } else {
        $cpuLoad
    }

    $ramUsage = if ($Memory) { $Memory.UsagePercent }
    $ramLevel = Get-HeatLevel -Celsius $ramUsage -Warm 70 -Hot 85
    $ramStatus = if ($Memory) { (Get-WinUtilText -Key "TempsRamUsed" -Default "{0} / {1} GB in use") -f $Memory.UsedGB, $Memory.TotalGB } else { "" }
    $ramDetails = "$((Get-WinUtilText -Key "TempsRamSpeed" -Default "Speed: {0} MHz") -f (Get-OrUnknown $(if ($Memory) { $Memory.SpeedMHz })))`n$(Get-WinUtilText -Key "TempsRamNoTemperature" -Default "Windows does not report memory temperature.")"

    $diskCards = if ($null -ne $Disks) {
        @(foreach ($disk in @($Disks)) {
            $healthLevel = switch ($disk.Health) { "Healthy" { "Good" } "Warning" { "Warm" } "Unhealthy" { "Hot" } default { "None" } }
            $temperatureLevel = Get-HeatLevel -Celsius $disk.TemperatureC -Warm 55 -Hot 70
            $level = @("Hot", "Warm", "Good", "None") | Where-Object { $_ -in @($healthLevel, $temperatureLevel) } | Select-Object -First 1

            $parts = @((Get-WinUtilText -Key "TempsDiskHealth" -Default "Health: {0}") -f (Get-WinUtilText -Key "TempsDisk$($disk.Health)" -Default $disk.Health))
            if ($null -ne $disk.TemperatureC) { $parts += (Get-WinUtilText -Key "TempsDiskTemperature" -Default "Temperature: {0}") -f "$($disk.TemperatureC)$degree" }
            if ($null -ne $disk.WearPercent) { $parts += (Get-WinUtilText -Key "TempsDiskLife" -Default "Life left: {0}%") -f [math]::Max(0, 100 - $disk.WearPercent) }
            if ($null -ne $disk.PowerOnHours) { $parts += (Get-WinUtilText -Key "TempsDiskHours" -Default "Powered on: {0} hours") -f $disk.PowerOnHours }

            [pscustomobject]@{
                Title   = ("{0} ({1} GB) {2}" -f $disk.Name, $disk.SizeGB, $disk.Kind).Trim()
                Details = $parts -join "`n"
                Level   = $level
            }
        })
    }

    [pscustomobject]@{
        RamValue   = if ($null -ne $ramUsage) { "$ramUsage%" } else { "--" }
        RamLevel   = $ramLevel
        RamStatus  = $ramStatus
        RamDetails = $ramDetails
        DisksRead  = $null -ne $Disks
        Disks      = $diskCards
        GpuName    = if ($Gpu -and $Gpu.Name) { $Gpu.Name } else { "" }
        GpuValue   = if ($null -ne $gpuTemperature) { "$gpuTemperature$degree" } else { "--" }
        GpuLevel   = $gpuLevel
        GpuStatus  = Get-HeatStatus $gpuLevel
        GpuDetails = $gpuDetails
        CpuValue   = if ($null -ne $cpuTemperature) { "$cpuTemperature$degree" } else { "--" }
        CpuLevel   = $cpuLevel
        CpuStatus  = Get-HeatStatus $cpuLevel
        CpuDetails = $cpuDetails
    }
}
