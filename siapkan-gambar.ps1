param(
  [ValidateSet("pad", "crop", "fit")]
  [string]$Mode = "fit",
  [int]$Quality = 85
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $root) { $root = (Get-Location).Path }

$rawDir   = Join-Path $root "assets\_mentah"
$buktiDir = Join-Path $root "assets\bukti"
$logoDir  = Join-Path $root "assets\logo"
$htmlPath = Join-Path $root "index.html"

New-Item -ItemType Directory -Force -Path $rawDir   | Out-Null
New-Item -ItemType Directory -Force -Path $buktiDir | Out-Null
New-Item -ItemType Directory -Force -Path $logoDir  | Out-Null

# ukuran kanvas akhir
$canvasW = 1600
$canvasH = 900
# batas sisi terpanjang untuk mode "fit" (sertifikat & dokumen tegak)
$canvasMax = 1600
# logo: kanvas KOTAK, karena di halaman dipasang di lencana bulat 58px
$logoW   = 320
$logoH   = 320

# peta kode -> nama file tujuan
$slots = @(
  [pscustomobject]@{ Code = "b1"; Name = "sertifikat-bnsp";         Kind = "bukti"; Ext = "jpg"; Label = "Sertifikat BNSP" }
  [pscustomobject]@{ Code = "b2"; Name = "sertifikat-kemenag";      Kind = "bukti"; Ext = "jpg"; Label = "Sertifikat Magang Kemenag" }
  [pscustomobject]@{ Code = "b3"; Name = "sertifikat-mitra-trend";  Kind = "bukti"; Ext = "jpg"; Label = "Sertifikat Magang Mitra Trend" }
  [pscustomobject]@{ Code = "b4"; Name = "webinar-piagam";          Kind = "bukti"; Ext = "jpg"; Label = "Foto Narasumber Webinar" }
  [pscustomobject]@{ Code = "b5"; Name = "artikel-tantri-pos";      Kind = "bukti"; Ext = "jpg"; Label = "Artikel Panduan Tantri POS" }
  [pscustomobject]@{ Code = "b6"; Name = "video-panduan";           Kind = "bukti"; Ext = "jpg"; Label = "Video Panduan" }
  [pscustomobject]@{ Code = "b7"; Name = "laporan-magang-kemenag";  Kind = "bukti"; Ext = "jpg"; Label = "Laporan Magang Kemenag" }
  [pscustomobject]@{ Code = "b8"; Name = "laporan-magang-mitra-trend"; Kind = "bukti"; Ext = "jpg"; Label = "Laporan Magang Mitra Trend" }
  [pscustomobject]@{ Code = "b10"; Name = "training-pengguna";      Kind = "bukti"; Ext = "jpg"; Label = "Foto Sesi Training Pengguna" }
  [pscustomobject]@{ Code = "b11"; Name = "laporan-nps";            Kind = "bukti"; Ext = "jpg"; Label = "Hasil Survei NPS" }
  [pscustomobject]@{ Code = "b12"; Name = "dashboard-sla";          Kind = "bukti"; Ext = "jpg"; Label = "Rata-rata Pelayanan (SLA)" }
  [pscustomobject]@{ Code = "b13"; Name = "sertifikat-ccna-1";      Kind = "bukti"; Ext = "jpg"; Label = "Sertifikat CCNA 1 - Introduction to Networks" }
  [pscustomobject]@{ Code = "b14"; Name = "sertifikat-ccna-2";      Kind = "bukti"; Ext = "jpg"; Label = "Sertifikat CCNA 2 - Switching, Routing, and Wireless Essentials" }
  [pscustomobject]@{ Code = "b15"; Name = "sertifikat-keempat";     Kind = "bukti"; Ext = "jpg"; Label = "Sertifikat Keempat" }
  [pscustomobject]@{ Code = "b16"; Name = "sertifikat-toefl";       Kind = "bukti"; Ext = "jpg"; Label = "Sertifikat TOEFL" }
[pscustomobject]@{ Code = "b17"; Name = "proyek-1";              Kind = "bukti"; Ext = "jpg"; Label = "Proyek 1" }
[pscustomobject]@{ Code = "b18"; Name = "proyek-2";              Kind = "bukti"; Ext = "jpg"; Label = "Proyek 2" }
[pscustomobject]@{ Code = "b19"; Name = "proyek-3";              Kind = "bukti"; Ext = "jpg"; Label = "Proyek 3" }
[pscustomobject]@{ Code = "b20"; Name = "proyek-4";              Kind = "bukti"; Ext = "jpg"; Label = "Proyek 4" }
  [pscustomobject]@{ Code = "l1"; Name = "sasana-solusi-digital";   Kind = "logo";  Ext = "png"; Label = "Logo Sasana Solusi Digital" }
  [pscustomobject]@{ Code = "l2"; Name = "lakes-konstelasi-data";   Kind = "logo";  Ext = "png"; Label = "Logo Lakes Konstelasi Data" }
  [pscustomobject]@{ Code = "l3"; Name = "ganesha-operation";       Kind = "logo";  Ext = "png"; Label = "Logo Ganesha Operation" }
  [pscustomobject]@{ Code = "l4"; Name = "kemenag-bandung";         Kind = "logo";  Ext = "png"; Label = "Logo Kemenag Kota Bandung" }
  [pscustomobject]@{ Code = "l5"; Name = "mitra-trend-computer";    Kind = "logo";  Ext = "png"; Label = "Logo Mitra Trend Computer" }
)

