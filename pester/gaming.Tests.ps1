#===========================================================================
# Tests - Blazma Boost gaming features
#===========================================================================

BeforeAll {
    $script:repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilText.ps1")
    . (Join-Path $script:repoRoot "functions\private\Save-WinUtilRegistryBackup.ps1")
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilRegistryBackup.ps1")
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilSystemSummary.ps1")
    . (Join-Path $script:repoRoot "functions\private\Open-WinUtilGpuDriverPage.ps1")
    . (Join-Path $script:repoRoot "functions\private\Start-WinUtilUpdateCheck.ps1")
    . (Join-Path $script:repoRoot "functions\public\Invoke-WPFGamingOneClick.ps1")
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilHardwareSpecs.ps1")
    . (Join-Path $script:repoRoot "functions\private\Copy-WinUtilHardwareSpecs.ps1")

    function Write-WinUtilLog { param($Message, $Level, $Component) }
    function Invoke-WPFRunspace { param($ScriptBlock, $ArgumentList, $ParameterList) & $ScriptBlock }
    function Invoke-WPFUIThread { param([scriptblock]$ScriptBlock, [hashtable]$Parameters, [switch]$Async) & $ScriptBlock @Parameters }
    function Invoke-WPFPresets { param($preset, $imported, $checkboxfilterpattern) }
    function Invoke-WPFtweaksbutton { }
    # Get-CimInstance does not exist outside Windows; a stub lets Pester mock it there too
    if (-not (Get-Command Get-CimInstance -ErrorAction SilentlyContinue)) {
        function Get-CimInstance { param($ClassName, $ErrorAction) }
    }
}

Describe "Registry backup" {
    BeforeEach {
        $script:previousLocalAppData = $env:LocalAppData
        $env:LocalAppData = Join-Path $TestDrive ([guid]::NewGuid())
    }

    AfterEach {
        $env:LocalAppData = $script:previousLocalAppData
    }

    It "records a missing value as <RemoveEntry> and hands it back once" {
        Save-WinUtilRegistryBackup -Tweak "WPFTweaksExample" -Path "HKLM:\Software\BlazmaBoostMissing" -Name "Value"

        Get-WinUtilRegistryBackup -Tweak "WPFTweaksExample" -Path "HKLM:\Software\BlazmaBoostMissing" -Name "Value" -Remove |
            Should -Be "<RemoveEntry>"
        Get-WinUtilRegistryBackup -Tweak "WPFTweaksExample" -Path "HKLM:\Software\BlazmaBoostMissing" -Name "Value" |
            Should -BeNullOrEmpty
    }

    It "keeps the first value when a tweak is applied twice" {
        Mock Test-Path { $true } -ParameterFilter { $Path -eq "HKCU:\Software\Example" }
        Mock Get-ItemProperty { [pscustomobject]@{ Setting = 1 } }
        Save-WinUtilRegistryBackup -Tweak "WPFTweaksExample" -Path "HKCU:\Software\Example" -Name "Setting"

        Mock Get-ItemProperty { [pscustomobject]@{ Setting = 0 } }
        Save-WinUtilRegistryBackup -Tweak "WPFTweaksExample" -Path "HKCU:\Software\Example" -Name "Setting"

        Get-WinUtilRegistryBackup -Tweak "WPFTweaksExample" -Path "HKCU:\Software\Example" -Name "Setting" | Should -Be "1"
    }

    It "returns nothing when no backup was ever written" {
        Get-WinUtilRegistryBackup -Tweak "WPFTweaksExample" -Path "HKCU:\Software\Example" -Name "Setting" | Should -BeNullOrEmpty
    }
}

