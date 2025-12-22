$fso = New-Object -ComObject Scripting.FileSystemObject
$folder = $fso.GetFolder("C:\Users\PC\Downloads\Yeni klasör")
$shortPath = $folder.ShortPath
Write-Host $shortPath
