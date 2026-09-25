#===========================================================================
# Tests - Blazma Boost gaming features
#===========================================================================

BeforeAll {
    $script:repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilText.ps1")
    . (Join-Path $script:repoRoot "functions\private\Save-WinUtilRegistryBackup.ps1")
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilRegistryBackup.ps1")
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilSystemSummary.ps1")
    . (Join-Path $script:repoRoot "functions\private\Open-WinUtilGpuDriverUpdater.ps1")
    . (Join-Path $script:repoRoot "functions\private\Start-WinUtilUpdateCheck.ps1")
    . (Join-Path $script:repoRoot "functions\public\Invoke-WPFGamingOneClick.ps1")
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilHardwareSpecs.ps1")
    . (Join-Path $script:repoRoot "functions\private\Copy-WinUtilHardwareSpecs.ps1")
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilGpuDriverStatus.ps1")
    . (Join-Path $script:repoRoot "functions\private\Save-WinUtilPreferences.ps1")
    . (Join-Path $script:repoRoot "functions\private\Import-WinUtilPreferences.ps1")
    . (Join-Path $script:repoRoot "functions\private\Start-WinUtilGameServerLatencyTest.ps1")
    . (Join-Path $script:repoRoot "functions\private\Measure-WinUtilGameServerLatency.ps1")
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilGpuSensor.ps1")
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilCpuSensor.ps1")
    . (Join-Path $script:repoRoot "functions\private\Format-WinUtilTemperatureReading.ps1")
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilStartupApps.ps1")
    . (Join-Path $script:repoRoot "functions\private\Set-WinUtilStartupApp.ps1")

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

Describe "Open-WinUtilGpuDriverUpdater" {
    BeforeEach {
        Mock Start-Process { }
        $script:previousProgramFiles = $env:ProgramFiles
        $env:ProgramFiles = Join-Path $TestDrive ([guid]::NewGuid())
        New-Item -ItemType Directory -Path $env:ProgramFiles -Force | Out-Null
    }

    AfterEach {
        $env:ProgramFiles = $script:previousProgramFiles
        Remove-Variable -Name sync -Scope Script -ErrorAction SilentlyContinue
    }

    It "opens the NVIDIA App when it is installed" {
        $appFolder = Join-Path $env:ProgramFiles "NVIDIA Corporation\NVIDIA App\CEF"
        New-Item -ItemType Directory -Path $appFolder -Force | Out-Null
        New-Item -ItemType File -Path (Join-Path $appFolder "NVIDIA App.exe") | Out-Null
        $script:sync = @{ GamingGpuVendor = "NVIDIA" }

        Open-WinUtilGpuDriverUpdater

        Should -Invoke -CommandName Start-Process -Times 1 -Exactly -ParameterFilter { $FilePath -like "*NVIDIA App*NVIDIA App.exe" }
    }

    It "opens AMD Adrenalin when it is installed" {
        $appFolder = Join-Path $env:ProgramFiles "AMD\CNext\CNext"
        New-Item -ItemType Directory -Path $appFolder -Force | Out-Null
        New-Item -ItemType File -Path (Join-Path $appFolder "RadeonSoftware.exe") | Out-Null
        $script:sync = @{ GamingGpuVendor = "AMD" }

        Open-WinUtilGpuDriverUpdater

        Should -Invoke -CommandName Start-Process -Times 1 -Exactly -ParameterFilter { $FilePath -like "*RadeonSoftware.exe" }
    }

    It "falls back to the vendor download page when the app is missing" {
        $script:sync = @{ GamingGpuVendor = "NVIDIA" }
        Open-WinUtilGpuDriverUpdater
        Should -Invoke -CommandName Start-Process -Times 1 -Exactly -ParameterFilter { $FilePath -eq "https://www.nvidia.com/en-us/software/nvidia-app/" }

        $script:sync = @{ GamingGpuVendor = "AMD" }
        Open-WinUtilGpuDriverUpdater
        Should -Invoke -CommandName Start-Process -Times 1 -Exactly -ParameterFilter { $FilePath -like "https://www.amd.com/*" }
    }

    It "does nothing when the vendor is unknown" {
        $script:sync = @{ GamingGpuVendor = "" }
        Open-WinUtilGpuDriverUpdater
        Should -Invoke -CommandName Start-Process -Times 0 -Exactly
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
        $rtl = [char]0x200F
        $specs.Ram | Should -Be "Total: 32 GB @ 3200 MHz`nSlots used: 2 of 4`n$rtl- 16 GB Corsair CMK16GX4 (DIMM1)`n$rtl- 16 GB Corsair CMK16GX4 (DIMM2)"
        $specs.Board | Should -Be "ASUSTeK COMPUTER INC. ROG STRIX B550-F GAMING`nBIOS: 3002 (2023-02-10)"
        $specs.Storage | Should -Be "$rtl- Samsung SSD 980 PRO 1TB (1 TB) NVMe SSD"
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

Describe "Get-WinUtilGpuDriverStatus" {
    BeforeEach {
        Mock Invoke-RestMethod {
            if ($Uri -like "*gpu-data.json") {
                [pscustomobject]@{
                    desktop = [pscustomobject]@{ "GeForce RTX 3070" = "933"; "GeForce RTX 4070 SUPER" = "1041" }
                    notebook = [pscustomobject]@{ "GeForce RTX 3060 Laptop GPU" = "940" }
                }
            } else {
                $script:lookupUri = $Uri
                [pscustomobject]@{
                    Success = "1"
                    IDS = @(
                        [pscustomobject]@{ downloadInfo = [pscustomobject]@{ Version = "566.36" } }
                        [pscustomobject]@{ downloadInfo = [pscustomobject]@{ Version = "565.90" } }
                    )
                }
            }
        }
    }

    It "reports an update when NVIDIA has a newer driver" {
        $status = Get-WinUtilGpuDriverStatus -Name "NVIDIA GeForce RTX 3070" -DriverVersion "32.0.15.6094"

        $status.Status | Should -Be "UpdateAvailable"
        $status.Installed | Should -Be "560.94"
        $status.Latest | Should -Be "566.36"
        $script:lookupUri | Should -Match "pfid=933&"
    }

    It "reports up to date when the newest driver is installed" {
        $status = Get-WinUtilGpuDriverStatus -Name "NVIDIA GeForce RTX 3070" -DriverVersion "32.0.15.6636"

        $status.Status | Should -Be "UpToDate"
        $status.Installed | Should -Be "566.36"
    }

    It "matches laptop and SUPER names to NVIDIA's list" {
        Get-WinUtilGpuDriverStatus -Name "NVIDIA GeForce RTX 3060 Laptop GPU" -DriverVersion "32.0.15.6094" -IsNotebook | Out-Null
        $script:lookupUri | Should -Match "pfid=940&"

        Get-WinUtilGpuDriverStatus -Name "NVIDIA GeForce RTX 4070 Super" -DriverVersion "32.0.15.6094" | Out-Null
        $script:lookupUri | Should -Match "pfid=1041&"
    }

    It "returns Unknown for a card NVIDIA's list does not have" {
        (Get-WinUtilGpuDriverStatus -Name "NVIDIA Quadro Something" -DriverVersion "32.0.15.6094").Status | Should -Be "Unknown"
    }

    It "judges AMD and Intel drivers by age without going online" {
        (Get-WinUtilGpuDriverStatus -Name "AMD Radeon RX 6700 XT" -DriverVersion "31.0.21001.45002" -DriverDate (Get-Date).AddDays(-400)).Status | Should -Be "Old"
        (Get-WinUtilGpuDriverStatus -Name "Intel(R) Arc(TM) A770" -DriverVersion "32.0.101.5972" -DriverDate (Get-Date).AddDays(-30)).Status | Should -Be "Current"
        Should -Invoke -CommandName Invoke-RestMethod -Times 0 -Exactly
    }
}

Describe "Preferences" {
    BeforeEach {
        $script:previousLocalAppData = $env:LocalAppData
        $env:LocalAppData = Join-Path $TestDrive ([guid]::NewGuid())
        $script:sync = @{ preferences = @{ theme = "Light"; packagemanager = "Choco"; language = "en" }; FontScaleFactor = 1.25 }
    }

    AfterEach {
        $env:LocalAppData = $script:previousLocalAppData
        Remove-Variable -Name sync -Scope Script -ErrorAction SilentlyContinue
    }

    It "restores what was saved" {
        Save-WinUtilPreferences
        $script:sync = @{ preferences = @{ theme = "Dark"; packagemanager = "Winget" } }

        Import-WinUtilPreferences

        $script:sync.preferences.theme | Should -Be "Light"
        $script:sync.preferences.packagemanager | Should -Be "Choco"
        $script:sync.preferences.language | Should -Be "en"
        $script:sync.FontScaleFactor | Should -Be 1.25
    }

    It "ignores invalid values in a hand-edited file" {
        $path = Join-Path (Join-Path $env:LocalAppData "winutil") "preferences.json"
        New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force | Out-Null
        '{ "theme": "Purple", "packagemanager": "npm", "language": "fr", "fontScale": 9 }' | Set-Content -LiteralPath $path
        $script:sync = @{ preferences = @{ theme = "Dark"; packagemanager = "Winget" } }

        Import-WinUtilPreferences

        $script:sync.preferences.theme | Should -Be "Dark"
        $script:sync.preferences.packagemanager | Should -Be "Winget"
        $script:sync.preferences.ContainsKey("language") | Should -BeFalse
        $script:sync.ContainsKey("FontScaleFactor") | Should -BeFalse
    }

    It "keeps the defaults when there is no file" {
        $script:sync = @{ preferences = @{ theme = "Dark"; packagemanager = "Winget" } }
        Import-WinUtilPreferences
        $script:sync.preferences.theme | Should -Be "Dark"
    }
}

Describe "Start-WinUtilGameServerLatencyTest" {
    It "lists regions fastest first and marks the ones that did not answer" {
        Mock Measure-WinUtilGameServerLatency {
            [pscustomobject]@{ Key = "AwsFrankfurt"; Name = "Frankfurt"; LatencyMs = 95 }
            [pscustomobject]@{ Key = "AwsBahrain"; Name = "Bahrain"; LatencyMs = 31 }
            [pscustomobject]@{ Key = "AwsUAE"; Name = "UAE"; LatencyMs = $null }
        }
        $script:sync = @{
            WPFGamingPingResult = [pscustomobject]@{ Text = "" }
            WPFGamingPing = [pscustomobject]@{ IsEnabled = $true }
        }

        Start-WinUtilGameServerLatencyTest

        $script:sync.WPFGamingPingResult.Text | Should -Be "Bahrain: 31 ms`nFrankfurt: 95 ms`nUAE: no response"
        $script:sync.WPFGamingPing.IsEnabled | Should -BeTrue
        Remove-Variable -Name sync -Scope Script
    }
}

Describe "Get-WinUtilGpuSensor" {
    It "returns nothing when nvidia-smi is not installed" {
        $previous = @($env:SystemRoot, $env:ProgramFiles)
        try {
            $env:SystemRoot = Join-Path $TestDrive "nowindows"
            $env:ProgramFiles = Join-Path $TestDrive "noprogramfiles"
            Get-WinUtilGpuSensor | Should -BeNullOrEmpty
        } finally {
            $env:SystemRoot, $env:ProgramFiles = $previous
        }
    }

    It "reads every value from one nvidia-smi line" {
        $sensor = ConvertFrom-WinUtilGpuSensorLine -Line "55, 12, 1200, 8192, 45.50, NVIDIA GeForce RTX 3060, Laptop"
        $sensor.TemperatureC | Should -Be "55"
        $sensor.LoadPercent | Should -Be "12"
        $sensor.MemoryUsedMB | Should -Be "1200"
        $sensor.MemoryTotalMB | Should -Be "8192"
        $sensor.PowerW | Should -Be 46
        $sensor.Name | Should -Be "NVIDIA GeForce RTX 3060, Laptop"
    }

    It "leaves values the card does not report empty" {
        $sensor = ConvertFrom-WinUtilGpuSensorLine -Line "61, 3, 500, 4096, [N/A], NVIDIA T600"
        $sensor.TemperatureC | Should -Be "61"
        $sensor.PowerW | Should -BeNullOrEmpty
    }

    It "returns nothing for empty output" {
        ConvertFrom-WinUtilGpuSensorLine -Line "" | Should -BeNullOrEmpty
    }
}

Describe "Get-WinUtilStartupApps" {
    BeforeAll {
        $script:runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        $script:approvedKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
    }

    BeforeEach {
        Mock Test-Path { $LiteralPath -in @($script:runKey, $script:approvedKey) }
        Mock Get-ItemProperty {
            [pscustomobject]@{
                PSPath = "provider path"
                Discord = "C:\Discord\Update.exe --processStart Discord.exe"
                Steam = "C:\Steam\steam.exe -silent"
                OneDrive = "C:\OneDrive\OneDrive.exe /background"
            }
        } -ParameterFilter { $LiteralPath -eq $script:runKey }
        Mock Get-ItemProperty {
            [pscustomobject]@{
                Discord = [byte[]](3, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8)
                Steam = [byte[]](2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            }
        } -ParameterFilter { $LiteralPath -eq $script:approvedKey }
    }

    It "lists every Run entry with its enabled state" {
        $apps = @(Get-WinUtilStartupApps)

        $apps.Name | Should -Be @("Discord", "Steam", "OneDrive")
        ($apps | Where-Object Name -eq "Discord").Enabled | Should -BeFalse
        ($apps | Where-Object Name -eq "Steam").Enabled | Should -BeTrue
        ($apps | Where-Object Name -eq "OneDrive").Enabled | Should -BeTrue
        ($apps | Where-Object Name -eq "Steam").Command | Should -Be "C:\Steam\steam.exe -silent"
        ($apps | Where-Object Name -eq "Steam").ApprovedKey | Should -Be $script:approvedKey
    }
}

Describe "Set-WinUtilStartupApp" {
    BeforeEach {
        $script:written = $null
        Mock Test-Path { $true }
        Mock New-ItemProperty { $script:written = $Value }
        $script:app = [pscustomobject]@{ Name = "Steam"; ValueName = "Steam"; ApprovedKey = "HKCU:\Approved\Run" }
    }

    It "records an enabled program as 02 followed by zeros" {
        Set-WinUtilStartupApp -App $script:app -Enabled $true

        $script:written.Length | Should -Be 12
        $script:written[0] | Should -Be 2
        ($script:written | Select-Object -Skip 1 | Where-Object { $_ -ne 0 }) | Should -BeNullOrEmpty
    }

    It "records a disabled program as 03 with the time it was disabled" {
        Set-WinUtilStartupApp -App $script:app -Enabled $false

        $script:written[0] | Should -Be 3
        $disabledAt = [DateTime]::FromFileTimeUtc([BitConverter]::ToInt64($script:written, 4))
        ([DateTime]::UtcNow - $disabledAt).TotalMinutes | Should -BeLessThan 5
        Should -Invoke New-ItemProperty -Times 1 -ParameterFilter { $LiteralPath -eq "HKCU:\Approved\Run" -and $Name -eq "Steam" }
    }
}

Describe "Get-WinUtilCpuSensor" {
    It "takes the hottest plausible thermal zone and the average load" {
        Mock Get-CimInstance {
            @([pscustomobject]@{ LoadPercentage = 20 }, [pscustomobject]@{ LoadPercentage = 31 })
        } -ParameterFilter { $ClassName -eq "Win32_Processor" }
        Mock Get-CimInstance {
            @(
                [pscustomobject]@{ HighPrecisionTemperature = 3182; Temperature = 318 },
                [pscustomobject]@{ HighPrecisionTemperature = 3332; Temperature = 333 },
                [pscustomobject]@{ HighPrecisionTemperature = 0; Temperature = 0 }
            )
        } -ParameterFilter { $ClassName -eq "Win32_PerfFormattedData_Counters_ThermalZoneInformation" }

        $sensor = Get-WinUtilCpuSensor

        $sensor.TemperatureC | Should -Be 60
        $sensor.LoadPercent | Should -Be 26
    }

    It "reports no temperature when the PC has no thermal zone" {
        Mock Get-CimInstance { [pscustomobject]@{ LoadPercentage = 5 } } -ParameterFilter { $ClassName -eq "Win32_Processor" }
        Mock Get-CimInstance { throw "Invalid class" } -ParameterFilter { $ClassName -eq "Win32_PerfFormattedData_Counters_ThermalZoneInformation" }

        $sensor = Get-WinUtilCpuSensor

        $sensor.TemperatureC | Should -BeNullOrEmpty
        $sensor.LoadPercent | Should -Be 5
    }
}

Describe "Format-WinUtilTemperatureReading" {
    It "shows both temperatures with their heat level" {
        $gpu = [pscustomobject]@{ TemperatureC = "84"; LoadPercent = "97"; MemoryUsedMB = "7000"; MemoryTotalMB = "8192"; PowerW = 160; Name = "RTX 3070" }
        $cpu = [pscustomobject]@{ TemperatureC = 55; LoadPercent = 40 }

        $reading = Format-WinUtilTemperatureReading -Gpu $gpu -Cpu $cpu

        $reading.GpuValue | Should -Be "84$([char]0x00B0)C"
        $reading.GpuLevel | Should -Be "Hot"
        $reading.GpuName | Should -Be "RTX 3070"
        $reading.GpuDetails | Should -Be "Load: 97%`nVideo memory: 7000 / 8192 MB`nPower: 160 W"
        $reading.CpuValue | Should -Be "55$([char]0x00B0)C"
        $reading.CpuLevel | Should -Be "Good"
        $reading.CpuDetails | Should -Be "Load: 40%"
    }

    It "explains what is missing without an NVIDIA card or a thermal zone" {
        $reading = Format-WinUtilTemperatureReading -Gpu $null -Cpu ([pscustomobject]@{ TemperatureC = $null; LoadPercent = 12 })

        $reading.GpuValue | Should -Be "--"
        $reading.GpuLevel | Should -Be "None"
        $reading.GpuStatus | Should -Be ""
        $reading.GpuDetails | Should -Match "NVIDIA"
        $reading.CpuValue | Should -Be "--"
        $reading.CpuDetails | Should -Match "^Load: 12%`n"
    }

    It "calls 70 degrees warm" {
        (Format-WinUtilTemperatureReading -Gpu ([pscustomobject]@{ TemperatureC = "70" }) -Cpu $null).GpuLevel | Should -Be "Warm"
    }
}