$utf8 = New-Object System.Text.UTF8Encoding($false)
$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
             Where-Object { $_.MimeType -eq 'image/jpeg' }

function Get-ExifOrientation {
  param([System.Drawing.Image]$Img)
  try {
    foreach ($p in $Img.PropertyItems) {
      if ($p.Id -eq 0x0112 -and $p.Value.Length -gt 0) { return [int]$p.Value[0] }
    }
  } catch { }
  return 1
}

function Repair-Orientation {
  param([System.Drawing.Image]$Img, [int]$Orientation)
  switch ($Orientation) {
    2 { $Img.RotateFlip([System.Drawing.RotateFlipType]::RotateNoneFlipX) }
    3 { $Img.RotateFlip([System.Drawing.RotateFlipType]::Rotate180FlipNone) }
    4 { $Img.RotateFlip([System.Drawing.RotateFlipType]::RotateNoneFlipY) }
    5 { $Img.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipX) }
    6 { $Img.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone) }
    7 { $Img.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipX) }
    8 { $Img.RotateFlip([System.Drawing.RotateFlipType]::Rotate270FlipNone) }
  }
  return $Img
}

function Get-ContentBounds {
  # cari kotak "isi" gambar: pinggiran yang sewarna latar (atau transparan)
  # dibuang, supaya tanda logonya tampil besar dan seragam antar perusahaan.
  param(
    [System.Drawing.Image]$Img,
    [int]$Threshold = 18
  )

  $bmp = New-Object System.Drawing.Bitmap($Img)
  try {
    $w = $bmp.Width
    $h = $bmp.Height
    # gambar besar cukup diperiksa setiap beberapa piksel, hasilnya tetap pas
    $step = [Math]::Max(1, [int][Math]::Floor([Math]::Max($w, $h) / 700))
    $bg = $bmp.GetPixel(0, 0)

    $minX = $w; $minY = $h; $maxX = -1; $maxY = -1
    for ($y = 0; $y -lt $h; $y += $step) {
      for ($x = 0; $x -lt $w; $x += $step) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.A -lt 8) { continue }
        if ([Math]::Abs($p.R - $bg.R) -le $Threshold -and
            [Math]::Abs($p.G - $bg.G) -le $Threshold -and
            [Math]::Abs($p.B - $bg.B) -le $Threshold) { continue }
        if ($x -lt $minX) { $minX = $x }
        if ($x -gt $maxX) { $maxX = $x }
        if ($y -lt $minY) { $minY = $y }
        if ($y -gt $maxY) { $maxY = $y }
      }
    }

    if ($maxX -lt 0) {
      return (New-Object System.Drawing.Rectangle(0, 0, $w, $h))
    }

    $padX = $step
    $x0 = [Math]::Max(0, $minX - $padX)
    $y0 = [Math]::Max(0, $minY - $padX)
    $x1 = [Math]::Min($w - 1, $maxX + $padX)
    $y1 = [Math]::Min($h - 1, $maxY + $padX)
    return (New-Object System.Drawing.Rectangle($x0, $y0, ($x1 - $x0 + 1), ($y1 - $y0 + 1)))
  } finally {
    $bmp.Dispose()
  }
}

