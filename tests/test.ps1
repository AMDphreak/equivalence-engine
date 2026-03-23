# Build engine if needed
if (!(Test-Path "../bin/evolution-engine.exe")) {
    Write-Host "Rebuilding engine..." -ForegroundColor Cyan
    Push-Location ..
    dub build -b release
    Pop-Location
}

# Run test
$engine = "../bin/evolution-engine.exe"
Write-Host "Running evolution-engine test..." -ForegroundColor Green
& $engine --path . --rules-dir ../rules/qt --from 5.15 --to 6.0
