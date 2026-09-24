function Get-WinUtilSystemSummary {
    <#
    .SYNOPSIS
        Reads the processor, graphics card, memory and Windows version for the Gaming tab

    .DESCRIPTION
        On machines with a discrete and an integrated GPU the NVIDIA or AMD card is reported,
        since that is the one games run on. GpuVendor is "NVIDIA", "AMD", "Intel" or "" and picks
        the driver download page.
    #>

    $cpu = @(Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue)[0]
    $gpus = @(Get-CimInstance -ClassName Win32_VideoController -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -and $_.Name -notmatch 'Basic Display|Remote Display|Virtual' })
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue

    $gpu = @($gpus | Where-Object { $_.Name -match 'NVIDIA|AMD|Radeon' })[0]
    if (-not $gpu) { $gpu = $gpus[0] }

    $gpuVendor = switch -Regex ([string]$gpu.Name) {
        'NVIDIA' { "NVIDIA"; break }
        'AMD|Radeon' { "AMD"; break }
        'Intel' { "Intel"; break }
        default { "" }
    }

    [pscustomobject]@{
        Cpu       = if ($cpu) { ([string]$cpu.Name).Trim() } else { "?" }
        Gpu       = if ($gpu) { [string]$gpu.Name } else { "?" }
        GpuDriver = if ($gpu) { [string]$gpu.DriverVersion } else { "?" }
        GpuVendor = $gpuVendor
        RamGB     = if ($computer) { [math]::Round($computer.TotalPhysicalMemory / 1GB) } else { "?" }
        Windows   = if ($os) { "$($os.Caption) ($($os.BuildNumber))" } else { "?" }
    }
}
