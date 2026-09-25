function Start-WinUtilSelfUpdate {
    <#
    .SYNOPSIS
        Replaces the running Blazma Boost with the latest release

    .DESCRIPTION
        Opens the latest release in a new Windows PowerShell window, the same way the one-line
        install command does, and closes this one. The new window inherits administrator rights
        from this process, so there is no second UAC prompt. Nothing happens while a job is
        running or when the user says no.
    #>

    if ($sync.ActiveJob) {
        Show-WinUtilMessage -Message "Wait for the current task to finish, then update." -Icon "Warning" | Out-Null
        return
    }

    $answer = Show-WinUtilMessage -Message "Blazma Boost will close and open the new version. Continue?" -Button "YesNo" -Icon "Question"
    if ("$answer" -ne "Yes") {
        return
    }

    $releaseUrl = "https://github.com/mr-kateba/Blazma-Boost/releases/latest/download/winutil.ps1"
    Write-WinUtilLog -Component "Update" -Message "Updating: starting $releaseUrl in a new window"
    Start-Process -FilePath "powershell.exe" -ArgumentList @(
        "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command",
        "[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; irm '$releaseUrl' | iex"
    )
    $sync.Form.Close()
}
