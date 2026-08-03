$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$siteRoot = Join-Path $repoRoot 'backup\codex'
$required = @('.nojekyll', 'backup\codex\index.html', 'backup\codex\assets\styles.css', 'backup\codex\status.json')

foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $relative))) {
        throw "Missing: $relative"
    }
}

$status = Get-Content -LiteralPath (Join-Path $siteRoot 'status.json') -Raw | ConvertFrom-Json
$names = @($status.PSObject.Properties.Name | Sort-Object)
$expected = @('checkedAtKst', 'message', 'status')
if (Compare-Object $names $expected) {
    throw 'status.json contains invalid fields'
}
if ($status.status -notin @('ok', 'failed')) {
    throw 'Invalid status value'
}

$forbidden = '(auth\.json|config\.toml|sessions|archived_sessions|\.sqlite|gh[opsu]_|github_pat_|sk-[A-Za-z0-9_-]{20,}|C:\\Users\\|KICPA)'
$hits = Get-ChildItem -LiteralPath $siteRoot -File -Recurse | Select-String -Pattern $forbidden
if ($hits) {
    throw "Forbidden public content: $($hits.Path -join ', ')"
}

Write-Output 'Public site validation passed.'
