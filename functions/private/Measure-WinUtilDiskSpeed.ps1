function Measure-WinUtilDiskSpeed {
    <#
    .SYNOPSIS
        Measures a drive's read and write speed with Windows' own WinSAT disk test

    .DESCRIPTION
        winsat.exe ships with Windows. The disk test takes about a minute and writes only a
        temporary test file, which it removes. Returns $null when WinSAT is missing or its
        output cannot be read.

    .PARAMETER DriveLetter
        The drive to test, without the colon
    #>

    param([string]$DriveLetter = $env:SystemDrive.TrimEnd(':'))

    $winsat = Join-Path $env:SystemRoot "System32\winsat.exe"
    if (-not (Test-Path -LiteralPath $winsat)) {
        return $null
    }

    $output = & $winsat disk -drive $DriveLetter 2>&1 | Out-String
    ConvertFrom-WinUtilWinsatDiskOutput -Output $output
}

function ConvertFrom-WinUtilWinsatDiskOutput {
    <#
    .SYNOPSIS
        Reads the MB/s results out of the text winsat disk prints
    #>

    param([string]$Output)

    function Get-Speed([string]$Pattern) {
        $match = [regex]::Match($Output, "$Pattern\s+([\d.,]+)\s*MB/s")
        if ($match.Success) {
            # "2104.14", or "2104,14" where the decimal separator is a comma
            $number = $match.Groups[1].Value
            $number = if ($number.Contains('.')) { $number -replace ',', '' } else { $number -replace ',', '.' }
            [math]::Round([double]::Parse($number, [System.Globalization.CultureInfo]::InvariantCulture))
        }
    }

    $sequentialRead = Get-Speed "Sequential 64\.0 Read"
    if ($null -eq $sequentialRead) {
        return $null
    }

    [pscustomobject]@{
        SequentialReadMBs  = $sequentialRead
        SequentialWriteMBs = Get-Speed "Sequential 64\.0 Write"
        RandomReadMBs      = Get-Speed "Random 16\.0 Read"
    }
}
