function Start-WinUtilTemperatureMonitor {
    <#
    .SYNOPSIS
        Keeps the Temperatures tab up to date while it is open

    .DESCRIPTION
        Every three seconds, and only while "Temperatures" is the current tab, the GPU, CPU and
        memory sensors are read on the worker pool and the result is posted to the tab. The disks
        change slowly and their SMART query is heavier, so they are read every 30 seconds. Nothing
        is read while another tab is open, only every 15 seconds while the window is minimized,
        and the timer stops when the window closes.

        The last two minutes of GPU and CPU temperature are drawn as a line under each number, and
        a Windows notification warns (at most every five minutes) when either runs hot, so the tab
        can be left open while playing.
    #>

    if ($sync.TemperatureTimer) {
        return
    }

    $update = {
        if ($sync.ShuttingDown -or $sync.TemperatureBusy -or $sync.currentTab -ne "Temps") {
            return
        }
        # Minimized (usually while playing) nobody sees the numbers, so they are read every 15
        # seconds instead of every 3, only to keep the heat warning working
        $minimized = $sync.Form.WindowState -eq [System.Windows.WindowState]::Minimized
        if ($minimized -and $sync.TemperatureReadAt -and ([datetime]::UtcNow - $sync.TemperatureReadAt).TotalSeconds -lt 15) {
            return
        }
        $sync.TemperatureReadAt = [datetime]::UtcNow
        $sync.TemperatureBusy = $true

        $readDisks = $null -eq $sync.TemperatureDiskReadAt -or ([datetime]::UtcNow - $sync.TemperatureDiskReadAt).TotalSeconds -ge 30
        if ($readDisks) {
            $sync.TemperatureDiskReadAt = [datetime]::UtcNow
        }

        $started = Invoke-WPFRunspace -ArgumentList $readDisks -ScriptBlock {
            param($ReadDisks)

            $reading = $null
            try {
                $readings = @{}
                foreach ($sensor in @("Gpu", "Cpu", "Memory")) {
                    try {
                        $readings[$sensor] = & "Get-WinUtil${sensor}Sensor"
                    } catch {
                        Write-WinUtilLog -Level "WARN" -Component "Temps" -Message "Could not read the $sensor sensor: $($_.Exception.Message)"
                    }
                }
                $disks = $null
                if ($ReadDisks) {
                    try {
                        $disks = @(Get-WinUtilDiskHealth)
                    } catch {
                        Write-WinUtilLog -Level "WARN" -Component "Temps" -Message "Could not read disk health: $($_.Exception.Message)"
                        $disks = @()
                    }
                }
                $reading = Format-WinUtilTemperatureReading -Gpu $readings.Gpu -Cpu $readings.Cpu -Memory $readings.Memory -Disks $disks
            } catch {
                Write-WinUtilLog -Level "WARN" -Component "Temps" -Message "Could not update the Temperatures tab: $($_.Exception.Message)"
            }

            # Posted even without a reading, so the next tick is not blocked
            Invoke-WPFUIThread -Async -Parameters @{ Reading = $reading } -ScriptBlock {
                param($Reading)
                Update-WinUtilTemperatureTab -Reading $Reading
            }
        }
        if ($null -eq $started) {
            $sync.TemperatureBusy = $false
        }
    }

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromSeconds(3)
    $timer.Add_Tick($update)
    $sync.TemperatureTimer = $timer
    $sync.Form.Add_Closed({ $sync.TemperatureTimer.Stop() })
    $timer.Start()
    & $update
}
