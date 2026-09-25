function Start-WinUtilGpuSensorMonitor {
    <#
    .SYNOPSIS
        Keeps the GPU temperature line on the "My Specs" tab up to date while that tab is open

    .DESCRIPTION
        Every three seconds, and only while "My Specs" is the current tab, nvidia-smi runs on the
        worker pool and the result is posted to the tab. Without an NVIDIA card the line says so
        once and the timer stops.
    #>

    if ($sync.GpuSensorTimer) {
        return
    }

    $update = {
        if ($sync.GpuSensorBusy -or $sync.currentTab -ne "Specs") {
            return
        }
        $sync.GpuSensorBusy = $true

        $null = Invoke-WPFRunspace -ScriptBlock {
            try {
                $sensor = Get-WinUtilGpuSensor
            } catch {
                $sensor = $null
            }

            if ($null -eq $sensor) {
                $text = Get-WinUtilText -Key "GpuLiveUnavailable" -Default "Live temperature is available for NVIDIA cards only."
            } else {
                $unknown = "?"
                $format = Get-WinUtilText -Key "GpuLive" -Default "Temperature: {0}$([char]0x00B0)C | Load: {1}% | Video memory: {2} / {3} MB | Power: {4} W"
                $text = $format -f `
                    $(if ($null -ne $sensor.TemperatureC) { $sensor.TemperatureC } else { $unknown }),
                    $(if ($null -ne $sensor.LoadPercent) { $sensor.LoadPercent } else { $unknown }),
                    $(if ($null -ne $sensor.MemoryUsedMB) { $sensor.MemoryUsedMB } else { $unknown }),
                    $(if ($null -ne $sensor.MemoryTotalMB) { $sensor.MemoryTotalMB } else { $unknown }),
                    $(if ($null -ne $sensor.PowerW) { $sensor.PowerW } else { $unknown })
            }

            Invoke-WPFUIThread -Async -Parameters @{ Text = $text; Available = ($null -ne $sensor) } -ScriptBlock {
                param($Text, $Available)
                $sync.WPFSpecsGpuLive.Text = $Text
                $sync.GpuSensorBusy = $false
                if (-not $Available -and $sync.GpuSensorTimer) {
                    $sync.GpuSensorTimer.Stop()
                }
            }
        }
    }

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromSeconds(3)
    $timer.Add_Tick($update)
    $sync.GpuSensorTimer = $timer
    $timer.Start()
    & $update
}
