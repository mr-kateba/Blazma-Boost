function Start-WinUtilGameServerLatencyTest {
    <#
    .SYNOPSIS
        Runs the game server latency test on the worker pool and shows the result on the Gaming tab
    #>

    $sync.WPFGamingPingResult.Text = Get-WinUtilText -Key "PingRunning" -Default "Measuring..."
    $sync.WPFGamingPing.IsEnabled = $false

    $null = Invoke-WPFRunspace -ScriptBlock {
        $results = @(Measure-WinUtilGameServerLatency | Sort-Object { if ($null -eq $_.LatencyMs) { [int]::MaxValue } else { $_.LatencyMs } })
        $unreachable = Get-WinUtilText -Key "PingUnreachable" -Default "no response"
        $lines = foreach ($result in $results) {
            $value = if ($null -eq $result.LatencyMs) { $unreachable } else { "$($result.LatencyMs) ms" }
            "$($result.Name): $value"
        }

        Invoke-WPFUIThread -Async -Parameters @{ Text = ($lines -join "`n") } -ScriptBlock {
            param($Text)
            $sync.WPFGamingPingResult.Text = $Text
            $sync.WPFGamingPing.IsEnabled = $true
        }
    }
}
