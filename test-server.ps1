param(
    [string]$BuildProfile = "release-ultra"
)

$binaryMap = @{
    "debug" = "target\debug\axum-size-optimized.exe"
    "release" = "target\release\axum-size-optimized.exe"
    "release-z" = "target\release-z\axum-size-optimized.exe"
    "release-ultra" = "target\release-ultra\axum-size-optimized.exe"
}

$binaryPath = $binaryMap[$BuildProfile]

if (-not $binaryPath) {
    Write-Host "Invalid profile. Use: debug, release, release-z, or release-ultra" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $binaryPath)) {
    Write-Host "Binary not found: $binaryPath" -ForegroundColor Red
    Write-Host "Run build script first" -ForegroundColor Yellow
    exit 1
}

$size = (Get-Item $binaryPath).Length
$sizeKB = [math]::Round($size / 1KB, 2)

Write-Host "Starting server ($BuildProfile profile - $sizeKB KB)..." -ForegroundColor Cyan
Write-Host "Server will be available at http://127.0.0.1:3000" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Gray

& $binaryPath
