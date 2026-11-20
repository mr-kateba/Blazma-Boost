function Start-WinUtilGameServerLatencyTest {
    <#
    .SYNOPSIS
        Runs the game server latency test on the worker pool and shows the result on the Gaming tab
    #>

    $sync.WPFGamingPingResult.Text = Get-WinUtilText -Key "PingRunning" -Default "Measuring..."
    $sync.WPFGamingPing.IsEnabled = $false

    $started = Invoke-WPFRunspace -ScriptBlock {
        # A failed measurement still reports back, or the button would stay locked
        try {
            $results = @(Measure-WinUtilGameServerLatency | Sort-Object { if ($null -eq $_.LatencyMs) { [int]::MaxValue } else { $_.LatencyMs } })
            $unreachable = Get-WinUtilText -Key "PingUnreachable" -Default "no response"
            $lines = foreach ($result in $results) {
                $value = if ($null -eq $result.LatencyMs) { $unreachable } else { "$($result.LatencyMs) ms" }
                "$($result.Name): $value"
            }
            $text = $lines -join "`n"
        } catch {
            Write-WinUtilLog -Level "WARN" -Component "Gaming" -Message "Ping test failed: $($_.Exception.Message)"
            $text = Get-WinUtilText -Key "PingFailed" -Default "The ping test could not run. Check your connection and try again."
        }

        Invoke-WPFUIThread -Async -Parameters @{ Text = $text } -ScriptBlock {
            param($Text)
            $sync.WPFGamingPingResult.Text = $Text
            $sync.WPFGamingPing.IsEnabled = $true
        }
    }
    # Nothing was started (WinUtil is closing), so nothing will unlock the button later
    if ($null -eq $started) {
        $sync.WPFGamingPingResult.Text = ""
        $sync.WPFGamingPing.IsEnabled = $true
    }
}