Describe "Get-WinUtilSystemSummary" {
    It "prefers the discrete GPU and reports its vendor" {
        Mock Get-CimInstance {
            switch ($ClassName) {
                "Win32_Processor" { [pscustomobject]@{ Name = " AMD Ryzen 7 5800X " } }
                "Win32_VideoController" {
                    [pscustomobject]@{ Name = "Intel(R) UHD Graphics"; DriverVersion = "31.0" }
                    [pscustomobject]@{ Name = "NVIDIA GeForce RTX 3070"; DriverVersion = "32.0.15.6094" }
                }
                "Win32_ComputerSystem" { [pscustomobject]@{ TotalPhysicalMemory = 16GB } }
                "Win32_OperatingSystem" { [pscustomobject]@{ Caption = "Windows 11 Pro"; BuildNumber = "26100" } }
            }
        }

        $summary = Get-WinUtilSystemSummary

        $summary.Cpu | Should -Be "AMD Ryzen 7 5800X"
        $summary.Gpu | Should -Be "NVIDIA GeForce RTX 3070"
        $summary.GpuVendor | Should -Be "NVIDIA"
        $summary.GpuDriver | Should -Be "32.0.15.6094"
        $summary.RamGB | Should -Be 16
        $summary.Windows | Should -Be "Windows 11 Pro (26100)"
    }
}

Describe "Open-WinUtilGpuDriverPage" {
    It "opens the page for the detected vendor and nothing without one" {
        Mock Start-Process { }
        $script:sync = @{ GamingGpuVendor = "AMD" }
        Open-WinUtilGpuDriverPage
        Should -Invoke -CommandName Start-Process -Times 1 -Exactly -ParameterFilter { $FilePath -like "https://www.amd.com/*" }

        $script:sync = @{ GamingGpuVendor = "" }
        Open-WinUtilGpuDriverPage
        Should -Invoke -CommandName Start-Process -Times 1 -Exactly
        Remove-Variable -Name sync -Scope Script
    }
}

Describe "Start-WinUtilUpdateCheck" {
    BeforeEach {
        $script:sync = @{
            version = "26.09.24"
            WPFUpdateBannerText = [pscustomobject]@{ Text = "" }
            WPFUpdateBanner = [pscustomobject]@{ Visibility = "Collapsed" }
        }
    }

    AfterEach {
        Remove-Variable -Name sync -Scope Script -ErrorAction SilentlyContinue
    }

    It "shows the banner for a newer release" {
        Mock Invoke-RestMethod { [pscustomobject]@{ tag_name = "26.10.01" } }
        Start-WinUtilUpdateCheck

        $script:sync.WPFUpdateBannerText.Text | Should -Be "A new version of Blazma Boost is available: 26.10.01"
        "$($script:sync.WPFUpdateBanner.Visibility)" | Should -Be "Visible"
    }

    It "stays hidden when the running build is current or the check fails" {
        Mock Invoke-RestMethod { [pscustomobject]@{ tag_name = "26.09.24" } }
        Start-WinUtilUpdateCheck
        "$($script:sync.WPFUpdateBanner.Visibility)" | Should -Be "Collapsed"

        Mock Invoke-RestMethod { throw "offline" }
        { Start-WinUtilUpdateCheck } | Should -Not -Throw
        "$($script:sync.WPFUpdateBanner.Visibility)" | Should -Be "Collapsed"
    }
}

Describe "Invoke-WPFGamingOneClick" {
    It "selects the gaming preset and a restore point before applying" {
        Mock Invoke-WPFPresets { }
        Mock Invoke-WPFtweaksbutton { }

        Invoke-WPFGamingOneClick

        Should -Invoke -CommandName Invoke-WPFPresets -Times 1 -Exactly -ParameterFilter { $preset -eq "Gaming" }
        Should -Invoke -CommandName Invoke-WPFPresets -Times 1 -Exactly -ParameterFilter { @($preset) -contains "WPFTweaksRestorePoint" }
        Should -Invoke -CommandName Invoke-WPFtweaksbutton -Times 1 -Exactly
    }
}

