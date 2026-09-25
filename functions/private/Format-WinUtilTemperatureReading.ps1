function Format-WinUtilTemperatureReading {
    <#
    .SYNOPSIS
        Turns the GPU and CPU sensor readings into the texts and heat levels the Temperatures tab shows

    .PARAMETER Gpu
        The result of Get-WinUtilGpuSensor, or $null without an NVIDIA card

    .PARAMETER Cpu
        The result of Get-WinUtilCpuSensor
    #>

    param($Gpu, $Cpu)

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

    [pscustomobject]@{
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
