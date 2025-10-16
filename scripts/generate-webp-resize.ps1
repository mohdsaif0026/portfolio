<#
Generate resized WebP variants for images in a folder.

This script prefers ImageMagick's `magick` command to resize and encode directly to WebP.
If ImageMagick is not available, it will fall back to the simple `cwebp` conversion (no resizing).

Usage:
  powershell -ExecutionPolicy Bypass -File .\scripts\generate-webp-resize.ps1 -SourceDir "assets/images/port" -Quality 80

Outputs (for each image):
  <name>-400.webp  (400px wide)
  <name>-800.webp  (800px wide)
  <name>-1200.webp (1200px wide)

Requirements:
  - ImageMagick (magick) is recommended. Download from https://imagemagick.org
  - Or libwebp (cwebp) available on PATH (converts but does not resize reliably)
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceDir,
    [int]$Quality = 80
)

function Ensure-Path($p){ if ($p -like './*' -or $p -like '.\\*') { return (Resolve-Path $p).Path } ; return $p }

$srcFull = Ensure-Path $SourceDir
if (-not (Test-Path $srcFull)) { Write-Error "Source directory not found: $srcFull"; exit 1 }

$usesMagick = (Get-Command magick -ErrorAction SilentlyContinue) -ne $null
$usesCwebp = (Get-Command cwebp -ErrorAction SilentlyContinue) -ne $null

if (-not $usesMagick -and -not $usesCwebp) {
    Write-Error "Neither 'magick' (ImageMagick) nor 'cwebp' (libwebp) were found on PATH. Install one and retry."
    exit 1
}

$widths = @(400,800,1200)

Get-ChildItem -Path $srcFull -Include *.jpg,*.jpeg,*.png -File | ForEach-Object {
    $src = $_.FullName
    $base = [System.IO.Path]::GetFileNameWithoutExtension($src)
    $dir = $_.DirectoryName
    foreach ($w in $widths) {
        $dest = Join-Path $dir "$($base)-$w.webp"
        if ($usesMagick) {
            # Use ImageMagick to resize and write WebP directly
            Write-Host "magick: $($_.Name) -> $($base)-$w.webp ($w px)"
            & magick "$src" -quality $Quality -resize ${w}x "$dest"
        } else {
            # Fallback: use cwebp (will not reliably resize). We'll still run it to produce webp.
            Write-Host "cwebp fallback: $($_.Name) -> $($base)-$w.webp (no resize)"
            & cwebp -q $Quality "$src" -o "$dest" | Out-Null
        }
    }
}

Write-Host "Done. WebP resized variants created alongside originals (when ImageMagick available)."
