function Start-WinUtilTemperatureMonitor {
    <#
    .SYNOPSIS
        Keeps the Temperatures tab up to date while it is open

    .DESCRIPTION
        Every three seconds, and only while "Temperatures" is the current tab, the GPU, CPU and
        memory sensors are read on the worker pool and the result is posted to the tab. The disks
        change slowly and their SMART query is heavier, so they are read every 30 seconds. Nothing
        is read while another tab is open.
    #>

    if ($sync.TemperatureTimer) {
        return
    }

    $update = {
        if ($sync.TemperatureBusy -or $sync.currentTab -ne "Temps") {
            return
        }
        $sync.TemperatureBusy = $true

        $readDisks = $null -eq $sync.TemperatureDiskReadAt -or ([datetime]::UtcNow - $sync.TemperatureDiskReadAt).TotalSeconds -ge 30
        if ($readDisks) {
            $sync.TemperatureDiskReadAt = [datetime]::UtcNow
        }

        $null = Invoke-WPFRunspace -ArgumentList $readDisks -ScriptBlock {
            param($ReadDisks)

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

            Invoke-WPFUIThread -Async -Parameters @{ Reading = $reading } -ScriptBlock {
                param($Reading)
                $converter = [System.Windows.Media.BrushConverter]::new()
                $colors = @{ Good = "#4CAF50"; Warm = "#FF9800"; Hot = "#F44336" }

                foreach ($part in @("Gpu", "Cpu", "Ram")) {
                    $level = $Reading."${part}Level"
                    $sync["WPFTemps${part}Value"].Text = $Reading."${part}Value"
                    $sync["WPFTemps${part}Status"].Text = $Reading."${part}Status"
                    $sync["WPFTemps${part}Details"].Text = $Reading."${part}Details"
                    if ($colors.ContainsKey($level)) {
                        $brush = $converter.ConvertFromString($colors[$level])
                        $sync["WPFTemps${part}Value"].Foreground = $brush
                        $sync["WPFTemps${part}Status"].Foreground = $brush
                    }
                }
                if ($Reading.GpuName) {
                    $sync.WPFTempsGpuName.Text = $Reading.GpuName
                }

                if ($Reading.DisksRead) {
                    $list = $sync.WPFTempsDiskList
                    $list.Children.Clear()
                    foreach ($disk in @($Reading.Disks)) {
                        $text = New-Object System.Windows.Controls.TextBlock
                        $text.TextWrapping = "Wrap"
                        $text.Margin = "7,0,7,12"
                        $text.LineHeight = 22
                        $title = New-Object System.Windows.Documents.Run($disk.Title)
                        $title.FontWeight = "Bold"
                        if ($colors.ContainsKey($disk.Level)) {
                            $title.Foreground = $converter.ConvertFromString($colors[$disk.Level])
                        }
                        $text.Inlines.Add($title)
                        $text.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
                        $text.Inlines.Add((New-Object System.Windows.Documents.Run($disk.Details)))
                        $null = $list.Children.Add($text)
                    }
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
