function Get-WinUtilDiskHealth {
    <#
    .SYNOPSIS
        Reads the health, temperature, wear and power-on hours of every physical disk

    .DESCRIPTION
        Reads MSFT_PhysicalDisk for the type and Windows' health verdict, and its associated
        MSFT_StorageReliabilityCounter for the SMART values (the classes behind Get-PhysicalDisk and
        Get-StorageReliabilityCounter). A drive that does not report a value (many USB drives and
        older disks) gets $null for it.
    #>

    $namespace = "root\Microsoft\Windows\Storage"
    foreach ($disk in @(Get-CimInstance -Namespace $namespace -ClassName MSFT_PhysicalDisk -ErrorAction Stop)) {
        $counter = $null
        try {
            $counter = Get-CimAssociatedInstance -InputObject $disk -ResultClassName MSFT_StorageReliabilityCounter -ErrorAction Stop | Select-Object -First 1
        } catch {
            Write-Verbose "No reliability counters for $($disk.FriendlyName): $($_.Exception.Message)"
        }

        # The raw CIM class gives numbers; the Storage cmdlets' formatting would give names
        $media = switch ("$($disk.MediaType)") { { $_ -in "SSD", "4" } { "SSD" } { $_ -in "HDD", "3" } { "HDD" } default { "" } }
        $bus = switch ("$($disk.BusType)") { { $_ -in "NVMe", "17" } { "NVMe" } { $_ -in "SATA", "11" } { "SATA" } { $_ -in "USB", "7" } { "USB" } default { "" } }
        $health = switch ("$($disk.HealthStatus)") { { $_ -in "Healthy", "0" } { "Healthy" } { $_ -in "Warning", "1" } { "Warning" } { $_ -in "Unhealthy", "2" } { "Unhealthy" } default { "Unknown" } }

        [pscustomobject]@{
            Name         = ([string]$disk.FriendlyName).Trim()
            Kind         = if ($media -eq "SSD" -and $bus -eq "NVMe") { "NVMe SSD" } else { ("$bus $media").Trim() }
            SizeGB       = [math]::Round([double]$disk.Size / 1GB)
            Health       = $health
            TemperatureC = if ($counter -and $counter.Temperature) { [int]$counter.Temperature } else { $null }
            WearPercent  = if ($counter -and $media -eq "SSD" -and $null -ne $counter.Wear) { [int]$counter.Wear } else { $null }
            PowerOnHours = if ($counter -and $counter.PowerOnHours) { [int]$counter.PowerOnHours } else { $null }
        }
    }
}
