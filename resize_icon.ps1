Add-Type -AssemblyName System.Drawing

$sourcePath = "assets/app_icon.png"
$destPath = "assets/app_icon_foreground.png"

# Load original image
$sourceImg = [System.Drawing.Image]::FromFile($sourcePath)

# Create new 1024x1024 transparent bitmap
$destImg = New-Object System.Drawing.Bitmap(1024, 1024)
$graphics = [System.Drawing.Graphics]::FromImage($destImg)
$graphics.Clear([System.Drawing.Color]::Transparent)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Calculate new size (60% scale to be safe for adaptive icon safe zone)
# Safe zone is 66% diameter circle, so 60% square is safe
$scale = 0.60
$newWidth = 1024 * $scale
$newHeight = 1024 * $scale

# Calculate position to center
$x = (1024 - $newWidth) / 2
$y = (1024 - $newHeight) / 2

# Draw original image onto new canvas
$graphics.DrawImage($sourceImg, $x, $y, $newWidth, $newHeight)

# Save
$destImg.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)

# Cleanup
$sourceImg.Dispose()
$destImg.Dispose()
$graphics.Dispose()

Write-Host "Created app_icon_foreground.png successfully at $destPath"
