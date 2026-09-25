function Get-WinUtilStartupApps {
    <#
    .SYNOPSIS
        Lists the programs that start with Windows and whether each one is enabled

    .DESCRIPTION
        Reads the same places Task Manager's Startup page does: the Run keys for the current user
        and the machine (64-bit and 32-bit) and the user and common Startup folders. Task Manager
        records enabled/disabled under Explorer\StartupApproved; an entry with no record there is
        enabled, and an odd first byte means disabled.
    #>

    $approvedRoot = "Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved"
    $sources = @(
        @{ Kind = "Registry"; Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"; Approved = "HKCU:\$approvedRoot\Run" },
        @{ Kind = "Registry"; Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; Approved = "HKLM:\$approvedRoot\Run" },
        @{ Kind = "Registry"; Path = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"; Approved = "HKLM:\$approvedRoot\Run32" },
        @{ Kind = "Folder"; Path = [Environment]::GetFolderPath("Startup"); Approved = "HKCU:\$approvedRoot\StartupFolder" },
        @{ Kind = "Folder"; Path = [Environment]::GetFolderPath("CommonStartup"); Approved = "HKLM:\$approvedRoot\StartupFolder" }
    )
    $providerProperties = @("PSPath", "PSParentPath", "PSChildName", "PSDrive", "PSProvider")

    foreach ($source in $sources) {
        if ([string]::IsNullOrEmpty($source.Path) -or -not (Test-Path -LiteralPath $source.Path)) {
            continue
        }

        $entries = if ($source.Kind -eq "Registry") {
            $values = Get-ItemProperty -LiteralPath $source.Path -ErrorAction SilentlyContinue
            if ($values) {
                foreach ($property in $values.PSObject.Properties) {
                    if ($providerProperties -notcontains $property.Name) {
                        @{ ValueName = $property.Name; DisplayName = $property.Name; Command = [string]$property.Value }
                    }
                }
            }
        } else {
            foreach ($file in @(Get-ChildItem -LiteralPath $source.Path -File -ErrorAction SilentlyContinue)) {
                if ($file.Name -ne "desktop.ini") {
                    @{ ValueName = $file.Name; DisplayName = $file.BaseName; Command = $file.FullName }
                }
            }
        }

        $approved = if (Test-Path -LiteralPath $source.Approved) {
            Get-ItemProperty -LiteralPath $source.Approved -ErrorAction SilentlyContinue
        }

        foreach ($entry in @($entries)) {
            # Assigned directly: an if statement's output would unroll the byte array
            $state = $null
            if ($approved) {
                $state = $approved.($entry.ValueName)
            }
            [pscustomobject]@{
                Name = $entry.DisplayName
                ValueName = $entry.ValueName
                Command = $entry.Command
                ApprovedKey = $source.Approved
                Enabled = -not ($state -is [byte[]] -and $state.Length -gt 0 -and ($state[0] -band 1))
            }
        }
    }
}
