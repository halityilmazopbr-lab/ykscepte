@echo off
title GRAVITY - APK Builder V2
color 0B
chcp 65001 >nul

echo ==================================================
echo   GRAVITY APK BUILDER V2 🛠️
echo ==================================================
echo.

:: 1. Define specific Flutter path
set "FLUTTER_EXE=C:\Users\PC\Downloads\Yeni klasör\yks_kocluk\flutter\bin\flutter.bat"

:: 2. SSL Configurations
set JAVA_TOOL_OPTIONS=-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true -Dfile.encoding=UTF-8

:: 2.5 Set FLUTTER_ROOT to symlink path (this takes priority in settings.gradle.kts)
set FLUTTER_ROOT=C:\flutter_sdk
echo Using FLUTTER_ROOT=%FLUTTER_ROOT%
echo.

echo [0/3] Clearing existing Java processes...
taskkill /F /IM java.exe >nul 2>&1

:: 3. Process
echo [1/3] Cleaning project...
call "%FLUTTER_EXE%" clean

echo.
echo [1.5/3] Fixing local.properties with symlink path...
powershell -ExecutionPolicy Bypass -Command "$content = \"sdk.dir=C:\\Users\\PC\\AppData\\Local\\Android\\sdk`nflutter.sdk=C:\\flutter_sdk`nflutter.buildMode=release`nflutter.versionName=0.1.0\"; $utf8NoBom = New-Object System.Text.UTF8Encoding $false; [System.IO.File]::WriteAllText(\"android\local.properties\", $content, $utf8NoBom); Write-Host 'local.properties fixed!'"

echo.
echo [2/3] Getting dependencies...
call "%FLUTTER_EXE%" pub get

echo.
echo [2.5/3] Re-fixing local.properties after pub get...
powershell -ExecutionPolicy Bypass -Command "$content = \"sdk.dir=C:\\Users\\PC\\AppData\\Local\\Android\\sdk`nflutter.sdk=C:\\flutter_sdk`nflutter.buildMode=release`nflutter.versionName=0.1.0\"; $utf8NoBom = New-Object System.Text.UTF8Encoding $false; [System.IO.File]::WriteAllText(\"android\local.properties\", $content, $utf8NoBom); Write-Host 'local.properties re-fixed!'"

echo.
echo [3/3] Building APK (Release)...
call "%FLUTTER_EXE%" build apk --release

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ BUILD FAILED! Please check the errors above.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ==================================================
echo   SUCCESS! ✅
echo ==================================================
echo.
echo APK Location: build\app\outputs\flutter-apk\app-release.apk
echo.
pause
