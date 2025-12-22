$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   GRAVITY - HARD FIX BUILDER (TURKISH CHAR FIX)   " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Force Safe Paths
$safeFlutterPath = "C:\flutter_sdk"
if (-not (Test-Path $safeFlutterPath)) {
    Write-Error "CRITICAL: C:\flutter_sdk symlink not found! Aborting."
    exit 1
}

Write-Host "[1/4] Configuring Environment (Forcing Safe Paths)..." -ForegroundColor Yellow
$env:FLUTTER_ROOT = $safeFlutterPath
$env:Path = "$safeFlutterPath\bin;" + $env:Path
Write-Host "FLUTTER_ROOT set to: $env:FLUTTER_ROOT" -ForegroundColor Green

# 2. Fix local.properties force-write
Write-Host "[2/4] Overwriting local.properties..." -ForegroundColor Yellow
$localPropsContent = @"
sdk.dir=C:\\Users\\PC\\AppData\\Local\\Android\\sdk
flutter.sdk=$safeFlutterPath
flutter.buildMode=release
flutter.versionName=0.1.0
flutter.versionCode=1
"@

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$PWD\android\local.properties", $localPropsContent, $utf8NoBom)
Write-Host "local.properties fixed successfully." -ForegroundColor Green

# 3. Clean
Write-Host "[3/4] Cleaning Project..." -ForegroundColor Yellow
# We use the full path to the flutter bat to be absolutely sure
$flutterBat = "$safeFlutterPath\bin\flutter.bat"
& $flutterBat clean
if ($LASTEXITCODE -ne 0) { Write-Error "Flutter Clean Failed!"; exit 1 }

# 4. Build
Write-Host "[4/4] Building APK (Release Mode)..." -ForegroundColor Yellow
& $flutterBat build apk --release
if ($LASTEXITCODE -ne 0) { 
    Write-Error "Build Failed! Check log above."
    exit 1 
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "   SUCCESS! APK CREATED SUCCESSFULLY!             " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host "APK Path: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
Write-Host ""
