function Measure-WinUtilGameServerLatency {
    <#
    .SYNOPSIS
        Measures the latency to the server regions many online games are hosted in

    .DESCRIPTION
        For every entry in config/gameservers.json the host name is resolved and the TCP connect
        time to port 443 is measured three times; the best try is kept, like the lowest ping. A TCP
        handshake is one round trip, so this is close to what ping shows, and it works where ICMP
        ping is blocked. All regions are resolved and measured at the same time, so the whole test
        takes about as long as the slowest region. Unreachable regions get LatencyMs = $null.

    .PARAMETER TimeoutMs
        How long one round of connection attempts may take

    .PARAMETER Port
        The TCP port to connect to
    #>
    param(
        [int]$TimeoutMs = 2000,
        [int]$Port = 443
    )

    $servers = @($sync.configs.gameservers.PSObject.Properties)

    # Resolve every host at once
    $lookups = @(foreach ($server in $servers) {
        try {
            [System.Net.Dns]::GetHostAddressesAsync($server.Value.Host)
        } catch {
            $null
        }
    })
    $clock = [System.Diagnostics.Stopwatch]::StartNew()
    $addresses = for ($index = 0; $index -lt $servers.Count; $index++) {
        $lookup = $lookups[$index]
        $address = $null
        if ($lookup) {
            $remaining = [math]::Max(0, $TimeoutMs - $clock.ElapsedMilliseconds)
            try {
                if ($lookup.Wait([int]$remaining)) {
                    $address = @($lookup.Result | Where-Object { $_.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork })[0]
                }
            } catch {
                Write-Verbose "Lookup failed: $($_.Exception.Message)"
            }
        }
        if (-not $address) {
            Write-WinUtilLog -Level "WARN" -Component "Gaming" -Message "Could not resolve $($servers[$index].Value.Host)"
        }
        , $address
    }
    $addresses = @($addresses)

    $best = New-Object 'object[]' $servers.Count
    for ($attempt = 0; $attempt -lt 3; $attempt++) {
        $clock = [System.Diagnostics.Stopwatch]::StartNew()
        $clients = @{}
        $tasks = @{}
        $startedAt = @{}
        for ($index = 0; $index -lt $servers.Count; $index++) {
            if (-not $addresses[$index]) {
                continue
            }
            $client = [System.Net.Sockets.TcpClient]::new()
            $clients[$index] = $client
            $startedAt[$index] = $clock.Elapsed.TotalMilliseconds
            $tasks[$index] = $client.ConnectAsync($addresses[$index], $Port)
        }

        $pending = [System.Collections.Generic.List[int]]::new()
        foreach ($index in $tasks.Keys) { $pending.Add($index) }
        try {
            while ($pending.Count -gt 0) {
                $remaining = $TimeoutMs - $clock.ElapsedMilliseconds
                if ($remaining -le 0) {
                    break
                }
                $waiting = [System.Threading.Tasks.Task[]]@($pending | ForEach-Object { $tasks[$_] })
                $finished = [System.Threading.Tasks.Task]::WaitAny($waiting, [int]$remaining)
                if ($finished -lt 0) {
                    break
                }
                $index = $pending[$finished]
                $elapsed = [int][math]::Round($clock.Elapsed.TotalMilliseconds - $startedAt[$index])
                # A refused or reset attempt just does not count towards the best time
                if ($tasks[$index].Status -eq [System.Threading.Tasks.TaskStatus]::RanToCompletion -and ($null -eq $best[$index] -or $elapsed -lt $best[$index])) {
                    $best[$index] = $elapsed
                }
                $pending.RemoveAt($finished)
            }
        } finally {
            foreach ($client in $clients.Values) { $client.Dispose() }
        }
    }

    for ($index = 0; $index -lt $servers.Count; $index++) {
        [pscustomobject]@{
            Key       = $servers[$index].Name
            Name      = $servers[$index].Value.Name
            LatencyMs = $best[$index]
        }
    }
}
