@echo off
chcp 65001 >nul
title Siapkan Gambar Portofolio
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0siapkan-gambar.ps1"
echo.
pause
