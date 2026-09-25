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
        # Left-to-right marks keep English values such as "Windows 11 Pro (26200)" in order in the Arabic window
        $values = @($summary.Cpu, $summary.Gpu, $summary.GpuDriver, $summary.RamGB, $summary.Windows) | ForEach-Object { "$([char]0x200E)$_$([char]0x200E)" }
        Invoke-WPFUIThread -Async -Parameters @{
            Text = ($format -f $values)
            Vendor = $summary.GpuVendor
        } -ScriptBlock {
            param($Text, $Vendor)
            $sync.GamingGpuVendor = $Vendor
            $sync.WPFGamingSystemInfo.Text = $Text
            $sync.WPFGamingGPUDriver.IsEnabled = -not [string]::IsNullOrEmpty($Vendor)
        }
    }
}