Describe "Get-WinUtilHardwareSpecs" {
    It "formats every section and reads the real video memory from the driver key" {
        Mock Get-CimInstance {
            switch ($ClassName) {
                "Win32_Processor" { [pscustomobject]@{ Name = "AMD Ryzen 7 5800X"; NumberOfCores = 8; NumberOfLogicalProcessors = 16; MaxClockSpeed = 3800 } }
                "Win32_VideoController" {
                    [pscustomobject]@{ Name = "NVIDIA GeForce RTX 3070"; AdapterRAM = 4GB; DriverVersion = "32.0.15.6094"
                        DriverDate = [datetime]"2024-08-01"; CurrentHorizontalResolution = 2560; CurrentVerticalResolution = 1440; CurrentRefreshRate = 165 }
                }
                "Win32_PhysicalMemory" {
                    [pscustomobject]@{ Capacity = 16GB; ConfiguredClockSpeed = 3200; Manufacturer = "Corsair"; PartNumber = "CMK16GX4"; DeviceLocator = "DIMM1" }
                    [pscustomobject]@{ Capacity = 16GB; ConfiguredClockSpeed = 3200; Manufacturer = "Corsair"; PartNumber = "CMK16GX4"; DeviceLocator = "DIMM2" }
                }
                "Win32_PhysicalMemoryArray" { [pscustomobject]@{ MemoryDevices = 4 } }
                "Win32_BaseBoard" { [pscustomobject]@{ Manufacturer = "ASUSTeK COMPUTER INC."; Product = "ROG STRIX B550-F GAMING" } }
                "Win32_BIOS" { [pscustomobject]@{ SMBIOSBIOSVersion = "3002"; ReleaseDate = [datetime]"2023-02-10" } }
                "MSFT_PhysicalDisk" { [pscustomobject]@{ FriendlyName = "Samsung SSD 980 PRO 1TB"; Size = 1TB; MediaType = 4; BusType = 17 } }
                "Win32_OperatingSystem" { [pscustomobject]@{ Caption = "Windows 11 Pro"; Version = "10.0.26100"; BuildNumber = "26100"; OSArchitecture = "64-bit" } }
            }
        }
        Mock Get-ChildItem { [pscustomobject]@{ PSPath = "driverkey" } } -ParameterFilter { $Path -like "HKLM:*" }
        Mock Get-ItemProperty { [pscustomobject]@{ DriverDesc = "NVIDIA GeForce RTX 3070"; "HardwareInformation.qwMemorySize" = 8GB } }

        $specs = Get-WinUtilHardwareSpecs

        $specs.Cpu | Should -Be "AMD Ryzen 7 5800X`nCores: 8 / Threads: 16`nMax clock: 3.8 GHz"
        $specs.Gpu | Should -Be "NVIDIA GeForce RTX 3070`nVideo memory: 8 GB`nDriver: 32.0.15.6094 (2024-08-01)`nDisplay: 2560 x 1440 @ 165 Hz"
        $specs.Ram | Should -Be "Total: 32 GB @ 3200 MHz`nSlots used: 2 of 4`n- 16 GB Corsair CMK16GX4 (DIMM1)`n- 16 GB Corsair CMK16GX4 (DIMM2)"
        $specs.Board | Should -Be "ASUSTeK COMPUTER INC. ROG STRIX B550-F GAMING`nBIOS: 3002 (2023-02-10)"
        $specs.Storage | Should -Be "- Samsung SSD 980 PRO 1TB (1 TB) NVMe SSD"
        $specs.Windows | Should -Be "Windows 11 Pro`nVersion: 10.0.26100 (build 26100)`nArchitecture: 64-bit"
    }

    It "shows ? instead of failing when Windows reports nothing" {
        Mock Get-CimInstance { }
        Mock Get-ChildItem { } -ParameterFilter { $Path -like "HKLM:*" }

        $specs = Get-WinUtilHardwareSpecs

        $specs.Cpu | Should -Be "?"
        $specs.Gpu | Should -Be "?"
        $specs.Storage | Should -Be "?"
    }
}

Describe "Copy-WinUtilHardwareSpecs" {
    It "copies every section under its heading" {
        # Set-Clipboard is missing on some hosts; a stub lets Pester mock it everywhere
        if (-not (Get-Command Set-Clipboard -ErrorAction SilentlyContinue)) {
            function script:Set-Clipboard { param($Value) }
        }
        Mock Set-Clipboard { $script:copied = $Value }
        $script:sync = @{}
        foreach ($name in @("CPU", "GPU", "RAM", "Board", "Storage", "Windows")) {
            $script:sync["WPFSpecs$($name)Header"] = [pscustomobject]@{ Content = "H$name" }
            $script:sync["WPFSpecs$name"] = [pscustomobject]@{ Text = "T$name`nline2" }
        }

        Copy-WinUtilHardwareSpecs

        $script:copied | Should -Match "^\[HCPU\]\r\nTCPU\r\nline2\r\n\r\n\[HGPU\]"
        $script:copied | Should -Match "\[HWindows\]\r\nTWindows\r\nline2$"
        Remove-Variable -Name sync -Scope Script
    }
}
