@echo off
title GRAVITY - Guvenlik Duvari Kirici 🛡️🔨
color 0D

echo ==================================================
echo   GUVENLIK DUVARI KIRMA MODU
echo   (Java SSL Sertifika Kontrolu Kapatiliyor)
echo ==================================================
echo.

:: Java'ya "Sertifikalara guven" diyerek SSL hatalarini asiyoruz
set JAVA_TOOL_OPTIONS=-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true -Dfile.encoding=UTF-8

echo [0/2] Flutter yolu tanimlaniyor...
set PATH=%PATH%;C:\src\flutter\bin;C:\flutter\bin;C:\Users\%USERNAME%\flutter\bin;C:\Users\%USERNAME%\AppData\Local\Google\flutter\bin

echo [1/2] IP ve Sertifika ayarlari yapildi.
echo.
echo [2/2] APK insasi baslatiliyor...
echo.

echo [0/2] Turkce karakter destegi aciliyor...
chcp 65001 >nul

:: Ozel Flutter Yolu (Kesin Konum - UTF-8)
:: Not: Klasor isminde Turkce karakter var (Yeni klasör)
set "FLUTTER_EXE=C:\Users\PC\Downloads\Yeni klasör\yks_kocluk\flutter\bin\flutter.bat"

:: MEB/Asya Modu (China Mirrors)
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

echo [1/2] Web on hazirlik yapiliyor...
call "%FLUTTER_EXE%" clean

echo.
echo [2/2] WEB SITESI BASLATILIYOR (Chrome)...
echo Lutfen bekleyin, tarayici otomatik acilacak...
echo (Ilk acilis 1-2 dakika surebilir)
call "%FLUTTER_EXE%" run -d chrome

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo HATA: Web sitesi acilamadi. Lutfen yukaridaki hatayi okuyun.
)

echo.
echo Islem tamamlandi.
pause

echo.
echo Islem tamamlandi.
pause
