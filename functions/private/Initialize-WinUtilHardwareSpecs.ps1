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
    }
}
