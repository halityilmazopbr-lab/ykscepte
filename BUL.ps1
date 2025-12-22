$path = "C:\Users\PC\Downloads\Yeni klasör\yks_kocluk\flutter\bin\flutter.bat"
if (Test-Path $path) {
    echo "BULUNDU: $path"
    $item = Get-Item $path
    echo "KISA_YOL: $($item.FullName)"
} else {
    echo "BULUNAMADI"
    Get-ChildItem -Path "C:\Users\PC\Downloads" -Recurse -Filter "flutter.bat" -ErrorAction SilentlyContinue | Select-Object FullName
}
