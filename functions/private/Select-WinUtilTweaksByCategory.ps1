function Select-WinUtilTweaksByCategory {
    <#
    .SYNOPSIS
        Returns the tweaks config limited to, or without, one category

    .DESCRIPTION
        The Gaming tab shows the "Gaming" tweaks and the Tweaks tab shows everything else. Both
        keep reading from config/tweaks.json, so applying, undoing, presets and "Get Installed
        Tweaks" work the same for every entry.

    .PARAMETER Category
        The category to select

    .PARAMETER Exclude
        Return every entry except the ones in Category
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Category,

        [switch]$Exclude
    )

    $selected = [ordered]@{}
    foreach ($entry in $sync.configs.tweaks.PSObject.Properties) {
        if (($entry.Value.category -eq $Category) -ne [bool]$Exclude) {
            $selected[$entry.Name] = $entry.Value
        }
    }
    return [pscustomobject]$selected
}
