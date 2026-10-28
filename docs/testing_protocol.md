# DEKSTRA — Protokol Pengujian Flutter DevTools
## Tugas Akhir: Analisis UI Jank dan Performa Rendering

> Dokumen ini adalah referensi prosedur pengujian BAB IV.
> Versi: 1.0 — 2026-10-28

---

## 1. Tujuan Pengujian

Mengukur dan menganalisis UI jank serta performa rendering antarmuka aplikasi DEKSTRA pada tiga skenario dengan dua kondisi jaringan menggunakan Flutter DevTools, untuk mengevaluasi kelayakan performa dari perspektif pengguna akhir.

---

## 2. Perangkat & Environment

| Item | Spesifikasi |
|---|---|
| Device | Oppo A9 2020 |
| SoC | Qualcomm Snapdragon 665 |
| GPU | Adreno 610 |
| RAM | 8 GB |
| OS | Android 10 |
| Flutter mode | Profile (`flutter run --profile`) |
| Flutter SDK | 3.41.6 |
| Dart | 3.11.4 |
| Flutter DevTools | 2.54.2 |

---

## 3. Skenario Pengujian

| Kode | Nama Skenario | Screen | Kompleksitas |
|---|---|---|---|
| S1 | Splash Screen | `lib/screens/auth/splash_screen.dart` | Rendah |
| S2 | Riwayat Permohonan | `lib/screens/beranda/riwayat_screen.dart` | Sedang |
| S3 | Formulir Pendaftaran Peristiwa Kependudukan (F-1.02) | `lib/screens/layanan/surat/kependudukan/formulir_pendaftaran_peristiwa_screen.dart` | Tinggi |

---

## 4. Kondisi Jaringan

| Kode | Kondisi | Cara Simulasi |
|---|---|---|
| J1 | Wi-Fi Normal | Koneksi Wi-Fi stabil, tanpa throttle |
| J2 | 3G Simulasi | Android Developer Options → Network Conditioning → pilih `3G` (~750 Kbps / 300ms latency) |

---

## 5. Metrik yang Diukur

| No | Metrik | Sumber DevTools | Satuan |
|---|---|---|---|
| M1 | Average frame build time | Performance View → Frame Chart | ms |
| M2 | Average raster time | Performance View → Frame Chart | ms |
| M3 | Worst frame build time | Performance View → Frame Chart | ms |
| M4 | Jank frames percentage | Performance View → Frame Chart | % |
| M5 | Widget rebuild count | Widget Inspector → Rebuild Stats | count |
| M6 | Peak heap usage | Memory View → Heap Chart | MB |
| M7 | CPU hot paths | CPU Profiler → Flame Chart | % |

> **Definisi UI Jank:** Frame tidak selesai dirender dalam budget 16.67 ms (threshold 60 fps). Frame yang melewati threshold ini dihitung sebagai jank frame.

---

## 6. Jumlah Iterasi

- **Total iterasi per skenario per kondisi jaringan:** 10
- **Iterasi 1:** Warm-up — data **dibuang**, tidak dimasukkan ke analisis
- **Iterasi 2–10:** Data valid — **9 iterasi** yang dianalisis
- **Justifikasi:** Ceccato et al. (ICST 2020) — ANOVA power analysis memvalidasi 10 repetisi (power > 0.8); Georges et al. (OOPSLA 2007) — justifikasi pembuangan iterasi pertama sebagai warm-up

**Total pengujian:** 3 skenario × 2 kondisi × 10 iterasi = **60 sesi pengujian**

---

## 7. Prosedur Pengambilan Data (Per Iterasi)

### Persiapan Awal (Sekali per Sesi Pengujian)

1. Pastikan perangkat Oppo A9 2020 dalam kondisi:
   - Baterai ≥ 50%
   - Tidak ada aplikasi lain berjalan di background (tutup semua app)
   - Brightness dikunci (tidak auto)
   - Mode pesawat OFF (kecuali simulasi J2 menggunakan Developer Options)
2. Hubungkan device ke komputer via USB (USB Debugging aktif)
3. Verifikasi koneksi: `flutter devices`
4. Set kondisi jaringan sesuai skenario (J1 atau J2)

### Langkah Per Iterasi

**Langkah 1 — Reset state aplikasi**
```bash
# Tutup aplikasi jika sedang berjalan
# Hapus data app (opsional untuk konsistensi): Settings → Apps → DEKSTRA → Clear Data
```

**Langkah 2 — Jalankan dalam profile mode**
```bash
flutter run --profile
```

**Langkah 3 — Buka Flutter DevTools**
- DevTools akan terbuka otomatis, atau akses URL yang ditampilkan di terminal
- Pastikan semua 4 tab aktif: Performance, Widget Inspector, Memory, CPU Profiler

**Langkah 4 — Navigasi ke skenario**
- S1: Tidak perlu navigasi — Splash Screen tampil otomatis saat launch
- S2: Login → tap tab "Riwayat" di bottom navigation
- S3: Login → tap "Layanan" → pilih "Kependudukan" → tap "Formulir Pendaftaran Peristiwa Kependudukan (F-1.02)"

