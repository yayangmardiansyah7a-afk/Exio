@echo off
setlocal enabledelayedexpansion
title Setup Exio - Auto Install

echo ===================================================
echo   SETUP EXIO - Saat proses berjalan jangan di Close
echo ===================================================
echo.

set "TARGET_DIR=D:\MP\exio"
set "ZIP_URL=https://github.com/ym2803/Exio/releases/download/v2.0/Exio.zip"
set "ZIP_FILE=%TARGET_DIR%\Exio.zip"

REM === 1. Buat folder tujuan jika belum ada ===
if not exist "%TARGET_DIR%" (
    echo [1/7] Membuat folder %TARGET_DIR% ...
    mkdir "%TARGET_DIR%"
    if errorlevel 1 (
        echo [ERROR] Gagal membuat folder %TARGET_DIR%. Pastikan drive D: ada dan script dijalankan sebagai Administrator.
        pause
        exit /b 1
    )
) else (
    echo [1/7] Folder %TARGET_DIR% sudah ada, lanjut...
)
echo.

REM === 2. Download Exio.zip dari GitHub ===
echo [2/7] Mendownload Exio.zip dari GitHub...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "try { $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%ZIP_FILE%' -UseBasicParsing -MaximumRedirection 10 } catch { Write-Host 'DOWNLOAD_FAILED'; exit 1 }"

if not exist "%ZIP_FILE%" (
    goto DOWNLOAD_ERROR
)

REM Cek ukuran file, kalau kecil sekali kemungkinan bukan file zip asli (misal halaman HTML error)
for %%A in ("%ZIP_FILE%") do set FSIZE=%%~zA
if !FSIZE! LSS 10000 (
    goto DOWNLOAD_ERROR
)

echo       Download selesai: %ZIP_FILE%
echo.
goto CONTINUE_EXTRACT

:DOWNLOAD_ERROR
echo [ERROR] Gagal mendownload Exio.zip secara otomatis dari GitHub.
echo         Kemungkinan penyebab: koneksi internet bermasalah, atau
echo         link release sudah tidak berlaku (dihapus/diganti versi).
echo.
echo         SOLUSI MANUAL:
echo         1. Buka link berikut di browser: %ZIP_URL%
echo         2. Download file Exio.zip
echo         3. Simpan/pindahkan file tsb ke: %TARGET_DIR%\Exio.zip
echo         4. Jalankan kembali script ini untuk melanjutkan proses extract dst.
echo.
pause
exit /b 1

:CONTINUE_EXTRACT
REM === 3. Extract Exio.zip ===
echo [3/7] Mengekstrak Exio.zip ...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "try { Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TARGET_DIR%' -Force } catch { Write-Host 'EXTRACT_FAILED'; exit 1 }"

if errorlevel 1 (
    echo [ERROR] Gagal mengekstrak Exio.zip. File mungkin corrupt/tidak lengkap.
    pause
    exit /b 1
)
echo       Ekstrak selesai.
echo.

REM === 4. Hapus permanen Exio.zip setelah berhasil diekstrak ===
echo [4/7] Menghapus permanen Exio.zip ...
if exist "%ZIP_FILE%" (
    del /f /q "%ZIP_FILE%"
    if exist "%ZIP_FILE%" (
        echo [WARNING] Gagal menghapus %ZIP_FILE%. File mungkin sedang terbuka/terkunci.
    ) else (
        echo       Exio.zip berhasil dihapus permanen.
    )
)
echo.

REM === 5. Jalankan "copas sett barcode.bat" ===
set "BARCODE_BAT=%TARGET_DIR%\copas sett barcode.bat"
echo [5/7] Menjalankan "copas sett barcode.bat" ...
if exist "%BARCODE_BAT%" (
    pushd "%TARGET_DIR%"
    echo.| call "copas sett barcode.bat"
    popd
    echo       Selesai menjalankan copas sett barcode.bat
) else (
    echo [WARNING] File "copas sett barcode.bat" tidak ditemukan di %TARGET_DIR%.
    echo           Lewati langkah ini, silakan cek isi folder secara manual.
)
echo.

REM === 6. Buat shortcut Exiov2.exe ke Desktop ===
set "EXE_PATH=%TARGET_DIR%\Exiov2.exe"
echo [6/7] Membuat shortcut Exiov2.exe ke Desktop ...
if exist "%EXE_PATH%" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\Exiov2.lnk'); $Shortcut.TargetPath = '%EXE_PATH%'; $Shortcut.WorkingDirectory = '%TARGET_DIR%'; $Shortcut.Save()"
    echo       Shortcut berhasil dibuat di Desktop.
) else (
    echo [ERROR] Exiov2.exe tidak ditemukan di %TARGET_DIR%. Shortcut tidak dibuat.
    echo         Cek kembali isi folder hasil ekstrak.
    pause
)
echo.

REM === 7. Jalankan Exiov2.exe ===
echo [7/7] Menjalankan Exiov2.exe ...
if exist "%EXE_PATH%" (
    start "" "%EXE_PATH%"
    echo       Aplikasi Exiov2.exe dijalankan.
) else (
    echo [ERROR] Tidak bisa menjalankan Exiov2.exe karena file tidak ditemukan.
    pause
)
echo.

echo ===================================================
echo   SETUP SELESAI
echo ===================================================
timeout /t 5 /nobreak >nul
exit
