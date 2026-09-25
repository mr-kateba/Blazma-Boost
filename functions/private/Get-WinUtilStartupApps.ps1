function Get-WinUtilStartupApps {
    <#
    .SYNOPSIS
        Lists the programs that start with Windows and whether each one is enabled

    .DESCRIPTION
        Reads the same places Task Manager's Startup page does: the Run keys for the current user
        and the machine (64-bit and 32-bit), the user and common Startup folders, and Microsoft
        Store apps' startup tasks. Task Manager records enabled/disabled for the first ones under
        Explorer\StartupApproved; an entry with no record there is enabled, and an odd first byte
        means disabled. A Store app keeps its own State value (2 enabled, 0 or 1 disabled; 3 and 4
        are set by policy and left out). Scheduled tasks that run at sign-in are added too
        (Get-WinUtilStartupTasks).
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
                Kind = "Approved"
                Name = $entry.DisplayName
                ValueName = $entry.ValueName
                Command = $entry.Command
                ApprovedKey = $source.Approved
                Enabled = -not ($state -is [byte[]] -and $state.Length -gt 0 -and ($state[0] -band 1))
            }
        }
    }
    # Microsoft Store apps: one key per package, one subkey per startup task
    $storeRoot = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData"
    if (Test-Path -LiteralPath $storeRoot) {
        foreach ($package in @(Get-ChildItem -LiteralPath $storeRoot -ErrorAction SilentlyContinue)) {
            foreach ($task in @(Get-ChildItem -LiteralPath $package.PSPath -ErrorAction SilentlyContinue)) {
                $state = (Get-ItemProperty -LiteralPath $task.PSPath -ErrorAction SilentlyContinue).State
                if ($null -eq $state -or [int]$state -notin 0, 1, 2) {
                    continue
                }
                # "SpotifyAB.SpotifyMusic_zpdnekdrzrea0" -> "SpotifyMusic"
                $packageName = ($package.PSChildName -split "_")[0]
                [pscustomobject]@{
                    Kind     = "Store"
                    Name     = ($packageName -split "\.")[-1]
                    Command  = $packageName
                    StateKey = $task.PSPath
                    Enabled  = [int]$state -eq 2
                }
            }
        }
    }

    try {
        Get-WinUtilStartupTasks
    } catch {
        Write-WinUtilLog -Level "WARN" -Component "Startup" -Message "Could not read scheduled tasks: $($_.Exception.Message)"
    }
}
