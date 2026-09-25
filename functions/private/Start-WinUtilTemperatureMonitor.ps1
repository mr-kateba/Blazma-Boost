function Start-WinUtilTemperatureMonitor {
    <#
    .SYNOPSIS
        Keeps the Temperatures tab up to date while it is open

    .DESCRIPTION
        Every three seconds, and only while "Temperatures" is the current tab, the GPU, CPU and
        memory sensors are read on the worker pool and the result is posted to the tab. The disks
        change slowly and their SMART query is heavier, so they are read every 30 seconds. Nothing
        is read while another tab is open, and the timer stops when the window closes.

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
                try {
                    if ($null -eq $Reading) {
                        return
                    }
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

                    # Two minutes of history drawn from 20 to 100 degrees, oldest on the left
                    if ($null -eq $sync.TemperatureHistory) {
                        $sync.TemperatureHistory = @{ Gpu = [System.Collections.Generic.List[double]]::new(); Cpu = [System.Collections.Generic.List[double]]::new() }
                    }
                    $samples = 40
                    foreach ($part in @("Gpu", "Cpu")) {
                        $history = $sync.TemperatureHistory[$part]
                        $celsius = $Reading."${part}TemperatureC"
                        if ($null -ne $celsius) {
                            $history.Add([double]$celsius)
                            while ($history.Count -gt $samples) { $history.RemoveAt(0) }
                        }

                        $canvas = $sync["WPFTemps${part}Graph"]
                        $width = $canvas.ActualWidth
                        $height = $canvas.ActualHeight
                        if ($history.Count -lt 2 -or $width -le 0 -or $height -le 0) {
                            continue
                        }
                        if ($canvas.Children.Count -eq 0) {
                            $line = New-Object System.Windows.Shapes.Polyline
                            $line.StrokeThickness = 2
                            $null = $canvas.Children.Add($line)
                        }
                        $line = $canvas.Children[0]
                        $points = New-Object System.Windows.Media.PointCollection
                        for ($index = 0; $index -lt $history.Count; $index++) {
                            $value = [math]::Min(100, [math]::Max(20, $history[$index]))
                            $x = ($samples - $history.Count + $index) * $width / ($samples - 1)
                            $points.Add([System.Windows.Point]::new($x, $height - (($value - 20) / 80 * $height)))
                        }
                        $line.Points = $points
                        $line.Stroke = $converter.ConvertFromString($colors[$(if ($colors.ContainsKey($Reading."${part}Level")) { $Reading."${part}Level" } else { "Good" })])
                    }

                    if ($Reading.HotAlert -and ($null -eq $sync.TemperatureAlertAt -or ([datetime]::UtcNow - $sync.TemperatureAlertAt).TotalMinutes -ge 5)) {
                        $sync.TemperatureAlertAt = [datetime]::UtcNow
                        Show-WinUtilHeatAlert -Message $Reading.HotAlert
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
                } finally {
                    $sync.TemperatureBusy = $false
                }
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
