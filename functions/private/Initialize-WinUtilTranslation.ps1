function Initialize-WinUtilTranslation {
    <#
    .SYNOPSIS
        Applies config/translations.json on top of the loaded configs

    .DESCRIPTION
        Every section of translations.json named after a config (tweaks, feature, applications,
        appnavigation, ...) maps entry keys to the fields to replace, usually Content and
        Description. Keeping translations out of the upstream config files means the English
        sources can still be merged from WinUtil without conflicts.
    #>

    $translations = $sync.configs.translations
    if ($null -eq $translations) {
        return
    }

    foreach ($section in $translations.PSObject.Properties) {
        $config = $sync.configs[$section.Name]
        if ($section.Name -in @("strings", "categories") -or $null -eq $config) {
            continue
        }

        foreach ($entry in $section.Value.PSObject.Properties) {
            # applications.json keys gain the WPFInstall prefix when compiled
            $targetName = if ($section.Name -eq "applications") { "WPFInstall$($entry.Name)" } else { $entry.Name }
            $target = $config.$targetName
            if ($null -eq $target) {
                continue
            }

            foreach ($field in $entry.Value.PSObject.Properties) {
                $existing = $target.PSObject.Properties[$field.Name]
                if ($existing) {
                    $existing.Value = $field.Value
                } else {
                    $target | Add-Member -NotePropertyName $field.Name -NotePropertyValue $field.Value
                }
            }
        }
    }
}
