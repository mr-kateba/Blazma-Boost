function Start-WinUtilUpdateCheck {
    <#
    .SYNOPSIS
        Shows the update banner when a newer Blazma Boost release exists

    .DESCRIPTION
        Asks the GitHub API for the latest release on the worker pool, so a slow or missing
        connection never holds the interface. Versions are the yy.MM.dd build dates the release
        workflow tags. Local builds are stamped with today's date and so never see a newer one.
    #>

    $null = Invoke-WPFRunspace -ScriptBlock {
        try {
            $latest = Invoke-RestMethod -Uri "https://api.github.com/repos/mr-kateba/Blazma-Boost/releases/latest" -TimeoutSec 10 -ErrorAction Stop
            $latestVersion = [version]$latest.tag_name
            $currentVersion = [version]$sync.version
        } catch {
            Write-WinUtilLog -Level "WARN" -Component "Update" -Message "Update check skipped: $($_.Exception.Message)"
            return
        }

        if ($latestVersion -le $currentVersion) {
            return
        }

        Write-WinUtilLog -Component "Update" -Message "A newer release is available: $($latest.tag_name) (running $($sync.version))"
        Invoke-WPFUIThread -Async -Parameters @{
            Text = (Get-WinUtilText -Key "UpdateAvailable" -Default "A new version of Blazma Boost is available: {0}") -f $latest.tag_name
        } -ScriptBlock {
            param($Text)
            $sync.WPFUpdateBannerText.Text = $Text
            $sync.WPFUpdateBanner.Visibility = "Visible"
        }
    }
}
