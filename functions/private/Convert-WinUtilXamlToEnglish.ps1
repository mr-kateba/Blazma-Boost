function Convert-WinUtilXamlToEnglish {
    <#
    .SYNOPSIS
        Switches the parsed window XAML to English when the user picked English

    .DESCRIPTION
        The XAML is written in Arabic. The "english" section of translations.json maps each Arabic
        text in it to its English text; attributes and text nodes whose (whitespace-normalized)
        value is in the map are replaced. The window is laid out left to right again, which also
        means the Win11 Creator back and forward arrows swap back, and the language menu item
        offers Arabic instead of English.

    .PARAMETER Xaml
        The parsed window XAML, before it is loaded
    #>

    param([Parameter(Mandatory)][xml]$Xaml)

    if ($sync.preferences.language -ne "en") {
        return
    }

    $english = @{}
    if ($sync.configs.translations -and $sync.configs.translations.english) {
        foreach ($entry in $sync.configs.translations.english.PSObject.Properties) {
            $english[$entry.Name] = [string]$entry.Value
        }
    }

    foreach ($node in @($Xaml.SelectNodes("//@* | //text()"))) {
        $value = $node.Value
        if ([string]::IsNullOrWhiteSpace($value)) {
            continue
        }
        # Attributes keep their padding (" Standard "); text nodes are laid out across lines
        $key = if ($node.NodeType -eq [System.Xml.XmlNodeType]::Attribute) { $value } else { ($value -replace '\s+', ' ').Trim() }
        if ($english.ContainsKey($key)) {
            $node.Value = $english[$key]
        }
    }

    $Xaml.DocumentElement.SetAttribute("FlowDirection", "LeftToRight")

    $back = [string][char]0xE76C
    $forward = [string][char]0xE76B
    foreach ($button in @($Xaml.SelectNodes("//*[@Name='WPFWin11ISOBackButton' or @Name='WPFWin11ISOForwardButton']"))) {
        $button.SetAttribute("Content", $(if ($button.GetAttribute("Content") -eq $back) { $forward } else { $back }))
    }

    # The menu item carries its Arabic label in Tag, so no Arabic lives in this file
    $languageItem = $Xaml.SelectSingleNode("//*[@Name='LanguageMenuItem']")
    if ($languageItem) {
        $languageItem.SetAttribute("Header", $languageItem.GetAttribute("Tag"))
    }
}
