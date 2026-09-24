function Get-WinUtilGpuDriverStatus {
    <#
    .SYNOPSIS
        Tells whether a newer graphics driver is available for the given card

    .DESCRIPTION
        NVIDIA: the card name is mapped to NVIDIA's product family id (pfid) with the public
        domain ZenitH-AT/nvidia-data list, then NVIDIA's driver lookup service returns the newest
        driver version. This is the same approach TinyNvidiaUpdateChecker uses.

        AMD and Intel publish no such service, so only the age of the installed driver is
        reported and the user is pointed at the vendor page.

        Status is "UpToDate", "UpdateAvailable", "Old", "Current" (AMD/Intel, recent driver)
        or "Unknown".

    .PARAMETER Name
        Win32_VideoController.Name

    .PARAMETER DriverVersion
        Win32_VideoController.DriverVersion, e.g. 32.0.15.6094 (NVIDIA 560.94)

    .PARAMETER DriverDate
        Win32_VideoController.DriverDate
    #>
    param(
        [string]$Name,
        [string]$DriverVersion,
        $DriverDate,
        [switch]$IsNotebook
    )

    $result = [pscustomobject]@{ Status = "Unknown"; Installed = $DriverVersion; Latest = $null; AgeDays = $null }
    if ($DriverDate) {
        $result.AgeDays = [int]((Get-Date) - [datetime]$DriverDate).TotalDays
    }

    if ($Name -notmatch '^NVIDIA') {
        if ($null -ne $result.AgeDays) {
            $result.Status = if ($result.AgeDays -gt 180) { "Old" } else { "Current" }
        }
        return $result
    }

    # NVIDIA's own version is the last five digits of the Windows one: 32.0.15.6094 -> 560.94
    $digits = $DriverVersion -replace '\D', ''
    if ($digits.Length -lt 5) {
        return $result
    }
    $installed = $digits.Substring($digits.Length - 5).Insert(3, ".")
    $result.Installed = $installed

    # "NVIDIA GeForce RTX 3070 Ti Laptop GPU (8GB)" -> the name NVIDIA's lookup list uses
    $label = ($Name -replace '^NVIDIA\s+', '' -replace '\s+\(.*$', '' -replace '\s+\d+GB.*$', '' -replace '\s+with Max-Q Design.*$', '' -replace '\s+COLLECTORS EDITION.*$', '').Trim()
    $label = $label -creplace 'Super', 'SUPER'

    $gpuData = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/ZenitH-AT/nvidia-data/main/gpu-data.json" -TimeoutSec 15 -ErrorAction Stop
    $lists = if ($IsNotebook) { @($gpuData.notebook, $gpuData.desktop) } else { @($gpuData.desktop, $gpuData.notebook) }
    $productFamily = @($lists | ForEach-Object { $_.$label } | Where-Object { $_ })[0]
    if (-not $productFamily) {
        return $result
    }

    # NVIDIA's operating system ids: 135 is Windows 11, 57 is Windows 10 64-bit
    $osId = if ([Environment]::OSVersion.Version.Build -ge 22000) { 135 } else { 57 }
    $lookup = "https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php" +
        "?func=DriverManualLookup&pfid=$productFamily&osID=$osId&dch=1&numberOfResults=10&languageCode=1033"
    $response = Invoke-RestMethod -Uri $lookup -TimeoutSec 15 -ErrorAction Stop
    if ($response -is [string]) {
        $response = $response | ConvertFrom-Json
    }
    if ([int]$response.Success -le 0) {
        return $result
    }

    $latest = @($response.IDS | ForEach-Object { [version]$_.downloadInfo.Version } | Sort-Object -Descending)[0]
    if (-not $latest) {
        return $result
    }

    $result.Latest = "{0}.{1:00}" -f $latest.Major, $latest.Minor
    $result.Status = if ($latest -gt [version]$installed) { "UpdateAvailable" } else { "UpToDate" }
    return $result
}
