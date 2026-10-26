$root = "C:\New folder\Portofolio-Silvyani"
$buktiDir = Join-Path $root "assets\bukti"
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Save-Svg {
  param([string]$Path, [string]$Content)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8)
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

New-Bukti -File "dokumen-system-design.svg" -Label "System Design"      -Kategori "Process Flow dan Data Structure"
New-Bukti -File "laporan-analisis.svg"      -Label "Laporan Kendala"    -Kategori "Analisis dan Usulan Perbaikan"

# hapus placeholder lama yang sudah tidak dipakai
foreach ($f in @("webinar-training.svg", "webinar-modul-video.svg")) {
  $p = Join-Path $buktiDir $f
  if (Test-Path $p) { Remove-Item $p -Force; Write-Host "Dihapus: $f" }
}

Write-Host ""
Write-Host "Isi folder assets\bukti sekarang:"
Get-ChildItem $buktiDir | Select-Object -ExpandProperty Name
