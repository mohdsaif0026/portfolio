<#
Generate WebP versions of images in a folder using cwebp (libwebp).
Usage:
  powershell -ExecutionPolicy Bypass -File .\scripts\generate-webp.ps1 -SourceDir "assets/images/port" -Quality 80

Make sure `cwebp` is installed and available on PATH. On Windows you can get it from https://developers.google.com/speed/webp/download
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceDir,
    [int]$Quality = 80
)

if (-not (Get-Command cwebp -ErrorAction SilentlyContinue)) {
    Write-Error "cwebp not found on PATH. Install libwebp and ensure cwebp is available."
    exit 1
}

$sourceFull = Join-Path (Get-Location) $SourceDir
if (-not (Test-Path $sourceFull)) {
    Write-Error "Source directory '$sourceFull' not found."
    exit 1
}

Get-ChildItem -Path $sourceFull -Include *.jpg,*.jpeg,*.png -Recurse | ForEach-Object {
    $src = $_.FullName
    $dest = [System.IO.Path]::ChangeExtension($src, '.webp')
    Write-Host "Converting $($_.Name) -> $(Split-Path $dest -Leaf) (quality=$Quality)"
    & cwebp -q $Quality "$src" -o "$dest" | Out-Null
}

Write-Host "Done. WebP files created alongside original images."
