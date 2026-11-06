# DEKSTRA — Protokol Pengujian Flutter DevTools
## Tugas Akhir: Analisis UI Jank dan Performa Rendering

> Referensi prosedur pengujian BAB IV. Isinya mengikuti BAB III naskah TA (revisi November 2026).
> Versi: 2.0 — 2026-11-06. Versi 1.0 (2026-10-28) **usang**: masih memuat kondisi jaringan J1/J2, S1 dengan "hapus data app", dan M5 dari Widget Inspector.

---

## 1. Tujuan Pengujian

Mengukur dan menganalisis *UI jank* serta performa *rendering* antarmuka DEKSTRA pada tiga skenario dengan tingkat kompleksitas berbeda, menggunakan Flutter DevTools.

Penelitian ini **tidak** memakai variasi kondisi jaringan. Kondisi J1/J2 (Wi-Fi/3G) dari versi 1.0 sudah dihapus dari BAB III.

---

## 2. Perangkat & Lingkungan

| Item | Spesifikasi |
|---|---|
| Perangkat | Oppo A9 2020 (Snapdragon 665, Adreno 610, RAM 8 GB, Android 10 / API 29) |
| Layar | 60 Hz (batas *frame* 16,67 ms) |
| Mesin grafis | Impeller (Vulkan), dikonfirmasi dari log `flutter run` |
| Flutter SDK / Dart | 3.41.6 / 3.11.4 |
| Flutter DevTools | 2.54.2 |
| Mode utama | `flutter run --profile` (metrik 1–4, 6, 7) |
| Mode tambahan | `flutter run` (debug), khusus metrik 5 |

---

## 3. Skenario Pengujian

| Kode | Halaman | Berkas | Kompleksitas | Kondisi awal |
|---|---|---|---|---|
| S1 | Splash Screen | `lib/screens/auth/splash_screen.dart` | Rendah | **Tanpa token** (sudah keluar akun) |
| S2 | Riwayat Permohonan | `lib/screens/beranda/riwayat_screen.dart` | Sedang | Sudah masuk akun, internet aktif |
| S3 | Formulir Pendaftaran Peristiwa Kependudukan (F-1.02) | `lib/screens/layanan/surat/kependudukan/formulir_pendaftaran_peristiwa_screen.dart` | Tinggi | Sudah masuk akun, semua kolom kosong |

### Interaksi standar (sesuai Tabel 3.3)

| Skenario | Mulai rekam | Interaksi | Berhenti |
|---|---|---|---|
| S1 | Logo muncul | Tidak ada (tunggu saja) | Tombol **Masuk** dan **Daftar** tampil |
| S2 | Halaman mulai dimuat (dibuka dari menu navigasi bawah) | Gulir daftar 3× ke bawah, lalu 3× ke atas | Setelah guliran terakhir |
| S3 | Halaman formulir terbuka (Layanan → Kependudukan → F-1.02) | Isi 4 kolom tahap 1 (Nama, NIK, No. KK, No. HP), lalu ketuk **Lanjut** | Tahap 2 selesai dimuat. **Jangan** sampai submit |

---

## 4. Metrik

| No | Metrik | Sumber | Mode | Satuan |
|---|---|---|---|---|
| M1 | Rata-rata waktu penyusunan *frame* (UI thread) | Ekspor Performance View | profile | ms |
| M2 | Rata-rata waktu penggambaran *frame* (raster thread) | Ekspor Performance View | profile | ms |
| M3 | Waktu penyusunan *frame* terlama | Ekspor Performance View | profile | ms |
| M4 | Persentase *jank frame* (build atau raster > 16,67 ms) | Ekspor Performance View | profile | % |
| M5 | Jumlah pembangunan ulang *widget* | Performance View → Rebuild Stats / ekspor sesi debug | **debug** | kali |
| M6 | Penggunaan memori puncak (*peak heap*) | Memory View | profile | MB |
| M7 | Fungsi dengan beban CPU tertinggi (*hot path*) | CPU Profiler | profile | % |

Catatan:
- DevTools **tidak** menampilkan angka agregat (rata-rata, terlama, persentase *jank*). M1–M4 dihitung dari berkas ekspor oleh skrip `olah_data_bab4.py`.
- Opsi penghitung *build widget* **tidak bisa diaktifkan** di mode profile, karena bergantung pada `debugOnRebuildDirtyWidget` yang hanya ada di mode debug. *Widget Inspector* tidak menghitung *rebuild*.
- Ambang *jank* yang dipakai adalah 16,67 ms persis (BAB III). Aturan bawaan DevTools membulatkan ke bawah, sehingga hasilnya bisa sedikit berbeda dari tanda merah di layar.

---

## 5. Iterasi

