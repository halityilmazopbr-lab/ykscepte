$content = @"
sdk.dir=C:\\Users\\PC\\AppData\\Local\\Android\\sdk
flutter.sdk=C:\\flutter_sdk
flutter.buildMode=release
flutter.versionName=0.1.0
"@

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$PWD\android\local.properties", $content, $utf8NoBom)

Write-Host "local.properties updated with symlink path C:\flutter_sdk"
