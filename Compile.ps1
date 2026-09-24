param (
    [switch]$Run
)

$OFS = "`r`n"

# Variable to sync between runspaces
$sync = [Hashtable]::Synchronized(@{})
$sync.configs = @{}

# Arabic text in config and XAML is escaped so the compiled script stays pure ASCII. Windows
# PowerShell 5.1 and `irm | iex` both decode scripts with a legacy code page, which would
# otherwise turn every non-ASCII character into mojibake.
function ConvertTo-WinUtilAsciiJson([string]$Text) {
    [regex]::Replace($Text, '[^\x00-\x7F]', { param($m) '\u{0:x4}' -f [int][char]$m.Value })
}
function ConvertTo-WinUtilAsciiXml([string]$Text) {
    [regex]::Replace($Text, '[\uD800-\uDBFF][\uDC00-\uDFFF]|[^\x00-\x7F]', { param($m) '&#x{0:X};' -f [char]::ConvertToUtf32($m.Value, 0) })
}

# The release workflow passes its version (yy.MM.dd, or yy.MM.dd.N for a second release that day)
$version = if ($env:BLAZMA_VERSION) { $env:BLAZMA_VERSION } else { Get-Date -Format 'yy.MM.dd' }
$script = (Get-Content -Path scripts\start.ps1) -replace '#{replaceme}', $version
$isLocalCompile = -not [string]::Equals($env:GITHUB_ACTIONS, "true", [StringComparison]::OrdinalIgnoreCase)
$script = $script -replace '#{islocalcompile}', $isLocalCompile.ToString().ToLowerInvariant()

$script += Get-ChildItem -Path functions -Recurse -File | ForEach-Object {
    Get-Content -Path $_.FullName -Raw
}

Get-ChildItem config | ForEach-Object {
    $obj = Get-Content -Path $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json

    if ($_.Name -eq "applications.json") {
        $fixed = [ordered]@{}
        foreach ($p in $obj.PSObject.Properties) {
            $fixed["WPFInstall$($p.Name)"] = $p.Value
        }
        $obj = [pscustomobject]$fixed
    }

    $json = ConvertTo-WinUtilAsciiJson ($obj | ConvertTo-Json -Depth 10)

    $sync.configs[$_.BaseName] = $obj
    $script += "`$sync.configs.$($_.BaseName) = @'`r`n$json`r`n'@ | ConvertFrom-Json"
}

$xaml = ConvertTo-WinUtilAsciiXml (Get-Content -Path xaml\inputXML.xaml -Raw -Encoding UTF8)
$script += "`$inputXML = @'`r`n$xaml`r`n'@"

$autounattendXml = Get-Content -Path tools\autounattend.xml -Raw
$script += "`$WinUtilAutounattendXml = @'`r`n$autounattendXml`r`n'@"

$script += Get-Content -Path scripts\main.ps1 -Raw

Set-Content -Path winutil.ps1 -Value $script

if ($Run) {
    .\Winutil.ps1
}
