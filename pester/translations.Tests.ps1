#===========================================================================
# Tests - Arabic translations
#===========================================================================

BeforeAll {
    $script:repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilText.ps1")
    . (Join-Path $script:repoRoot "functions\private\Initialize-WinUtilTranslation.ps1")
    . (Join-Path $script:repoRoot "functions\private\Get-WinUtilMessageText.ps1")

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
            if ($section.Name -in @("strings", "categories", "messages")) { continue }

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

    It "points tweak help links at the Arabic guide" {
        $script:sync.configs.tweaks.WPFTweaksTelemetry | Add-Member -NotePropertyName link -NotePropertyValue "https://winutil.christitus.com/x"
        $script:sync.configs.translations.strings | Add-Member -NotePropertyName GuideUrl -NotePropertyValue "https://example.com/guide.md"

        Initialize-WinUtilTranslation

        $script:sync.configs.tweaks.WPFTweaksTelemetry.link | Should -Be "https://example.com/guide.md#wpftweakstelemetry"
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

Describe "Arabic guide" {
    It "is up to date with the configs (run tools\Build-ArabicGuide.ps1 after changing them)" {
        $generated = Join-Path $TestDrive "tweaks.md"
        & (Join-Path $script:repoRoot "tools\Build-ArabicGuide.ps1") -OutputPath $generated

        # Git may check the guide out with CRLF line endings on Windows; only the content matters
        $expected = (Get-Content -Path (Join-Path $script:repoRoot "docs-ar\tweaks.md") -Raw -Encoding UTF8) -replace "`r`n", "`n"
        $actual = (Get-Content -Path $generated -Raw -Encoding UTF8) -replace "`r`n", "`n"
        $actual | Should -BeExactly $expected
    }

    It "has a section for every tweak with a help link" {
        $guide = Get-Content -Path (Join-Path $script:repoRoot "docs-ar\tweaks.md") -Raw -Encoding UTF8
        $tweaks = Get-TranslationConfig -Name "tweaks"
        $missing = @($tweaks.PSObject.Properties | Where-Object { $_.Value.link } |
            Where-Object { $guide -notmatch "<a id=`"$($_.Name.ToLowerInvariant())`"></a>" } | ForEach-Object Name)

        $missing | Should -BeNullOrEmpty
    }
}

Describe "Get-WinUtilMessageText" {
    BeforeEach {
        $script:sync = @{
            configs = @{
                translations = [pscustomobject]@{
                    messages = [pscustomobject]@{
                        "No toggles are selected." = "Arabic exact"
                        "ISO export failed:`n`n{0}" = "Arabic failed:`n`n{0}"
                        "ALL data on Disk {0} ({1}, {2} GB) will be PERMANENTLY ERASED." = "Arabic disk {0} {1} {2}"
                        "{0} is still running" = "Arabic running {0}"
                    }
                }
            }
        }
    }

    AfterEach {
        Remove-Variable -Name sync -Scope Script -ErrorAction SilentlyContinue
    }

    It "prefers an exact match" {
        Get-WinUtilMessageText -Text "No toggles are selected." | Should -Be "Arabic exact"
    }

    It "fills a template with the parts of the English message" {
        Get-WinUtilMessageText -Text "ISO export failed:`n`nAccess is denied." | Should -Be "Arabic failed:`n`nAccess is denied."
        Get-WinUtilMessageText -Text "ALL data on Disk 2 (SanDisk Ultra, 32 GB) will be PERMANENTLY ERASED." | Should -Be "Arabic disk 2 SanDisk Ultra 32"
    }

    It "does not let a short template swallow a longer message" {
        Get-WinUtilMessageText -Text "Tweaks is still running. Wait for it to finish." | Should -Be "Tweaks is still running. Wait for it to finish."
        Get-WinUtilMessageText -Text "Tweaks is still running" | Should -Be "Arabic running Tweaks"
    }

    It "returns untranslated and empty text unchanged" {
        Get-WinUtilMessageText -Text "Something new" | Should -Be "Something new"
        Get-WinUtilMessageText -Text "" | Should -Be ""
    }
}
