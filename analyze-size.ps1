Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   Binary Size Analysis Report" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$builds = @(
    @{ Name = "Debug"; Path = "target\debug\axum-size-optimized.exe"; Config = "Default debug settings" }
    @{ Name = "Release"; Path = "target\release\axum-size-optimized.exe"; Config = "opt-level=s, lto=true, strip=true" }
    @{ Name = "Release-Z"; Path = "target\release-z\axum-size-optimized.exe"; Config = "opt-level=z, lto=true, strip=true" }
    @{ Name = "Release-Ultra"; Path = "target\release-ultra\axum-size-optimized.exe"; Config = "opt-level=z, lto=fat, strip=true" }
)

$results = @()
$baselineSize = 0

foreach ($build in $builds) {
    if (Test-Path $build.Path) {
        $size = (Get-Item $build.Path).Length
        $sizeKB = [math]::Round($size / 1KB, 2)
        $sizeMB = [math]::Round($size / 1MB, 2)
        
        if ($build.Name -eq "Debug") {
            $baselineSize = $size
            $reduction = "baseline"
        } else {
            $percent = [math]::Round((($baselineSize - $size) / $baselineSize) * 100, 2)
            $reduction = "-$percent%"
        }
        
        $results += @{
            Name = $build.Name
            SizeKB = $sizeKB
            SizeMB = $sizeMB
            Reduction = $reduction
            Config = $build.Config
        }
    }
}

if ($results.Count -eq 0) {
    Write-Host "No binaries found. Run build-all.ps1 first." -ForegroundColor Red
    exit 1
}

$maxNameLen = ($results | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum
$maxKBLen = ($results | ForEach-Object { "$($_.SizeKB) KB".Length } | Measure-Object -Maximum).Maximum

Write-Host ("Build Profile".PadRight($maxNameLen + 2)) -NoNewline -ForegroundColor Yellow
Write-Host ("Size (KB)".PadRight($maxKBLen + 4)) -NoNewline -ForegroundColor Yellow
Write-Host ("Size (MB)".PadRight(12)) -NoNewline -ForegroundColor Yellow
Write-Host ("Reduction".PadRight(12)) -NoNewline -ForegroundColor Yellow
Write-Host "Configuration" -ForegroundColor Yellow
Write-Host ("-" * 100) -ForegroundColor Gray

foreach ($result in $results) {
    $color = switch ($result.Name) {
        "Debug" { "White" }
        "Release" { "Cyan" }
        "Release-Z" { "Green" }
        "Release-Ultra" { "Magenta" }
    }
    
    Write-Host ($result.Name.PadRight($maxNameLen + 2)) -NoNewline -ForegroundColor $color
    Write-Host ("$($result.SizeKB) KB".PadRight($maxKBLen + 4)) -NoNewline
    Write-Host ("$($result.SizeMB) MB".PadRight(12)) -NoNewline
    Write-Host ($result.Reduction.PadRight(12)) -NoNewline
    Write-Host $result.Config -ForegroundColor Gray
}

Write-Host "`n========================================`n" -ForegroundColor Cyan

if ($results.Count -gt 1) {
    $smallest = $results | Sort-Object { [double]$_.SizeKB } | Select-Object -First 1
    Write-Host "Smallest binary: $($smallest.Name) at $($smallest.SizeKB) KB" -ForegroundColor Green
    
    if ($baselineSize -gt 0) {
        $debugResult = $results | Where-Object { $_.Name -eq "Debug" }
        if ($debugResult) {
            $totalReduction = [math]::Round((($baselineSize - ($smallest.SizeKB * 1024)) / $baselineSize) * 100, 2)
            Write-Host "Total size reduction from debug: $totalReduction%" -ForegroundColor Cyan
        }
    }
}

Write-Host ""