**Langkah 5 — Mulai rekam di DevTools**
- Performance View: klik **Record** sebelum interaksi dimulai
- Memory View: pastikan heap chart aktif merekam
- CPU Profiler: klik **Record** bersamaan

**Langkah 6 — Lakukan interaksi skenario**

| Skenario | Interaksi yang Direkam |
|---|---|
| S1 | Tunggu animasi splash selesai hingga navigasi ke Login Screen |
| S2 | Scroll list riwayat permohonan dari atas ke bawah (3× scroll penuh) |
| S3 | Navigasi melalui semua step formulir (step 1 → step 2 → dst.) tanpa submit |

**Langkah 7 — Stop rekaman**
- Performance View: klik **Stop**
- CPU Profiler: klik **Stop**

**Langkah 8 — Catat data**

Catat ke tabel hasil (lihat Bagian 9):
- M1, M2, M3, M4 dari Performance View → Frame Chart (hover tiap frame atau lihat summary)
- M5 dari Widget Inspector → Rebuild Stats (aktifkan "Track Widget Rebuilds")
- M6 dari Memory View → nilai peak pada heap chart
- M7 dari CPU Profiler → hot path dengan persentase tertinggi

**Langkah 9 — Reset untuk iterasi berikutnya**
- Tutup DevTools
- Stop `flutter run` (Ctrl+C)
- Ulangi dari Langkah 1

---

## 8. Catatan Khusus per Skenario

### S1 — Splash Screen
- Backend **tidak perlu aktif** — splash hanya cek token di SharedPreferences
- Jika ada token tersimpan, splash akan auto-navigate ke HomeScreen setelah token check
- Untuk konsistensi: **hapus data app** sebelum setiap iterasi agar splash selalu mulai dari kondisi fresh (tidak ada cached token)
- Durasi rekaman: sejak app launch hingga navigasi keluar dari splash

### S2 — Riwayat Permohonan
- Backend **harus aktif** — screen memanggil `GET /riwayat-pengajuan/` untuk mengisi list
- Gunakan akun yang sudah memiliki data riwayat permohonan agar list tidak kosong
- Jika backend tidak aktif: screen akan render error state — data ini **tidak representatif**, jangan dipakai
- Durasi rekaman: sejak screen mount hingga selesai 3× scroll

### S3 — Formulir Pendaftaran Peristiwa Kependudukan (F-1.02)
- Backend **tidak perlu aktif** untuk mengukur rendering form — semua step form adalah pure local UI
- Backend diperlukan hanya di step Submit (step terakhir) — **jangan tap submit** saat rekaman
- Durasi rekaman: sejak screen mount hingga selesai navigasi semua step formulir

---

## 9. Template Tabel Hasil

### Format Per Iterasi

| Iterasi | M1 (ms) | M2 (ms) | M3 (ms) | M4 (%) | M5 (count) | M6 (MB) | M7 (%) |
|---|---|---|---|---|---|---|---|
| 1 (warm-up) | — | — | — | — | — | — | — |
| 2 | | | | | | | |
| 3 | | | | | | | |
| 4 | | | | | | | |
| 5 | | | | | | | |
| 6 | | | | | | | |
| 7 | | | | | | | |
| 8 | | | | | | | |
| 9 | | | | | | | |
| 10 | | | | | | | |
| **Rata-rata (2–10)** | | | | | | | |
| **Std. Dev** | | | | | | | |

### Kombinasi Pengujian

Buat tabel terpisah untuk setiap kombinasi:

- `S1_J1` — Splash Screen, Wi-Fi Normal
- `S1_J2` — Splash Screen, 3G Simulasi
- `S2_J1` — Riwayat Permohonan, Wi-Fi Normal
- `S2_J2` — Riwayat Permohonan, 3G Simulasi
- `S3_J1` — Formulir F-1.02, Wi-Fi Normal
- `S3_J2` — Formulir F-1.02, 3G Simulasi

---

## 10. Analisis Statistik

Analisis yang digunakan: **statistik deskriptif**

- Nilai rata-rata (mean) dari iterasi 2–10
- Nilai standar deviasi
- Nilai minimum dan maksimum
- Identifikasi jank: frame yang melewati 16.67 ms = jank frame

Tidak menggunakan uji inferensial (ANOVA, t-test) — cukup deskriptif sesuai batasan penelitian.

---

## 11. Troubleshooting

| Masalah | Solusi |
|---|---|
| DevTools tidak connect | Stop flutter run, jalankan ulang dengan `flutter run --profile` |
| Performance View tidak merekam | Pastikan mode Profile (bukan Debug) |
| Heap chart kosong | Klik "GC" sekali untuk trigger garbage collection, lalu mulai rekam |
| Backend tidak bisa diakses | Untuk S2: tunda pengujian atau hubungi tim backend (Naufal/Nadhif). Untuk S1 & S3: lanjutkan pengujian |
| Data iterasi anomali (outlier ekstrem) | Catat, tidak dihapus otomatis — dokumentasikan dalam BAB IV sebagai catatan |
| Build error sebelum run | `flutter clean && flutter pub get` lalu ulangi |
