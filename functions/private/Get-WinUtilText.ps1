function Get-WinUtilText {
    <#
    .SYNOPSIS
        Returns the translated text for a key, or the given default when there is none

    .DESCRIPTION
        Looks the key up in a section of config/translations.json. Code keeps its English text as
        the default so it still reads correctly when no translation is loaded, as in tests.

    .PARAMETER Section
        The translations section to read from, such as "strings" or "categories"

    .PARAMETER Key
        The key of the text inside the section

    .PARAMETER Default
        The text to return when the key has no translation

    .EXAMPLE
        Get-WinUtilText -Section "categories" -Key "Essential Tweaks" -Default "Essential Tweaks"
    #>
    param(
        [string]$Section = "strings",
        [Parameter(Mandatory)]
        [string]$Key,
        [string]$Default = $Key
    )

    $translations = if ($null -ne $sync -and $null -ne $sync.configs) { $sync.configs.translations }
    if ($null -eq $translations -or $null -eq $translations.$Section) {
        return $Default
    }

    $text = $translations.$Section.$Key
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $Default
    }
    return $text
}
