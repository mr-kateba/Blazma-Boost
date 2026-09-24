function Invoke-WPFGamingOneClick {
    <#
    .SYNOPSIS
        Selects the recommended gaming tweaks plus a restore point, then applies them

    .DESCRIPTION
        Uses the same selection and apply path as the buttons, so the restore point is taken
        first, the run shows on the progress bar and every tweak can be undone afterwards.
        Other tweaks the user already selected are applied with them.
    #>

    Invoke-WPFPresets "Gaming" -checkboxfilterpattern "WPFTweaksGaming*"
    Invoke-WPFPresets -preset @("WPFTweaksRestorePoint") -imported $true -checkboxfilterpattern "WPFTweaksRestorePoint"
    Invoke-WPFtweaksbutton
}
