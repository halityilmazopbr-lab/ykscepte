# PowerShell script to get and update local.properties with short path
$downloadsPath = "C:\Users\PC\Downloads"
$targetFolder = Get-ChildItem $downloadsPath | Where-Object { $_.Name -eq "Yeni klasör" } | Select-Object -First 1

if ($targetFolder) {
    # Use WMI to get short path (8.3 format)
    $folder = Get-WmiObject -Query "SELECT * FROM Win32_Directory WHERE Name='$($targetFolder.FullName.Replace('\','\\'))'"
    if ($folder) {
        $shortPath = $folder.EightDotThreeFileName
        $flutterShortPath = "$shortPath\yks_kocluk\flutter"
        
        Write-Host "Found short path: $flutterShortPath"
        
        # Update local.properties
        $content = @"
sdk.dir=C:\\Users\\PC\\AppData\\Local\\Android\\sdk
flutter.sdk=$flutterShortPath
flutter.buildMode=release
flutter.versionName=0.1.0
"@
        
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText("$PWD\android\local.properties", $content, $utf8NoBom)
        
        Write-Host "local.properties updated successfully with short path"
    }
    else {
        Write-Host "Could not get short path via WMI"
    }
}
else {
    Write-Host "Yeni klasör not found"
}
