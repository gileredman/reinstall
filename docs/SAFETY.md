# Safety Notes

## Hak Akses
- Semua script tweak membutuhkan hak Administrator.
- Jalankan dari PowerShell yang sudah elevated.

## Potensi Dampak
- Menonaktifkan `Spooler` akan mematikan kemampuan print.
- Menonaktifkan `DiagTrack`/`dmwappushservice` dapat memengaruhi komponen diagnosis tertentu.
- Menonaktifkan Xbox services dapat memengaruhi fitur Xbox/Game Pass.
- Menonaktifkan OneDrive akan menghentikan sinkronisasi cloud terkait OneDrive.

## Kapan Tidak Perlu Disable
- Jangan disable `Spooler` jika perangkat digunakan untuk mencetak.
- Jangan disable Xbox services jika membutuhkan login/fitur Xbox.
- Jangan uninstall OneDrive jika sinkronisasi file cloud masih dipakai.

## Praktik Aman
- Jalankan `scripts/verify-tweaks.ps1` setelah tweak diterapkan.
- Gunakan `scripts/rollback-tweaks.ps1` untuk mengembalikan default aman bila diperlukan.
- Restart Windows setelah apply tweak atau rollback untuk memastikan state konsisten.
