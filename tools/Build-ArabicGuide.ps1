<#
.SYNOPSIS
    Generates docs-ar/tweaks.md, the Arabic guide the "(?)" buttons open

.DESCRIPTION
    Every tweak and feature gets its Arabic name and description from config/translations.json
    and a list of what it actually changes (registry values, services, Windows features, scripts)
    from config/tweaks.json and config/feature.json. Run it after changing any of those files;
    pester/translations.Tests.ps1 fails while the committed guide is out of date.

.EXAMPLE
    .\tools\Build-ArabicGuide.ps1
#>
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot "..\docs-ar\tweaks.md")
)

$root = Join-Path $PSScriptRoot ".."
function Read-Config([string]$Name) {
    Get-Content -Path (Join-Path $root "config\$Name.json") -Raw -Encoding UTF8 | ConvertFrom-Json
}
$translations = Read-Config "translations"
$sources = [ordered]@{ tweaks = (Read-Config "tweaks"); feature = (Read-Config "feature") }

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('<div dir="rtl">')
$lines.Add('')
$lines.Add('# دليل التحسينات والميزات')
$lines.Add('')
$lines.Add('هذه الصفحة يفتحها زر "(?)" بجانب كل خيار في Blazma Boost. لكل خيار: وش يسوي، ووش يغيّر في النظام بالضبط.')
$lines.Add('')
$lines.Add('> هذا الملف يُنشأ تلقائياً بالأمر `.\tools\Build-ArabicGuide.ps1`، لا تعدله يدوياً.')
$lines.Add('')

foreach ($sourceName in $sources.Keys) {
    $config = $sources[$sourceName]
    $byCategory = $config.PSObject.Properties | Where-Object { $_.Value.link } | Group-Object { $_.Value.category } | Sort-Object Name
    foreach ($group in $byCategory) {
        $categoryName = $group.Name -replace '.*__', ''
        $categoryTitle = $translations.categories.$categoryName
        if (-not $categoryTitle) { $categoryTitle = $categoryName }
        $lines.Add("## $categoryTitle")
        $lines.Add('')

        foreach ($entry in ($group.Group | Sort-Object Name)) {
            $key = $entry.Name
            $value = $entry.Value
            $translated = $translations.$sourceName.$key
            $title = if ($translated.Content) { $translated.Content } else { $value.Content }
            $description = if ($translated.Description) { $translated.Description } else { $value.Description }

            $lines.Add("<a id=`"$($key.ToLowerInvariant())`"></a>")
            $lines.Add('')
            $lines.Add("### $title")
            $lines.Add('')
            if ($description) {
                $lines.Add($description)
                $lines.Add('')
            }

            $changes = [System.Collections.Generic.List[string]]::new()
            function Format-RegistryValue($raw) {
                if ($raw -eq "<RemoveEntry>") { "حذف القيمة" } else { "``$raw``" }
            }
            foreach ($registry in @($value.registry | Where-Object { $_ })) {
                if ($registry.Values) {
                    $changes.Add("- ريجستري: ``$($registry.Path)\$($registry.Name)`` حسب الخيار المختار")
                } else {
                    $changes.Add("- ريجستري: ``$($registry.Path)\$($registry.Name)``: $(Format-RegistryValue $registry.Value) (التراجع يرجع قيمتك السابقة، أو $(Format-RegistryValue $registry.OriginalValue) إذا ما كانت محفوظة)")
                }
            }
            foreach ($service in @($value.service | Where-Object { $_ })) {
                $changes.Add("- خدمة: ``$($service.Name)`` تصير ``$($service.StartupType)`` (الأصل ``$($service.OriginalType)``)")
            }
            foreach ($feature in @($value.feature | Where-Object { $_ })) {
                $changes.Add("- ميزة ويندوز: ``$feature``")
            }
            foreach ($appx in @($value.appx | Where-Object { $_ })) {
                $changes.Add("- حذف تطبيق: ``$appx``")
            }
            if (@($value.InvokeScript | Where-Object { $_ }).Count -gt 0) {
                $undo = if (@($value.UndoScript | Where-Object { $_ }).Count -gt 0) { "وله سكربت تراجع" } else { "وما له سكربت تراجع" }
                $changes.Add("- يشغّل سكربت PowerShell $undo")
            }
            if ($changes.Count -gt 0) {
                $lines.Add('**وش يغيّر:**')
                $lines.Add('')
                $changes | ForEach-Object { $lines.Add($_) }
                $lines.Add('')
            }
        }
    }
}

$lines.Add('</div>')
New-Item -ItemType Directory -Path (Split-Path -Parent $OutputPath) -Force | Out-Null
[IO.File]::WriteAllText([IO.Path]::GetFullPath($OutputPath), (($lines -join "`n") + "`n"), [Text.UTF8Encoding]::new($false))