- 10 iterasi per skenario. Iterasi 1 adalah pemanasan dan **dibuang**; iterasi 2–10 = 9 data valid (Ceccato dkk., ICST 2020; Georges dkk., OOPSLA 2007).
- Sesi mode profile: 3 skenario × 10 iterasi = **30 sesi**.
- Sesi mode debug (M5): 3 skenario × 10 iterasi = **30 sesi**, dengan interaksi standar yang sama.

---

## 6. Urutan Pengujian

1. **Keluar dari akun** (Akun → Keluar). Menutup aplikasi saja tidak menghapus token.
2. Jalankan **seluruh iterasi S1** (profile, lalu debug).
3. **Masuk kembali** ke akun.
4. Jalankan seluruh iterasi S2, lalu S3.

---

## 7. Prosedur per Iterasi

### Persiapan (sekali per sesi pengujian)
1. Baterai ≥ 50%, aplikasi lain ditutup, kecerahan layar dikunci.
2. Hubungkan perangkat lewat USB (USB *debugging* aktif), lalu cek dengan `flutter devices`.

### Langkah
1. **Tutup aplikasi sepenuhnya** (keluarkan dari daftar aplikasi terbaru).
2. Jalankan `flutter run --profile` (atau `flutter run` untuk sesi M5).
3. Buka DevTools dari URL di terminal, lalu buka **Performance View**.
4. Siapkan rekaman:
   - **S1: JANGAN tekan Clear.** *Frame* sejak aplikasi dibuka tetap terkirim ke DevTools walaupun DevTools baru dibuka belakangan. Clear akan menghapus *frame* awal splash.
   - **S2/S3: tekan Clear** tepat sebelum interaksi dimulai, karena *frame* dari halaman sebelumnya menumpuk.
5. Lakukan interaksi standar (Bagian 3).
6. **Ekspor** data Performance View (tombol Export), lalu simpan dengan penamaan berkas sesuai petunjuk skrip `olah_data_bab4.py`.
7. Sesi profile saja: catat **memori puncak** dari Memory View dan **hot path** dari CPU Profiler (rekam ulang dengan interaksi yang sama), lalu isi ke `catatan_manual.csv`.
8. Sesi debug saja: aktifkan opsi penghitung *build widget* di Performance View sebelum interaksi. Data *rebuild* ikut terekam di berkas ekspor.
   - **Khusus S1 debug:** splash sudah selesai (±1,2 detik) sebelum DevTools sempat dibuka, dan penghitung *rebuild* tidak berlaku mundur. Jalankan `flutter run --start-paused`, buka DevTools, aktifkan penghitung *build widget*, lalu lanjutkan aplikasi (Resume di DevTools). Uji coba sekali dulu untuk memastikan *frame* awal splash ikut terhitung.
9. Hentikan `flutter run` (Ctrl+C), lalu ulangi dari langkah 1.

---

## 8. Validasi Khusus S1

- Iterasi yang berpindah ke **Beranda** berarti token masih tersimpan. **Batalkan dan ulangi** setelah keluar akun, lalu catat jumlah iterasi yang diulang (dipakai di BAB IV 4.1).
- Skrip memotong rekaman S1 pada *frame* terakhir sebelum jeda > 200 ms (dihitung setelah detik pertama), lalu menandai durasinya:
  - > 1,8 detik: kemungkinan token masih tersimpan, ulangi iterasi.
  - < 1,15 detik: *frame* awal hilang (kemungkinan Clear tertekan), ulangi iterasi.
- Backend tidak perlu aktif untuk S1.

## 9. Catatan S2 dan S3

- **S2:** backend **harus aktif** (`GET /riwayat-pengajuan/`), dan akun harus punya data riwayat. Kalau yang tampil keadaan galat atau daftar kosong, data iterasi itu tidak dipakai.
- **S3:** keempat kolom teks memakai `TextEditingController`, jadi mengetik tidak memanggil `setState()` halaman. `setState()` halaman berjalan saat berpindah tahap (ketuk Lanjut). Backend tidak diperlukan karena rekaman berhenti sebelum submit.

---

## 10. Analisis

Statistik deskriptif komparatif dari 9 iterasi valid per skenario: rata-rata, minimum, maksimum, standar deviasi, dan interval kepercayaan 95% (distribusi t, df = 8). Tidak memakai uji inferensial, kecuali diminta pembimbing.

---

## 11. Troubleshooting

| Masalah | Solusi |
|---|---|
| DevTools tidak terhubung | Hentikan `flutter run`, lalu jalankan ulang |
| Opsi penghitung *build* tidak bisa dicentang | Wajar di mode profile; gunakan sesi `flutter run` (debug) |
| S1 berpindah ke Beranda | Keluar akun, lalu ulangi iterasi |
| S2 galat/kosong | Periksa backend; tunda S2 bila tidak aktif |
| Hasil iterasi menyimpang ekstrem | Jangan dihapus; catat dan bahas di BAB IV |
| Galat build | `flutter clean && flutter pub get`, lalu ulangi |
