function Open-WinUtilGpuDriverUpdater {
    <#
    .SYNOPSIS
        Opens the graphics vendor's own updater, or its download page when it is not installed

    .DESCRIPTION
        NVIDIA cards open the NVIDIA App (or the older GeForce Experience) and AMD cards open
        AMD Software: Adrenalin Edition, since those apps know the right driver for the exact card
        and install it in one click. When the app is missing, its official download page opens
        instead. Intel has no such app to rely on, so its driver page opens.
    #>

    function Find-VendorApp([string]$Folder, [string]$FileName) {
        foreach ($root in @($env:ProgramFiles, ${env:ProgramFiles(x86)}) | Where-Object { $_ }) {
            $path = Join-Path $root $Folder
            if (Test-Path -LiteralPath $path) {
                $app = Get-ChildItem -LiteralPath $path -Filter $FileName -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($app) { return $app.FullName }
            }
        }
    }

    $vendor = $sync.GamingGpuVendor
    $app = $null
    $fallback = $null
    switch ($vendor) {
        "NVIDIA" {
            $app = Find-VendorApp "NVIDIA Corporation\NVIDIA App" "NVIDIA App.exe"
            if (-not $app) { $app = Find-VendorApp "NVIDIA Corporation\NVIDIA GeForce Experience" "NVIDIA GeForce Experience.exe" }
            $fallback = "https://www.nvidia.com/en-us/software/nvidia-app/"
        }
        "AMD" {
            $app = Find-VendorApp "AMD\CNext\CNext" "RadeonSoftware.exe"
            $fallback = "https://www.amd.com/en/support/download/drivers.html"
        }
        "Intel" {
            $fallback = "https://www.intel.com/content/www/us/en/support/detect.html"
        }
        default {
            return
        }
    }

    if ($app) {
        Write-WinUtilLog -Component "Gaming" -Message "Opening the $vendor driver app: $app"
        Start-Process -FilePath $app
    } else {
        Write-WinUtilLog -Component "Gaming" -Message "No $vendor driver app found, opening $fallback"
        Start-Process -FilePath $fallback
    }
}
