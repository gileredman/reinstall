# reinstall

Otomasi post-install Windows untuk menerapkan tweak umum setelah instalasi selesai.

## Tujuan
Project ini membantu menonaktifkan fitur/service tertentu secara konsisten setelah fresh install Windows.

## Fitur
- Disable News and Interests
- Disable SysMain
- Disable Telemetry (service + policy)
- Disable Xbox Services
- Disable Print Spooler (opsional)
- Disable Fax
- Disable OneDrive (uninstall + policy)

## Quick Start (Manual)
1. Jalankan PowerShell sebagai **Administrator**.
2. Dari root repository:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\scripts\postinstall-tweaks.ps1
   ```
3. Restart Windows setelah selesai.

## Mode Otomatis (SetupComplete)
1. Salin `/setup/SetupComplete.cmd` ke:
   `C:\Windows\Setup\Scripts\SetupComplete.cmd`
2. Salin `/scripts/postinstall-tweaks.ps1` ke:
   `C:\Scripts\postinstall-tweaks.ps1`
3. Saat setup selesai, Windows akan menjalankan script otomatis.

## Verifikasi
```powershell
.\scripts\verify-tweaks.ps1
```

## Rollback
```powershell
.\scripts\rollback-tweaks.ps1
```

## Catatan Penting
- Wajib dijalankan dengan hak Administrator.
- Update/build Windows dapat mengubah perilaku beberapa tweak.
- Jangan disable Print Spooler jika masih menggunakan printer.
