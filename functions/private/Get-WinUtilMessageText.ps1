function Get-WinUtilMessageText {
    <#
    .SYNOPSIS
        Translates a message box text through translations.json "messages"

    .DESCRIPTION
        An exact key match wins. Otherwise keys with {0}, {1} ... placeholders are tried as
        templates, so messages that carry a file path or an error still get translated with those
        parts kept as they are. Text without a translation is returned unchanged.
    #>
    param([string]$Text)

    if ([string]::IsNullOrEmpty($Text)) {
        return $Text
    }

    $translated = Get-WinUtilText -Section "messages" -Key $Text -Default ""
    if ($translated) {
        return $translated
    }

    $messages = if ($null -ne $sync -and $null -ne $sync.configs -and $null -ne $sync.configs.translations) { $sync.configs.translations.messages }
    if ($null -eq $messages) {
        return $Text
    }

    foreach ($entry in $messages.PSObject.Properties) {
        if ($entry.Name -notmatch '\{\d+\}') {
            continue
        }
        # [regex]::Escape turns {0} into \{0}, which becomes a lazy group for that placeholder
        $pattern = '^' + ([regex]::Escape($entry.Name) -replace '\\\{(\d+)\}', '(?<p$1>[\s\S]*?)') + '$'
        $match = [regex]::Match($Text, $pattern)
        if ($match.Success) {
            $values = @(0..9 | Where-Object { $match.Groups["p$_"].Success } | ForEach-Object { $match.Groups["p$_"].Value })
            return ($entry.Value -f $values)
        }
    }
    return $Text
}
