Write-Host "Building all optimization levels..." -ForegroundColor Cyan

Write-Host "`nBuilding DEBUG build..." -ForegroundColor Yellow
cargo build
if ($LASTEXITCODE -ne 0) { Write-Host "Debug build failed" -ForegroundColor Red; exit 1 }

Write-Host "`nBuilding RELEASE (opt-level=s) build..." -ForegroundColor Yellow
cargo build --release
if ($LASTEXITCODE -ne 0) { Write-Host "Release build failed" -ForegroundColor Red; exit 1 }

Write-Host "`nBuilding RELEASE-Z (opt-level=z) build..." -ForegroundColor Yellow
cargo build --profile release-z
if ($LASTEXITCODE -ne 0) { Write-Host "Release-z build failed" -ForegroundColor Red; exit 1 }

Write-Host "`nBuilding RELEASE-ULTRA (opt-level=z, lto=fat) build..." -ForegroundColor Yellow
cargo build --profile release-ultra
if ($LASTEXITCODE -ne 0) { Write-Host "Release-ultra build failed" -ForegroundColor Red; exit 1 }

Write-Host "`nAll builds completed successfully!" -ForegroundColor Green
Write-Host "Run analyze-size.ps1 to see the size comparison" -ForegroundColor Cyan
