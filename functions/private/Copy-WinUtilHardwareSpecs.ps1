function Copy-WinUtilHardwareSpecs {
    <#
    .SYNOPSIS
        Copies the "My Specs" tab to the clipboard, with its section headings, for sharing
    #>

    $sections = foreach ($name in @("CPU", "GPU", "RAM", "Board", "Storage", "Windows")) {
        "[$($sync["WPFSpecs$($name)Header"].Content)]`r`n$($sync["WPFSpecs$name"].Text -replace "`r?`n", "`r`n")"
    }
    Set-Clipboard -Value ($sections -join "`r`n`r`n")
    Write-WinUtilLog -Component "Specs" -Message "Copied hardware specs to the clipboard."
}
