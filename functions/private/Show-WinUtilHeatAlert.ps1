function Show-WinUtilHeatAlert {
    <#
    .SYNOPSIS
        Tells the user their PC is running hot, even while a game has the screen

    .DESCRIPTION
        Shows a Windows notification. Windows PowerShell can reach the notification API; where it
        cannot (PowerShell 7), the taskbar button gets the warning overlay and the warning sound
        plays instead. Runs on the interface thread.

    .PARAMETER Message
        What is hot and how hot it is
    #>

    param([Parameter(Mandatory)][string]$Message)

    $title = Get-WinUtilText -Key "TempsHotAlertTitle" -Default "Your PC is running hot"
    Write-WinUtilLog -Level "WARN" -Component "Temps" -Message "$title`: $Message"

    try {
        $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
        $null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
        $escape = [System.Security.SecurityElement]
        $xml = [Windows.Data.Xml.Dom.XmlDocument]::new()
        $xml.LoadXml("<toast><visual><binding template=`"ToastGeneric`"><text>$($escape::Escape($title))</text><text>$($escape::Escape($Message))</text></binding></visual></toast>")
        # Windows PowerShell's own application id, so the notification needs no registration
        $appId = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show([Windows.UI.Notifications.ToastNotification]::new($xml))
    } catch {
        Write-Verbose "Windows notifications are not available here: $($_.Exception.Message)"
        Set-WinUtilTaskbaritem -overlay "warning"
        try {
            [System.Media.SystemSounds]::Exclamation.Play()
        } catch {
            Write-Verbose "Could not play the warning sound: $($_.Exception.Message)"
        }
    }
}
