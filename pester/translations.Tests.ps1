#===========================================================================
# Tests - Arabic translations
#===========================================================================

BeforeAll {
    $script:repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilText.ps1")
    . (Join-Path $script:repoRoot "functions\private\Initialize-WinUtilTranslation.ps1")

    function script:Get-TranslationConfig {
        param([string]$Name)
        Get-Content -Path (Join-Path $script:repoRoot "config\$Name.json") -Raw -Encoding UTF8 | ConvertFrom-Json
    }
}

Describe "translations.json" {
    It "only translates entries that exist in their config" {
        $translations = Get-TranslationConfig -Name "translations"
        $stale = New-Object System.Collections.Generic.List[string]

        foreach ($section in $translations.PSObject.Properties) {
            if ($section.Name -in @("strings", "categories")) { continue }

            $config = Get-TranslationConfig -Name $section.Name
            foreach ($entry in $section.Value.PSObject.Properties) {
                if (@($config.PSObject.Properties.Name) -notcontains $entry.Name) {
                    $stale.Add("$($section.Name).$($entry.Name)")
                }
            }
        }

        if ($stale.Count -gt 0) {
            throw "Translations for missing entries (renamed or removed upstream?):`n$($stale -join "`n")"
        }
    }

    It "translates every tweak" {
        $translations = Get-TranslationConfig -Name "translations"
        $tweaks = Get-TranslationConfig -Name "tweaks"
        $missing = @($tweaks.PSObject.Properties.Name | Where-Object { @($translations.tweaks.PSObject.Properties.Name) -notcontains $_ })

        $missing | Should -BeNullOrEmpty
    }
}

Describe "Initialize-WinUtilTranslation" {
    BeforeEach {
        $script:sync = @{
            configs = @{
                tweaks = [pscustomobject]@{
                    WPFTweaksTelemetry = [pscustomobject]@{ Content = "Telemetry - Disable"; Description = "English" }
                }
                applications = [pscustomobject]@{
                    WPFInstallsteam = [pscustomobject]@{ content = "Steam"; description = "English" }
                }
                translations = [pscustomobject]@{
                    strings = [pscustomobject]@{ SelectedApps = "Selected: {0}!" }
                    categories = [pscustomobject]@{ Gaming = "Games tab" }
                    tweaks = [pscustomobject]@{
                        WPFTweaksTelemetry = [pscustomobject]@{ Content = "Translated"; Description = "Translated description" }
                        WPFTweaksRemoved = [pscustomobject]@{ Content = "Ignored" }
                    }
                    applications = [pscustomobject]@{
                        steam = [pscustomobject]@{ description = "Translated app" }
                    }
                }
            }
        }
    }

    AfterEach {
        Remove-Variable -Name sync -Scope Script -ErrorAction SilentlyContinue
    }

    It "replaces translated fields and skips entries the config does not have" {
        Initialize-WinUtilTranslation

        $script:sync.configs.tweaks.WPFTweaksTelemetry.Content | Should -Be "Translated"
        $script:sync.configs.tweaks.WPFTweaksTelemetry.Description | Should -Be "Translated description"
        $script:sync.configs.tweaks.PSObject.Properties.Name | Should -Not -Contain "WPFTweaksRemoved"
    }

    It "maps application keys to their compiled WPFInstall names" {
        Initialize-WinUtilTranslation

        $script:sync.configs.applications.WPFInstallsteam.description | Should -Be "Translated app"
        $script:sync.configs.applications.WPFInstallsteam.content | Should -Be "Steam"
    }

    It "returns translated strings and categories, falling back to the default" {
        Get-WinUtilText -Key "SelectedApps" -Default "Selected Apps: {0}" | Should -Be "Selected: {0}!"
        Get-WinUtilText -Section "categories" -Key "Gaming" | Should -Be "Games tab"
        Get-WinUtilText -Section "categories" -Key "Unknown" | Should -Be "Unknown"
        Get-WinUtilText -Key "Missing" -Default "Fallback" | Should -Be "Fallback"
    }
}
