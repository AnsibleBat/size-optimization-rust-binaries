Write-Host "Building with ULTRA size optimization..." -ForegroundColor Cyan
Write-Host "Profile: release-ultra (opt-level=z, lto=fat, codegen-units=1, panic=abort, strip=true)" -ForegroundColor Yellow

cargo build --profile release-ultra

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBuild successful!" -ForegroundColor Green
    $binaryPath = "target\release-ultra\axum-size-optimized.exe"
    if (Test-Path $binaryPath) {
        $size = (Get-Item $binaryPath).Length
        $sizeMB = [math]::Round($size / 1MB, 2)
        $sizeKB = [math]::Round($size / 1KB, 2)
        Write-Host "Binary size: $sizeKB KB ($sizeMB MB)" -ForegroundColor Cyan
        Write-Host "Location: $binaryPath" -ForegroundColor Gray
    }
} else {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    exit 1
}
