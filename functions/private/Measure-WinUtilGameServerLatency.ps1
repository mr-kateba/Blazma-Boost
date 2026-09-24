function Measure-WinUtilGameServerLatency {
    <#
    .SYNOPSIS
        Measures the latency to the server regions many online games are hosted in

    .DESCRIPTION
        For every entry in config/gameservers.json the host name is resolved first and then the
        TCP connect time to port 443 is measured three times; the best try is kept, like the
        lowest ping. A TCP handshake is one round trip, so this is close to what ping shows, and
        it works where ICMP ping is blocked. Unreachable regions get LatencyMs = $null.

    .PARAMETER TimeoutMs
        How long one connection attempt may take
    #>
    param(
        [int]$TimeoutMs = 2000
    )

    foreach ($server in $sync.configs.gameservers.PSObject.Properties) {
        $best = $null
        try {
            $address = @([System.Net.Dns]::GetHostAddresses($server.Value.Host) |
                Where-Object { $_.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork })[0]
            if ($address) {
                for ($attempt = 0; $attempt -lt 3; $attempt++) {
                    $client = [System.Net.Sockets.TcpClient]::new()
                    try {
                        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                        $connect = $client.BeginConnect($address, 443, $null, $null)
                        if ($connect.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) {
                            $client.EndConnect($connect)
                            $stopwatch.Stop()
                            $elapsed = [int]$stopwatch.ElapsedMilliseconds
                            if ($null -eq $best -or $elapsed -lt $best) { $best = $elapsed }
                        }
                    } catch {
                        # A refused or reset attempt just does not count
                    } finally {
                        $client.Dispose()
                    }
                }
            }
        } catch {
            Write-WinUtilLog -Level "WARN" -Component "Gaming" -Message "Could not resolve $($server.Value.Host): $($_.Exception.Message)"
        }

        [pscustomobject]@{
            Key       = $server.Name
            Name      = $server.Value.Name
            LatencyMs = $best
        }
    }
}