function Resize-ToSlot {
  param(
    [string]$SourcePath,
    [string]$DestPath,
    [int]$TargetW,
    [int]$TargetH,
    [string]$FitMode,
    [bool]$Transparent,
    [int]$JpegQuality,
    [string]$Ext,
    [bool]$Trim = $false
  )

  $img = [System.Drawing.Image]::FromFile($SourcePath)
  try {
    $ori = Get-ExifOrientation -Img $img
    if ($ori -ne 1) { $img = Repair-Orientation -Img $img -Orientation $ori }

    $srcX = 0
    $srcY = 0
    $srcW = [double]$img.Width
    $srcH = [double]$img.Height

    # logo: pinggiran kosongnya dibuang dulu
    if ($Trim) {
      $b = Get-ContentBounds -Img $img
      $srcX = $b.X
      $srcY = $b.Y
      $srcW = [double]$b.Width
      $srcH = [double]$b.Height
    }

    # hitung skala
    if ($FitMode -eq "crop") {
      $scale = [Math]::Max($TargetW / $srcW, $TargetH / $srcH)
      $drawW = [int][Math]::Round($srcW * $scale)
      $drawH = [int][Math]::Round($srcH * $scale)
      $offX  = [int][Math]::Round(($TargetW - $drawW) / 2)
      $offY  = [int][Math]::Round(($TargetH - $drawH) / 2)
    } elseif ($FitMode -eq "fit") {
      # Sertifikat & dokumen umumnya TEGAK (portrait). Mode ini tidak menambah
      # kanvas kosong: ukuran hasil mengikuti bentuk aslinya, hanya sisi
      # terpanjangnya dibatasi. Jadi dokumen tetap besar saat diperbesar.
      $scale = [Math]::Min(1.0, $canvasMax / [Math]::Max($srcW, $srcH))
      $drawW = [int][Math]::Round($srcW * $scale)
      $drawH = [int][Math]::Round($srcH * $scale)
      $TargetW = $drawW
      $TargetH = $drawH
      $offX = 0
      $offY = 0
    } else {
      # sisakan sedikit napas di sekeliling logo
      $pad = if ($Trim) { 0.94 } else { 1.0 }
      $scale = [Math]::Min(($TargetW * $pad) / $srcW, ($TargetH * $pad) / $srcH)
      $drawW = [int][Math]::Round($srcW * $scale)
      $drawH = [int][Math]::Round($srcH * $scale)
      $offX  = [int][Math]::Round(($TargetW - $drawW) / 2)
      $offY  = [int][Math]::Round(($TargetH - $drawH) / 2)
    }

    $bmp = New-Object System.Drawing.Bitmap($TargetW, $TargetH)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    try {
      $g.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $g.PixelOffsetMode    = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
      $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
      $g.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

      if ($Transparent) {
        $g.Clear([System.Drawing.Color]::Transparent)
      } else {
        $g.Clear([System.Drawing.Color]::White)
      }

      $rect = New-Object System.Drawing.Rectangle($offX, $offY, $drawW, $drawH)
      if ($Trim) {
        $g.DrawImage($img, $rect, [single]$srcX, [single]$srcY, [single]$srcW, [single]$srcH,
                     [System.Drawing.GraphicsUnit]::Pixel)
      } else {
        $g.DrawImage($img, $rect)
      }
    } finally {
      $g.Dispose()
    }

    if ($Ext -eq "jpg") {
      $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
      $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
        [System.Drawing.Imaging.Encoder]::Quality, [long]$JpegQuality)
      $bmp.Save($DestPath, $jpegCodec, $ep)
      $ep.Dispose()
    } else {
      $bmp.Save($DestPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }

    $bmp.Dispose()
  } finally {
    $img.Dispose()
  }
}

# ---------- kumpulkan file mentah ----------

$imageExt = '\.(jpg|jpeg|png|webp|bmp|gif|tif|tiff|heic)$'
$rawFiles = Get-ChildItem -Path $rawDir -File |
            Where-Object { $_.Name -match $imageExt }

if ($rawFiles.Count -eq 0) {
  Write-Host ""
  Write-Host "  Folder 'assets\_mentah' masih kosong." -ForegroundColor Yellow
  Write-Host ""
  Write-Host "  Taruh gambar di folder itu, diberi nama sesuai kode:"
  Write-Host ""
  foreach ($s in $slots) {
    Write-Host ("    {0}  =  {1}" -f $s.Code, $s.Label) -ForegroundColor Gray
  }
  Write-Host ""
  Write-Host "  Contoh: beri nama file 'b4.jpg' untuk piagam webinar." -ForegroundColor Gray
  Write-Host ""
  exit 0
}

# ---------- proses ----------

