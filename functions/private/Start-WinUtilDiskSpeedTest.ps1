function Start-WinUtilDiskSpeedTest {
    <#
    .SYNOPSIS
        Runs the Windows drive speed test on the worker pool and shows the result on the Temperatures tab
    #>

    $sync.WPFTempsDiskSpeedResult.Text = Get-WinUtilText -Key "TempsDiskSpeedRunning" -Default "Measuring... this takes about a minute."
    $sync.WPFTempsDiskSpeedTest.IsEnabled = $false

    $null = Invoke-WPFRunspace -ScriptBlock {
        $speed = $null
        try {
            $speed = Measure-WinUtilDiskSpeed
        } catch {
            Write-WinUtilLog -Level "WARN" -Component "Temps" -Message "Disk speed test failed: $($_.Exception.Message)"
        }

        $text = if ($speed) {
            $unknown = "?"
            (Get-WinUtilText -Key "TempsDiskSpeedResult" -Default "Read: {0} MB/s`nWrite: {1} MB/s`nRandom read (like loading a game): {2} MB/s") -f `
                $speed.SequentialReadMBs,
                $(if ($null -ne $speed.SequentialWriteMBs) { $speed.SequentialWriteMBs } else { $unknown }),
                $(if ($null -ne $speed.RandomReadMBs) { $speed.RandomReadMBs } else { $unknown })
        } else {
            Get-WinUtilText -Key "TempsDiskSpeedFailed" -Default "The speed test could not run. Try again with the laptop plugged in."
        }
        Write-WinUtilLog -Component "Temps" -Message "Disk speed test: $($text -replace '\r?\n', ' | ')"

        Invoke-WPFUIThread -Async -Parameters @{ Text = $text } -ScriptBlock {
            param($Text)
            $sync.WPFTempsDiskSpeedResult.Text = $Text
            $sync.WPFTempsDiskSpeedTest.IsEnabled = $true
        }
    }
}
