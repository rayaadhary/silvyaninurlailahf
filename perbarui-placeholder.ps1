$root = "C:\New folder\Portofolio-Silvyani"
$logoDir  = Join-Path $root "assets\logo"
$buktiDir = Join-Path $root "assets\bukti"
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Save-Svg {
  param([string]$Path, [string]$Content)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

# lewati kalau gambar asli sudah ada (jpg/png/webp dengan nama yang sama)
function Test-SudahDiganti {
  param([string]$Dir, [string]$BaseName)
  foreach ($ext in @("jpg", "jpeg", "png", "webp")) {
    if (Test-Path (Join-Path $Dir "$BaseName.$ext")) { return $true }
  }
  return $false
}

function New-Logo {
  param([string]$BaseName, [string]$Initials, [string]$Name, [string]$Period)
  if (Test-SudahDiganti -Dir $logoDir -BaseName $BaseName) {
    Write-Host "  dilewati (sudah ada gambar asli): $BaseName"
    return
  }
  $svg = @"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 380 130" role="img" aria-label="$Name">
  <rect x="1" y="1" width="378" height="128" rx="16" fill="#ffffff" stroke="#efe3da" stroke-width="2"/>
  <circle cx="62" cy="65" r="30" fill="#fbeee7" stroke="#f7e4d9" stroke-width="2"/>
  <text x="62" y="65" text-anchor="middle" dominant-baseline="central" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="21" font-weight="700" fill="#b65a33">$Initials</text>
  <text x="110" y="56" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="18" font-weight="700" fill="#2e1e16">$Name</text>
  <text x="110" y="80" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="13" font-weight="500" fill="#7d6857">$Period</text>
</svg>
"@
  Save-Svg -Path (Join-Path $logoDir "$BaseName.svg") -Content $svg
  Write-Host "  logo diperbarui : $BaseName.svg"
}

function New-Bukti {
  param([string]$BaseName, [string]$Label, [string]$Kategori)
  if (Test-SudahDiganti -Dir $buktiDir -BaseName $BaseName) {
    Write-Host "  dilewati (sudah ada gambar asli): $BaseName"
    return
  }
  $svg = @"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 900" role="img" aria-label="$Label">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#fdf9f6"/>
      <stop offset="1" stop-color="#f9ece4"/>
    </linearGradient>
  </defs>
  <rect width="1600" height="900" fill="url(#bg)"/>
  <rect x="30" y="30" width="1540" height="840" rx="34" fill="none" stroke="#f0dbd0" stroke-width="5" stroke-dasharray="24 18"/>
  <g transform="translate(800,300)">
    <rect x="-130" y="-100" width="260" height="200" rx="20" fill="#ffffff" stroke="#f0dbd0" stroke-width="6"/>
    <circle cx="-56" cy="-40" r="22" fill="#fbeee7"/>
    <path d="M-130 100 L-34 -6 L22 100 Z" fill="#fbeee7"/>
    <path d="M-6 100 L74 -22 L130 100 Z" fill="#f3ddcf"/>
  </g>
  <text x="800" y="560" text-anchor="middle" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="54" font-weight="700" fill="#7a3a20">$Label</text>
  <text x="800" y="622" text-anchor="middle" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="30" font-weight="600" fill="#a86a4a">$Kategori</text>
  <text x="800" y="712" text-anchor="middle" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="27" font-weight="500" fill="#b8a496">Ganti file ini dengan gambar asli kamu</text>
</svg>
"@
  Save-Svg -Path (Join-Path $buktiDir "$BaseName.svg") -Content $svg
  Write-Host "  bukti diperbarui: $BaseName.svg"
}

Write-Host ""
Write-Host "Memperbarui gambar contoh ke palet terracotta..."
Write-Host ""

New-Logo -BaseName "sasana-solusi-digital"  -Initials "SS" -Name "Sasana Solusi Digital"  -Period "Technical Support - 2026"
New-Logo -BaseName "lakes-konstelasi-data"  -Initials "LK" -Name "Lakes Konstelasi Data"  -Period "IT Helpdesk - 2025-2026"
New-Logo -BaseName "ganesha-operation"      -Initials "GO" -Name "Ganesha Operation"      -Period "Product Development - 2024-2025"
New-Logo -BaseName "kemenag-bandung"        -Initials "KA" -Name "Kemenag Kota Bandung"   -Period "Magang - 2023"
New-Logo -BaseName "mitra-trend-computer"   -Initials "MT" -Name "Mitra Trend Computer"   -Period "Magang - 2019"

Write-Host ""

New-Bukti -BaseName "sertifikat-bnsp"         -Label "Sertifikat BNSP"        -Kategori "Associate Data Scientist"
New-Bukti -BaseName "sertifikat-kemenag"      -Label "Sertifikat Magang"      -Kategori "Kemenag Kota Bandung"
New-Bukti -BaseName "sertifikat-mitra-trend"  -Label "Sertifikat Magang"      -Kategori "Mitra Trend Computer"
New-Bukti -BaseName "webinar-piagam"          -Label "Piagam Narasumber"      -Kategori "Bukti Webinar"
New-Bukti -BaseName "artikel-tantri-pos"      -Label "Artikel Panduan"        -Kategori "Bukti Publikasi"
New-Bukti -BaseName "video-panduan"           -Label "Video Panduan"          -Kategori "Bukti Publikasi"
New-Bukti -BaseName "dokumen-prd-cr"          -Label "PRD dan Change Request" -Kategori "Dokumen Internal"
New-Bukti -BaseName "dokumen-system-design"   -Label "System Design"          -Kategori "Dokumen Internal"
New-Bukti -BaseName "laporan-analisis"        -Label "Laporan Kendala"        -Kategori "Dokumen Internal"

Write-Host ""
Write-Host "Selesai. Refresh browser dengan Ctrl+F5."
Write-Host ""
