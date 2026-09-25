function Initialize-WinUtilStartupApps {
    <#
    .SYNOPSIS
        Fills the Gaming tab's startup programs card with one checkbox per program

    .DESCRIPTION
        The list is read on the worker pool and posted back to the interface thread. Ticking or
        clearing a checkbox enables or disables that program straight away; if the change cannot
        be written the checkbox goes back and the reason is shown.
    #>

    $sync.WPFStartupAppsStatus.Text = Get-WinUtilText -Key "StartupAppsLoading" -Default "Reading startup programs..."
    $sync.WPFStartupAppsList.Children.Clear()

    $null = Invoke-WPFRunspace -ScriptBlock {
        try {
            $apps = @(Get-WinUtilStartupApps | Sort-Object Name)
        } catch {
            Write-WinUtilLog -Level "WARN" -Component "Startup" -Message "Could not read startup programs: $($_.Exception.Message)"
            $apps = @()
        }

        $status = if ($apps.Count -eq 0) {
            Get-WinUtilText -Key "StartupAppsEmpty" -Default "No programs start with Windows."
        } else {
            (Get-WinUtilText -Key "StartupAppsCount" -Default "{0} programs start with Windows. Clear the ones you do not need so Windows starts faster.") -f $apps.Count
        }

        Invoke-WPFUIThread -Async -Parameters @{ Apps = $apps; Status = $status } -ScriptBlock {
            param($Apps, $Status)
            $sync.WPFStartupAppsStatus.Text = $Status
            $sync.WPFStartupAppsList.Children.Clear()

            foreach ($app in $Apps) {
                $checkBox = New-Object System.Windows.Controls.CheckBox
                $checkBox.Content = switch ($app.Kind) {
                    "Store" { (Get-WinUtilText -Key "StartupKindStore" -Default "{0} (Store app)") -f $app.Name }
                    "Task" { (Get-WinUtilText -Key "StartupKindTask" -Default "{0} (scheduled task)") -f $app.Name }
                    default { $app.Name }
                }
                $checkBox.ToolTip = $app.Command
                $checkBox.IsChecked = $app.Enabled
                $checkBox.Tag = $app
                $checkBox.Margin = "5,2"
                $checkBox.Add_Click({
                    $enabled = [bool]$this.IsChecked
                    try {
                        Set-WinUtilStartupApp -App $this.Tag -Enabled $enabled
                    } catch {
                        $this.IsChecked = -not $enabled
                        $format = Get-WinUtilText -Key "StartupAppsFailed" -Default "Could not change {0}: {1}"
                        $sync.WPFStartupAppsStatus.Text = $format -f $this.Tag.Name, $_.Exception.Message
                    }
                })
                $null = $sync.WPFStartupAppsList.Children.Add($checkBox)
            }
        }
    }
}
