@echo off
title GRAVITY - Temizlik Zamani 🧹
color 0E

echo ==================================================
echo   GEREKSIZ DOSYALAR TEMIZLENIYOR...
echo ==================================================
echo.

echo [1/5] Build klasoru siliniyor...
if exist "build" rmdir /s /q "build"

echo [2/5] Gradle onbellegi siliniyor...
if exist ".gradle" rmdir /s /q ".gradle"
if exist "android\.gradle" rmdir /s /q "android\.gradle"

echo [3/5] Android build cikti siliniyor...
if exist "android\app\build" rmdir /s /q "android\app\build"

echo [4/5] Gecici dosyalar temizleniyor...
del /q "pubspec.lock" 2>nul

echo [5/5] Flutter temizleniyor...
call flutter clean

echo.
echo ==================================================
echo   TEMIZLIK TAMAMLANDI! ✨
echo   Proje simdi daha hafif ve temiz.
echo ==================================================
pause
