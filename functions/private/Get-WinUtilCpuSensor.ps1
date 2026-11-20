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

    # The load comes from the raw processor counter, compared with the reading before it: one
    # cheap query per tick. Win32_Processor works it out itself, which takes about half a second
    # and loads the CPU it is measuring, so it is only asked when there is no earlier reading.
    $load = $null
    try {
        $sample = Get-CimInstance -ClassName Win32_PerfRawData_PerfOS_Processor -Filter "Name='_Total'" -ErrorAction Stop | Select-Object -First 1
        $previous = if ($sync) { $sync.CpuLoadSample }
        if ($sync) {
            $sync.CpuLoadSample = $sample
        }
        if ($previous) {
            $elapsed = [double]$sample.Timestamp_Sys100NS - [double]$previous.Timestamp_Sys100NS
            if ($elapsed -gt 0) {
                # PercentProcessorTime counts idle time, so busy is what is left
                $idle = ([double]$sample.PercentProcessorTime - [double]$previous.PercentProcessorTime) / $elapsed
                $load = [math]::Round([math]::Min(100, [math]::Max(0, 100 * (1 - $idle))))
            }
        }
    } catch {
        Write-Verbose "Could not read the processor counter: $($_.Exception.Message)"
    }
    if ($null -eq $load) {
        try {
            $load = (Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average).Average
            if ($null -ne $load) {
                $load = [math]::Round($load)
            }
        } catch {
            Write-Verbose "Could not read the processor load: $($_.Exception.Message)"
        }
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
