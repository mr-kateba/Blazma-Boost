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

# Arabic letters (U+0600-U+06FF) become "~" and two hex digits instead of a six-character \u
# escape, which halves the size of the Arabic text. Any "~" already in the text is escaped first
# with -Tilde, so every "~xx" left is one of these. $WinUtilArabicDecoder undoes it at startup.
function ConvertTo-WinUtilShortArabic([string]$Text, [string]$Tilde) {
    $Text = $Text.Replace('~', $Tilde)
    [regex]::Replace($Text, '[\u0600-\u06FF]', { param($m) '~{0:x2}' -f ([int][char]$m.Value - 0x600) })
}
$WinUtilArabicDecoder = "{0} = [regex]::Replace({0}, '~([0-9a-f]{{2}})', {{ param(`$m) [string][char](0x600 + [Convert]::ToInt32(`$m.Groups[1].Value, 16)) }})"

# Comments and indentation are for people reading the sources; the release script drops them so
# it downloads and parses faster. Strings, here-strings included, are kept exactly as written, and
# so is the first comment: the header naming the project and WinUtil.
function Compress-WinUtilScript([string]$Text) {
    $tokens = $null
    $errors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref]$tokens, [ref]$errors)
    if ($errors.Count -gt 0) {
        throw "The compiled script does not parse: $($errors[0].Message)"
    }

    $builder = [System.Text.StringBuilder]::new($Text.Length)
    $position = 0
    $isHeader = $true
    foreach ($token in $tokens) {
        if ($token.Kind -ne [System.Management.Automation.Language.TokenKind]::Comment) {
            continue
        }
        $start = $token.Extent.StartOffset
        [void]$builder.Append($Text, $position, $start - $position)
        if ($isHeader) {
            [void]$builder.Append($token.Text)
            $isHeader = $false
        } elseif ($start -gt 0 -and $token.Extent.EndOffset -lt $Text.Length -and
            -not [char]::IsWhiteSpace($Text[$start - 1]) -and -not [char]::IsWhiteSpace($Text[$token.Extent.EndOffset])) {
            # An inline <# #> between two words still has to separate them
            [void]$builder.Append(' ')
        }
        $position = $token.Extent.EndOffset
    }
    [void]$builder.Append($Text, $position, $Text.Length - $position)
    $Text = $builder.ToString()

    # Where multi-line strings sit in the text without comments
    $null = [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref]$tokens, [ref]$errors)
    $script:multilineStrings = @($tokens | Where-Object {
        $_.Kind -in 'StringLiteral', 'StringExpandable', 'HereStringLiteral', 'HereStringExpandable' -and $_.Text.Contains("`n")
    } | ForEach-Object { , @($_.Extent.StartOffset, $_.Extent.EndOffset) })
    $script:stringIndex = 0

    # Indentation, and blank lines, outside those strings. Matches arrive in order, so one pass
    # over the string ranges is enough.
    [regex]::Replace($Text, '(?m)^[ \t]*(?:\r?\n)?', {
        param($match)
        while ($script:stringIndex -lt $script:multilineStrings.Count -and $script:multilineStrings[$script:stringIndex][1] -le $match.Index) {
            $script:stringIndex++
        }
        if ($script:stringIndex -lt $script:multilineStrings.Count -and $match.Index -gt $script:multilineStrings[$script:stringIndex][0]) {
            return $match.Value
        }
        return ''
    })
}

# Comments, indentation and blank lines in XAML only take up space: WPF collapses whitespace in
# text, and nothing in this file sets xml:space="preserve".
function Compress-WinUtilXaml([string]$Text) {
    $Text = $Text -replace '(?s)<!--.*?-->', ''
    $Text -replace '(?m)^[ \t]+', '' -replace '(\r?\n)+', "`r`n"
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

    $json = $obj | ConvertTo-Json -Depth 10 -Compress
    $sync.configs[$_.BaseName] = $obj
    if ($json -match '[\u0600-\u06FF]') {
        $json = ConvertTo-WinUtilAsciiJson (ConvertTo-WinUtilShortArabic $json '\u007e')
        $script += "`$sync.configs.$($_.BaseName) = @'`r`n$json`r`n'@"
        $script += ($WinUtilArabicDecoder -f "`$sync.configs.$($_.BaseName)")
        $script += "`$sync.configs.$($_.BaseName) = `$sync.configs.$($_.BaseName) | ConvertFrom-Json"
    } else {
        $json = ConvertTo-WinUtilAsciiJson $json
        $script += "`$sync.configs.$($_.BaseName) = @'`r`n$json`r`n'@ | ConvertFrom-Json"
    }
}

$xaml = ConvertTo-WinUtilAsciiXml (ConvertTo-WinUtilShortArabic (Compress-WinUtilXaml (Get-Content -Path xaml\inputXML.xaml -Raw -Encoding UTF8)) '&#x7E;')
$script += "`$inputXML = @'`r`n$xaml`r`n'@"
$script += ($WinUtilArabicDecoder -f '$inputXML')

$autounattendXml = Get-Content -Path tools\autounattend.xml -Raw
$script += "`$WinUtilAutounattendXml = @'`r`n$autounattendXml`r`n'@"

$script += Get-Content -Path scripts\main.ps1 -Raw

Set-Content -Path winutil.ps1 -Value (Compress-WinUtilScript "$script")

if ($Run) {
    .\Winutil.ps1
}
