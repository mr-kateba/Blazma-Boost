function Start-WinUtilTemperatureMonitor {
    <#
    .SYNOPSIS
        Keeps the Temperatures tab up to date while it is open

    .DESCRIPTION
        Every three seconds, and only while "Temperatures" is the current tab, the GPU and CPU
        sensors are read on the worker pool and the result is posted to the tab. Nothing is read
        while another tab is open.
    #>

    if ($sync.TemperatureTimer) {
        return
    }

    $update = {
        if ($sync.TemperatureBusy -or $sync.currentTab -ne "Temps") {
            return
        }
        $sync.TemperatureBusy = $true

        $null = Invoke-WPFRunspace -ScriptBlock {
            $gpu = $null
            $cpu = $null
            try {
                $gpu = Get-WinUtilGpuSensor
            } catch {
                Write-WinUtilLog -Level "WARN" -Component "Temps" -Message "Could not read the GPU sensor: $($_.Exception.Message)"
            }
            try {
                $cpu = Get-WinUtilCpuSensor
            } catch {
                Write-WinUtilLog -Level "WARN" -Component "Temps" -Message "Could not read the CPU sensor: $($_.Exception.Message)"
            }
            $reading = Format-WinUtilTemperatureReading -Gpu $gpu -Cpu $cpu

            Invoke-WPFUIThread -Async -Parameters @{ Reading = $reading } -ScriptBlock {
                param($Reading)
                $colors = @{ Good = "#4CAF50"; Warm = "#FF9800"; Hot = "#F44336" }
                foreach ($part in @("Gpu", "Cpu")) {
                    $level = $Reading."${part}Level"
                    $sync["WPFTemps${part}Value"].Text = $Reading."${part}Value"
                    $sync["WPFTemps${part}Status"].Text = $Reading."${part}Status"
                    $sync["WPFTemps${part}Details"].Text = $Reading."${part}Details"
                    if ($colors.ContainsKey($level)) {
                        $brush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($colors[$level])
                        $sync["WPFTemps${part}Value"].Foreground = $brush
                        $sync["WPFTemps${part}Status"].Foreground = $brush
                    }
                }
                if ($Reading.GpuName) {
                    $sync.WPFTempsGpuName.Text = $Reading.GpuName
                }
                $sync.TemperatureBusy = $false
            }
        }
    }

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromSeconds(3)
    $timer.Add_Tick($update)
    $sync.TemperatureTimer = $timer
    $timer.Start()
    & $update
}
