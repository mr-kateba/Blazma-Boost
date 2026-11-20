function Update-WinUtilTemperatureTab {
    <#
    .SYNOPSIS
        Shows one reading from Start-WinUtilTemperatureMonitor on the Temperatures tab

    .DESCRIPTION
        Runs on the interface thread. It is a function of its own so the monitor posts a one line
        call every few seconds instead of this whole block as text to be compiled again each time.
        It always clears the busy flag, so the next tick is never blocked.
    #>
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