$map = @{}
foreach ($f in $rawFiles) {
  if ($f.BaseName -match '^(?i)(b[0-9]{1,2}|l[1-5])(?![0-9])') {
    $code = $Matches[1].ToLower()
    if (-not $map.ContainsKey($code)) { $map[$code] = $f.FullName }
  } else {
    Write-Host ("  DILEWATI: {0}  (nama tidak diawali kode)" -f $f.Name) -ForegroundColor DarkYellow
  }
}

if ($map.Count -eq 0) {
  Write-Host ""
  Write-Host "  Tidak ada file yang cocok polanya." -ForegroundColor Yellow
  Write-Host "  Beri nama file dengan kode di depan, contoh: b4.jpg atau l3.png" -ForegroundColor Gray
  Write-Host ""
  exit 1
}

Write-Host ""
Write-Host "  Memproses gambar..." -ForegroundColor Cyan
Write-Host ""

$replacements = @()
$totalBefore = 0
$totalAfter  = 0

foreach ($s in $slots) {
  if (-not $map.ContainsKey($s.Code)) { continue }

  $src = $map[$s.Code]
  $dir = if ($s.Kind -eq "logo") { $logoDir } else { $buktiDir }
  $dst = Join-Path $dir ("{0}.{1}" -f $s.Name, $s.Ext)

  $isLogo = ($s.Kind -eq "logo")
  $tw = if ($isLogo) { $logoW } else { $canvasW }
  $th = if ($isLogo) { $logoH } else { $canvasH }

  # logo selalu memakai kanvas tetap supaya sejajar & mulus;
  # hanya sertifikat/dokumen yang mengikuti -Mode
  $modeForSlot = if ($isLogo) { "pad" } else { $Mode }

  $sizeBefore = (Get-Item $src).Length

  try {
    Resize-ToSlot -SourcePath $src -DestPath $dst -TargetW $tw -TargetH $th `
                  -FitMode $modeForSlot -Transparent $isLogo `
                  -JpegQuality $Quality -Ext $s.Ext -Trim $isLogo
  } catch {
    Write-Host ("  GAGAL : {0} -> {1}" -f (Split-Path $src -Leaf), $_.Exception.Message) -ForegroundColor Red
    continue
  }

  $sizeAfter = (Get-Item $dst).Length
  $totalBefore += $sizeBefore
  $totalAfter  += $sizeAfter

  $ratio = if ($sizeBefore -gt 0) { [int](100 - ($sizeAfter / $sizeBefore * 100)) } else { 0 }
  $sign  = if ($ratio -ge 0) { "-" } else { "+" }

  Write-Host ("  OK    : {0}  ->  {1}\{2}   ({3:N0} KB -> {4:N0} KB, {5}{6}%)" -f `
    (Split-Path $src -Leaf), $s.Kind, (Split-Path $dst -Leaf), `
    ($sizeBefore / 1KB), ($sizeAfter / 1KB), $sign, [Math]::Abs($ratio)) -ForegroundColor Green

  # siapkan penggantian referensi di index.html
  $rel  = if ($isLogo) { "assets/logo/$($s.Name).svg" } else { "assets/bukti/$($s.Name).svg" }
  $rel2 = if ($isLogo) { "assets/logo/$($s.Name).$($s.Ext)" } else { "assets/bukti/$($s.Name).$($s.Ext)" }
  $replacements += [pscustomobject]@{ Old = $rel; New = $rel2 }
}

# ---------- update index.html ----------

if ($replacements.Count -gt 0) {
  $content = Get-Content -Path $htmlPath -Raw
  $original = $content
  foreach ($r in $replacements) {
    $content = $content.Replace($r.Old, $r.New)
  }
  if ($content -ne $original) {
    Copy-Item -Path $htmlPath -Destination "$htmlPath.bak" -Force
    [System.IO.File]::WriteAllText($htmlPath, $content, $utf8)
    Write-Host ""
    Write-Host "  index.html diperbarui." -ForegroundColor Cyan
    Write-Host "  Cadangan lama disimpan sebagai index.html.bak" -ForegroundColor DarkGray
  } else {
    Write-Host ""
    Write-Host "  index.html tidak berubah (referensi sudah sesuai)." -ForegroundColor DarkGray
  }
}

Write-Host ""
if ($totalBefore -gt 0) {
  $pct = [int](100 - ($totalAfter / $totalBefore * 100))
  Write-Host ("  Total: {0:N1} MB -> {1:N1} MB  (hemat {2}%)" -f `
    ($totalBefore / 1MB), ($totalAfter / 1MB), $pct) -ForegroundColor Cyan
}
Write-Host "  Selesai. Refresh browser dengan Ctrl+F5." -ForegroundColor Green
Write-Host ""
