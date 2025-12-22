@echo off
title GRAVITY - APK Builder V3
color 0A

echo ==================================================
echo   GRAVITY APK BUILDER V3
echo ==================================================
echo.

:: Set Flutter path
set PATH=%PATH%;C:\src\flutter\bin;C:\flutter\bin;C:\Users\%USERNAME%\flutter\bin;C:\Users\%USERNAME%\AppData\Local\Google\flutter\bin

:: SSL bypass
set JAVA_TOOL_OPTIONS=-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true

:: Create clean temp directory for Gradle
set GRADLE_USER_HOME=%CD%\android\.gradle_home
set TMP=%CD%\android\.tmp
set TEMP=%CD%\android\.tmp
mkdir "%TMP%" 2>nul

echo [1/4] Cleaning previous builds...
call flutter clean
echo.

echo [2/4] Getting dependencies...
call flutter pub get
echo.

echo [3/4] Building APK (This may take a while)...
cd android
call gradlew.bat clean assembleRelease --no-daemon --stacktrace
cd ..
echo.

echo [4/4] Checking build output...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo.
    echo ==================================================
    echo   BUILD SUCCESSFUL! ✓
    echo ==================================================
    echo.
    echo APK Location:
    echo %CD%\build\app\outputs\flutter-apk\app-release.apk
) else (
    echo.
    echo ==================================================
    echo   BUILD FAILED! ✗
    echo ==================================================
    echo Please check the error messages above.
)

echo.
pause
