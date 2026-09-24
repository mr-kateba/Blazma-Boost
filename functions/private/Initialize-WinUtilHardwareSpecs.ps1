function Initialize-WinUtilHardwareSpecs {
    <#
    .SYNOPSIS
        Fills the "My Specs" tab without holding the interface

    .DESCRIPTION
        The WMI and registry reads take a second or two, so they run on the worker pool and the
        text is posted back to the interface thread. Also used by the refresh button.
    #>

    $null = Invoke-WPFRunspace -ScriptBlock {
        try {
            $specs = Get-WinUtilHardwareSpecs
        } catch {
            Write-WinUtilLog -Level "WARN" -Component "Specs" -Message "Could not read hardware specs: $($_.Exception.Message)"
            return
        }

        Invoke-WPFUIThread -Async -Parameters @{ Specs = $specs } -ScriptBlock {
            param($Specs)
            $sync.WPFSpecsCPU.Text = $Specs.Cpu
            $sync.WPFSpecsGPU.Text = $Specs.Gpu
            $sync.WPFSpecsRAM.Text = $Specs.Ram
            $sync.WPFSpecsBoard.Text = $Specs.Board
            $sync.WPFSpecsStorage.Text = $Specs.Storage
            $sync.WPFSpecsWindows.Text = $Specs.Windows
        }

        # The driver check goes online, so it reports after the specs are already on screen
        $gpu = $Specs.PrimaryGpu
        $vendor = switch -Regex ([string]$gpu.Name) { 'NVIDIA' { "NVIDIA"; break } 'AMD|Radeon' { "AMD"; break } 'Intel' { "Intel"; break } default { "" } }
        $color = "#FFC83D"
        try {
            $status = Get-WinUtilGpuDriverStatus -Name $gpu.Name -DriverVersion $gpu.DriverVersion -DriverDate $gpu.DriverDate -IsNotebook:$Specs.IsNotebook
            switch ($status.Status) {
                "UpToDate" {
                    $text = (Get-WinUtilText -Key "DriverUpToDate" -Default "Your driver is up to date ({0}).") -f $status.Installed
                    $color = "#4CAF50"
                }
                "UpdateAvailable" {
                    $text = (Get-WinUtilText -Key "DriverUpdateAvailable" -Default "A driver update is available: {1} (you have {0}).") -f $status.Installed, $status.Latest
                    $color = "#FF6D00"
                }
                "Old" {
                    $text = (Get-WinUtilText -Key "DriverOld" -Default "Your driver is {0} days old, a newer one is probably available. Automatic checking is only available for NVIDIA cards.") -f $status.AgeDays
                    $color = "#FF6D00"
                }
                "Current" {
                    $text = (Get-WinUtilText -Key "DriverCurrent" -Default "Your driver is {0} days old. Automatic checking is only available for NVIDIA cards, use the button to make sure.") -f $status.AgeDays
                }
                default {
                    $text = Get-WinUtilText -Key "DriverUnknown" -Default "Could not tell whether a newer driver exists. Use the button to check the vendor page."
                }
            }
        } catch {
            Write-WinUtilLog -Level "WARN" -Component "Specs" -Message "GPU driver check failed: $($_.Exception.Message)"
            $text = Get-WinUtilText -Key "DriverCheckFailed" -Default "Could not check for a newer driver. Check your internet connection."
        }

        Invoke-WPFUIThread -Async -Parameters @{ Text = $text; Color = $color; Vendor = $vendor } -ScriptBlock {
            param($Text, $Color, $Vendor)
            if ($Vendor) { $sync.GamingGpuVendor = $Vendor }
            $sync.WPFSpecsDriverStatus.Text = $Text
            $sync.WPFSpecsDriverStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($Color)
            $sync.WPFSpecsDriverDownload.IsEnabled = -not [string]::IsNullOrEmpty($Vendor)
        }
    }
}
