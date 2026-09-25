function Get-WinUtilGpuSensor {
    <#
    .SYNOPSIS
        Reads the live temperature, load, video memory and power of an NVIDIA card

    .DESCRIPTION
        Uses nvidia-smi, which every NVIDIA driver installs. Returns $null when it is missing
        (AMD and Intel cards, or no NVIDIA driver). Values a card does not report, such as power
        on some laptops, come back as $null.
    #>

    $nvidiaSmi = @(
        (Join-Path $env:SystemRoot "System32\nvidia-smi.exe"),
        (Join-Path $env:ProgramFiles "NVIDIA Corporation\NVSMI\nvidia-smi.exe")
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
    if (-not $nvidiaSmi) {
        return $null
    }

    $line = @(& $nvidiaSmi --query-gpu=temperature.gpu,utilization.gpu,memory.used,memory.total,power.draw --format=csv,noheader,nounits 2>$null)[0]
    ConvertFrom-WinUtilGpuSensorLine -Line $line
}

function ConvertFrom-WinUtilGpuSensorLine {
    <#
    .SYNOPSIS
        Turns one csv line of nvidia-smi output into the sensor object Get-WinUtilGpuSensor returns
    #>

    param([string]$Line)

    if ([string]::IsNullOrWhiteSpace($Line)) {
        return $null
    }

    # "[N/A]" (or "[Not Supported]") marks a value this card does not report
    $values = @($Line -split ',' | ForEach-Object {
        $value = $_.Trim()
        if ($value -match '^\[') { $null } else { $value }
    })

    [pscustomobject]@{
        TemperatureC  = $values[0]
        LoadPercent   = $values[1]
        MemoryUsedMB  = $values[2]
        MemoryTotalMB = $values[3]
        PowerW        = if ($values[4]) { [math]::Round([double]$values[4], [System.MidpointRounding]::AwayFromZero) } else { $null }
    }
}
