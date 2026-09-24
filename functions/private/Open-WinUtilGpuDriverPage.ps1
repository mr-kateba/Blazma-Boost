function Open-WinUtilGpuDriverPage {
    <#
    .SYNOPSIS
        Opens the official driver download page for the detected graphics card vendor
    #>

    $url = switch ($sync.GamingGpuVendor) {
        "NVIDIA" { "https://www.nvidia.com/Download/index.aspx" }
        "AMD" { "https://www.amd.com/en/support/download/drivers.html" }
        "Intel" { "https://www.intel.com/content/www/us/en/support/detect.html" }
    }

    if ($url) {
        Write-WinUtilLog -Component "Gaming" -Message "Opening $($sync.GamingGpuVendor) driver page: $url"
        Start-Process $url
    }
}
