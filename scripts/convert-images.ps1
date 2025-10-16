# PowerShell script to batch convert images to WebP using cwebp (libwebp)
# Usage: run in PowerShell where cwebp is installed and in project root
# Example: .\scripts\convert-images.ps1 -SourceDir "assets/images/port" -Quality 80
param(
    [string]$SourceDir = "assets/images/port",
    [int]$Quality = 80
)

if (-not (Get-Command cwebp -ErrorAction SilentlyContinue)) {
    Write-Host "cwebp not found. Install libwebp and ensure 'cwebp' is on your PATH. See: https://developers.google.com/speed/webp/download"
    exit 1
}

$files = Get-ChildItem -Path $SourceDir -Include *.jpg,*.jpeg,*.png -Recurse
foreach ($f in $files) {
    $out = [System.IO.Path]::ChangeExtension($f.FullName, '.webp')
    Write-Host "Converting $($f.Name) -> $([System.IO.Path]::GetFileName($out)) (quality $Quality)"
    & cwebp -q $Quality "$($f.FullName)" -o "$out"
}

Write-Host "Done. Review generated .webp files and update your HTML <img> tags to use <picture> or srcset for WebP with fallback."