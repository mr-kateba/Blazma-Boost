function Disable-WinUtilConsoleQuickEdit {
    <#
    .SYNOPSIS
        Turns off QuickEdit mode in the console window WinUtil runs in

    .DESCRIPTION
        With QuickEdit on, one click inside the console starts a text selection ("Select" in the
        title bar) and Windows blocks every write to the console until it ends. The next log line
        then stops the running job, which looks like WinUtil hanging halfway through. Only this
        console session is changed, not the user's console defaults.
    #>

    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
        return
    }

    try {
        if (-not ("WinUtilConsoleMode" -as [type])) {
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class WinUtilConsoleMode
{
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetStdHandle(int nStdHandle);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);
}
"@
        }

        $STD_INPUT_HANDLE = -10
        $ENABLE_QUICK_EDIT_MODE = 0x0040
        $ENABLE_EXTENDED_FLAGS = 0x0080

        $handle = [WinUtilConsoleMode]::GetStdHandle($STD_INPUT_HANDLE)
        $mode = [uint32]0
        # No console (Windows Terminal hosts its own selection, or a redirected input) is fine
        if ([WinUtilConsoleMode]::GetConsoleMode($handle, [ref]$mode)) {
            $newMode = ($mode -band (-bnot $ENABLE_QUICK_EDIT_MODE)) -bor $ENABLE_EXTENDED_FLAGS
            [void][WinUtilConsoleMode]::SetConsoleMode($handle, [uint32]$newMode)
        }
    } catch {
        Write-WinUtilLog -Level "WARN" -Component "Console" -Message "Could not turn off QuickEdit mode: $($_.Exception.Message)"
    }
}
