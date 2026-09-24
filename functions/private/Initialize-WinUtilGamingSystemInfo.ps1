function Initialize-WinUtilGamingSystemInfo {
    <#
    .SYNOPSIS
        Fills the Gaming tab's system information panel without holding the interface

    .DESCRIPTION
        The WMI queries take about a second, so they run on the worker pool and the result is
        posted back to the interface thread. The GPU driver button is enabled once the vendor is
        known.
    #>

    $null = Invoke-WPFRunspace -ScriptBlock {
        try {
            $summary = Get-WinUtilSystemSummary
        } catch {
            Write-WinUtilLog -Level "WARN" -Component "Gaming" -Message "Could not read system information: $($_.Exception.Message)"
            return
        }

        $format = Get-WinUtilText -Key "SystemSummary" -Default "CPU: {0}`nGPU: {1} (driver {2})`nRAM: {3} GB`nWindows: {4}"
        Invoke-WPFUIThread -Async -Parameters @{
            Text = ($format -f $summary.Cpu, $summary.Gpu, $summary.GpuDriver, $summary.RamGB, $summary.Windows)
            Vendor = $summary.GpuVendor
        } -ScriptBlock {
            param($Text, $Vendor)
            $sync.GamingGpuVendor = $Vendor
            $sync.WPFGamingSystemInfo.Text = $Text
            $sync.WPFGamingGPUDriver.IsEnabled = -not [string]::IsNullOrEmpty($Vendor)
        }
    }
}
