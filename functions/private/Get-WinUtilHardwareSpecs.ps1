function Get-WinUtilHardwareSpecs {
    <#
    .SYNOPSIS
        Reads the full hardware specification shown on the "My Specs" tab

    .DESCRIPTION
        Returns one formatted text block per section (Cpu, Gpu, Ram, Board, Storage, Windows).
        Labels come from translations.json through Get-WinUtilText and fall back to English.
        Anything Windows does not report is shown as "?" rather than failing the whole panel.
    #>

    function Get-Cim([string]$ClassName, [string]$Namespace = "root\cimv2") {
        @(Get-CimInstance -Namespace $Namespace -ClassName $ClassName -ErrorAction SilentlyContinue)
    }
    function Format-Size([double]$Bytes) {
        if ($Bytes -ge 1TB) { "{0:0.##} TB" -f ($Bytes / 1TB) } else { "{0:0} GB" -f ($Bytes / 1GB) }
    }
    function Get-Text([string]$Key, [string]$Default) {
        Get-WinUtilText -Key $Key -Default $Default
    }
    $unknown = "?"
    # A right-to-left mark keeps a line that starts with "-" and English text in order in the
    # Arabic window; without it the dash is drawn at the far end of the line
    $rtl = [char]0x200F

    # Processor
    $cpuLines = foreach ($cpu in (Get-Cim "Win32_Processor")) {
        (Get-Text "SpecsCpu" "{0}`nCores: {1} / Threads: {2}`nMax clock: {3} GHz") -f `
            ([string]$cpu.Name).Trim(), $cpu.NumberOfCores, $cpu.NumberOfLogicalProcessors, ("{0:0.0#}" -f ($cpu.MaxClockSpeed / 1000))
    }

    # Graphics. AdapterRAM is 32 bit and stops at 4 GB, so the real size comes from the
    # display driver's registry key when it is there.
    $gpuMemory = @{}
    $displayClass = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
    Get-ChildItem -Path $displayClass -ErrorAction SilentlyContinue | ForEach-Object {
        $driverKey = Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue
        if ($driverKey.DriverDesc -and $driverKey.'HardwareInformation.qwMemorySize') {
            $gpuMemory[[string]$driverKey.DriverDesc] = [double]$driverKey.'HardwareInformation.qwMemorySize'
        }
    }
    $gpus = @(Get-Cim "Win32_VideoController" | Where-Object { $_.Name -and $_.Name -notmatch 'Basic Display|Remote Display|Virtual' })
    $gpuLines = foreach ($gpu in $gpus) {
        $memory = if ($gpuMemory.ContainsKey([string]$gpu.Name)) { $gpuMemory[[string]$gpu.Name] } else { [double]$gpu.AdapterRAM }
        $driverDate = if ($gpu.DriverDate) { ([datetime]$gpu.DriverDate).ToString("yyyy-MM-dd") } else { $unknown }
        $display = if ($gpu.CurrentHorizontalResolution) {
            "{0} x {1} @ {2} Hz" -f $gpu.CurrentHorizontalResolution, $gpu.CurrentVerticalResolution, $gpu.CurrentRefreshRate
        } else { $unknown }
        (Get-Text "SpecsGpu" "{0}`nVideo memory: {1}`nDriver: {2} ({3})`nDisplay: {4}") -f `
            $gpu.Name, $(if ($memory -gt 0) { Format-Size $memory } else { $unknown }), $gpu.DriverVersion, $driverDate, $display
    }

    # Memory
    $modules = Get-Cim "Win32_PhysicalMemory"
    $totalMemory = ($modules | Measure-Object -Property Capacity -Sum).Sum
    if (-not $totalMemory) { $totalMemory = (Get-Cim "Win32_ComputerSystem" | Select-Object -First 1).TotalPhysicalMemory }
    $slots = (Get-Cim "Win32_PhysicalMemoryArray" | Measure-Object -Property MemoryDevices -Sum).Sum
    $speed = ($modules | ForEach-Object { if ($_.ConfiguredClockSpeed) { $_.ConfiguredClockSpeed } else { $_.Speed } } |
        Measure-Object -Maximum).Maximum
    $ramLines = @(
        (Get-Text "SpecsRam" "Total: {0} @ {1} MHz`nSlots used: {2} of {3}") -f `
            $(if ($totalMemory) { Format-Size $totalMemory } else { $unknown }), $(if ($speed) { $speed } else { $unknown }),
            $modules.Count, $(if ($slots) { $slots } else { $unknown })
    ) + @(foreach ($module in $modules) {
        "$rtl- {0} {1} {2} ({3})" -f (Format-Size $module.Capacity), ([string]$module.Manufacturer).Trim(), ([string]$module.PartNumber).Trim(), $module.DeviceLocator
    })

    # Motherboard and BIOS
    $board = Get-Cim "Win32_BaseBoard" | Select-Object -First 1
    $bios = Get-Cim "Win32_BIOS" | Select-Object -First 1
    $biosDate = if ($bios.ReleaseDate) { ([datetime]$bios.ReleaseDate).ToString("yyyy-MM-dd") } else { $unknown }
    $boardText = (Get-Text "SpecsBoard" "{0} {1}`nBIOS: {2} ({3})") -f `
        ([string]$board.Manufacturer).Trim(), ([string]$board.Product).Trim(), $bios.SMBIOSBIOSVersion, $biosDate

    # Storage. MSFT_PhysicalDisk knows SSD from HDD and the bus; Win32_DiskDrive is the fallback.
    $diskLines = @(foreach ($disk in (Get-Cim "MSFT_PhysicalDisk" "root\Microsoft\Windows\Storage")) {
        $media = switch ([int]$disk.MediaType) { 3 { "HDD" } 4 { "SSD" } default { "" } }
        $bus = switch ([int]$disk.BusType) { 7 { "USB" } 11 { "SATA" } 17 { "NVMe" } default { "" } }
        "$rtl- {0} ({1}) {2}" -f ([string]$disk.FriendlyName).Trim(), (Format-Size $disk.Size), (("$bus $media").Trim())
    })
    if ($diskLines.Count -eq 0) {
        $diskLines = @(foreach ($disk in (Get-Cim "Win32_DiskDrive")) {
            "$rtl- {0} ({1})" -f ([string]$disk.Model).Trim(), (Format-Size $disk.Size)
        })
    }

    # The card games run on (discrete before integrated) is the one checked for driver updates
    $primaryGpu = @($gpus | Where-Object { $_.Name -match 'NVIDIA|AMD|Radeon' })[0]
    if (-not $primaryGpu) { $primaryGpu = $gpus[0] }
    $notebookChassis = @(8, 9, 10, 11, 12, 14, 18, 21, 31, 32)
    $isNotebook = [bool](Get-Cim "Win32_SystemEnclosure" | Where-Object { @($_.ChassisTypes | Where-Object { $_ -in $notebookChassis }).Count -gt 0 })

    # Windows
    $os = Get-Cim "Win32_OperatingSystem" | Select-Object -First 1
    $windowsText = (Get-Text "SpecsWindows" "{0}`nVersion: {1} (build {2})`nArchitecture: {3}") -f `
        $os.Caption, $os.Version, $os.BuildNumber, $os.OSArchitecture

    [pscustomobject]@{
        Cpu     = if ($cpuLines) { $cpuLines -join "`n`n" } else { $unknown }
        Gpu     = if ($gpuLines) { $gpuLines -join "`n`n" } else { $unknown }
        Ram     = $ramLines -join "`n"
        Board   = $boardText
        Storage = if ($diskLines.Count -gt 0) { $diskLines -join "`n" } else { $unknown }
        Windows = $windowsText
        PrimaryGpu = $primaryGpu
        IsNotebook = $isNotebook
    }
}
