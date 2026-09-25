function Get-WinUtilCpuSensor {
    <#
    .SYNOPSIS
        Reads the processor load and, where the PC reports one, its temperature

    .DESCRIPTION
        Windows has no processor temperature of its own; the closest it offers is the ACPI thermal
        zones the motherboard reports, read here through the thermal zone performance counters
        (tenths of a kelvin). The hottest zone is taken. Many desktops report no zone, or a fixed
        placeholder, so TemperatureC is $null whenever no zone gives a plausible value.
    #>

    $load = $null
    try {
        $load = (Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average).Average
        if ($null -ne $load) {
            $load = [math]::Round($load)
        }
    } catch {
        Write-Verbose "Could not read the processor load: $($_.Exception.Message)"
    }

    $temperature = $null
    try {
        $zones = @(Get-CimInstance -ClassName Win32_PerfFormattedData_Counters_ThermalZoneInformation -ErrorAction Stop)
        $celsius = @($zones | ForEach-Object {
            $kelvin = if ($_.HighPrecisionTemperature) { $_.HighPrecisionTemperature / 10 } else { $_.Temperature }
            if ($kelvin) { [math]::Round($kelvin - 273.15) }
        } | Where-Object { $_ -gt 0 -and $_ -lt 125 })
        if ($celsius.Count -gt 0) {
            $temperature = ($celsius | Measure-Object -Maximum).Maximum
        }
    } catch {
        Write-Verbose "Could not read the thermal zones: $($_.Exception.Message)"
    }

    [pscustomobject]@{
        TemperatureC = $temperature
        LoadPercent  = $load
    }
}
