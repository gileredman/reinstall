# Features

## Disable News and Interests
- Menetapkan policy `EnableFeeds=0` pada `HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds`.
- Menetapkan `ShellFeedsTaskbarViewMode=2` pada profile user saat ini.

## Disable SysMain
- Menghentikan service `SysMain` jika aktif.
- Mengubah startup type menjadi `Disabled`.

## Disable Telemetry
- Menghentikan dan menonaktifkan `DiagTrack` dan `dmwappushservice`.
- Menetapkan policy `AllowTelemetry=0` pada `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection`.

## Disable Xbox Services
- Menonaktifkan `XblAuthManager`, `XblGameSave`, `XboxNetApiSvc`, dan `XboxGipSvc`.

## Disable Print Spooler (Opsional)
- Dikontrol variabel `$DisablePrintSpooler` (default: `$true`).
- Jika aktif, service `Spooler` akan dihentikan dan di-disable.

## Disable Fax
- Menonaktifkan service `Fax` jika tersedia.

## Disable OneDrive
- Menghentikan proses OneDrive jika sedang berjalan.
- Menjalankan uninstall melalui `SysWOW64\OneDriveSetup.exe` lalu fallback `System32\OneDriveSetup.exe`.
- Menetapkan policy `DisableFileSyncNGSC=1` untuk mencegah sinkronisasi OneDrive.
