$root = "C:\New folder\Portofolio-Silvyani"
$logoDir  = Join-Path $root "assets\logo"
$buktiDir = Join-Path $root "assets\bukti"

New-Item -ItemType Directory -Force -Path $logoDir  | Out-Null
New-Item -ItemType Directory -Force -Path $buktiDir | Out-Null

$utf8 = New-Object System.Text.UTF8Encoding($false)

function Save-Svg {
  param([string]$Path, [string]$Content)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function New-Logo {
  param([string]$File, [string]$Initials, [string]$Name, [string]$Period)
  $svg = @"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 380 130" role="img" aria-label="$Name">
  <rect x="1" y="1" width="378" height="128" rx="16" fill="#ffffff" stroke="#e2e8f0" stroke-width="2"/>
  <circle cx="62" cy="65" r="30" fill="#eff6ff" stroke="#dbeafe" stroke-width="2"/>
  <text x="62" y="65" text-anchor="middle" dominant-baseline="central" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="21" font-weight="700" fill="#2563eb">$Initials</text>
  <text x="110" y="56" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="18" font-weight="700" fill="#0f172a">$Name</text>
  <text x="110" y="80" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="13" font-weight="500" fill="#64748b">$Period</text>
</svg>
"@
  Save-Svg -Path (Join-Path $logoDir $File) -Content $svg
}

function New-Bukti {
  param([string]$File, [string]$Label, [string]$Kategori)
  $svg = @"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 900" role="img" aria-label="$Label">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#f7f9fc"/>
      <stop offset="1" stop-color="#e4edfb"/>
    </linearGradient>
  </defs>
  <rect width="1600" height="900" fill="url(#bg)"/>
  <rect x="28" y="28" width="1544" height="844" rx="32" fill="none" stroke="#bcd6f8" stroke-width="5" stroke-dasharray="24 18"/>
  <g transform="translate(800,300)">
    <rect x="-130" y="-100" width="260" height="200" rx="20" fill="#ffffff" stroke="#bcd6f8" stroke-width="6"/>
    <circle cx="-56" cy="-40" r="22" fill="#dbeafe"/>
    <path d="M-130 100 L-34 -6 L22 100 Z" fill="#dbeafe"/>
    <path d="M-6 100 L74 -22 L130 100 Z" fill="#c3dbf9"/>
  </g>
  <text x="800" y="560" text-anchor="middle" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="54" font-weight="700" fill="#1e3a8a">$Label</text>
  <text x="800" y="622" text-anchor="middle" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="30" font-weight="600" fill="#3b6bc4">$Kategori</text>
  <text x="800" y="712" text-anchor="middle" font-family="Inter,Segoe UI,Arial,sans-serif" font-size="27" font-weight="500" fill="#94a3b8">Ganti file ini dengan gambar asli kamu</text>
</svg>
"@
  Save-Svg -Path (Join-Path $buktiDir $File) -Content $svg
}

# ---------- logo perusahaan ----------
New-Logo -File "ganesha-operation.svg"      -Initials "GO" -Name "Ganesha Operation"      -Period "Product Development - 2024-2025"
New-Logo -File "lakes-konstelasi-data.svg"  -Initials "LK" -Name "Lakes Konstelasi Data"  -Period "IT Helpdesk - 2025-2026"
New-Logo -File "sasana-solusi-digital.svg"  -Initials "SS" -Name "Sasana Solusi Digital"  -Period "Technical Support - 2026"
New-Logo -File "kemenag-bandung.svg"        -Initials "KA" -Name "Kemenag Kota Bandung"   -Period "Magang - 2023"
New-Logo -File "mitra-trend-computer.svg"   -Initials "MT" -Name "Mitra Trend Computer"   -Period "Magang - 2019"

# ---------- gambar bukti ----------
New-Bukti -File "webinar-piagam.svg"        -Label "Piagam Narasumber"      -Kategori "Bukti Webinar"
New-Bukti -File "webinar-training.svg"      -Label "Dokumentasi Training"   -Kategori "Bukti Webinar"
New-Bukti -File "webinar-modul-video.svg"   -Label "Modul dan Video"        -Kategori "Bukti Panduan"
New-Bukti -File "artikel-tantri-pos.svg"    -Label "Artikel Panduan"        -Kategori "Bukti Publikasi"
New-Bukti -File "video-panduan.svg"         -Label "Video Panduan"          -Kategori "Bukti Publikasi"
New-Bukti -File "dokumen-prd-cr.svg"        -Label "PRD dan Change Request" -Kategori "Bukti Dokumen"
New-Bukti -File "sertifikat-bnsp.svg"       -Label "Sertifikat BNSP"        -Kategori "Associate Data Scientist"
New-Bukti -File "sertifikat-kemenag.svg"    -Label "Sertifikat Magang"      -Kategori "Kemenag Kota Bandung"
New-Bukti -File "sertifikat-mitra-trend.svg"-Label "Sertifikat Magang"      -Kategori "Mitra Trend Computer"

Write-Host "Selesai. File dibuat:"
Get-ChildItem -Recurse $logoDir, $buktiDir | Select-Object -ExpandProperty Name
