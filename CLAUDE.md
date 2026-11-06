# CLAUDE.md — DEKSTRA Mobile Project Context

> Dokumen ini dibaca otomatis oleh Claude Code setiap sesi baru.
> Terakhir diperbarui: 2026-11-06

---

## 1. Tentang Project Ini

**DEKSTRA** adalah aplikasi mobile Flutter untuk pelayanan surat administratif dan kependudukan tingkat desa di Kecamatan Gantiwarno, Klaten. Dibangun sebagai project Capstone semester 7 Teknik Komputer Undip, dan **aplikasi ini juga menjadi subjek Tugas Akhir (TA) Muhammad Hafizh Albanthany (NIM 21120122140148)**.

Judul TA:
> *"Analisis UI Jank dan Performa Rendering Antarmuka Aplikasi Mobile Pelayanan Desa Menggunakan Flutter DevTools"*

---

## 2. Tim Capstone

| Nama | Peran |
|---|---|
| **Muhammad Hafizh Albanthany** | Mobile developer (Flutter) — juga penulis TA ini |
| Naufal Izzudin Taufik | Backend load testing |
| Novendra Anugrah Fitriatmoko | Web frontend (Next.js) |
| Nadhif Abhirama Nayaka | Backend microservices |

Pembimbing TA:
- Pembimbing I: Kurniawan Teguh Martono, S.T., M.T.
- Pembimbing II: Kuntoro Adi Nugroho, S.T., M.Eng., Ph.D.

---

## 3. State Management — PENTING

**DEKSTRA TIDAK menggunakan GetX, Provider, Bloc, atau Riverpod.**

State management yang digunakan adalah **`StatefulWidget` + `setState()`** bawaan Flutter — state lokal per-screen. Ini sudah dikonfirmasi:
- Package `get` tidak ada di `pubspec.yaml`
- Tidak ada `ChangeNotifierProvider`, `BlocProvider`, atau `ProviderScope` di `main.dart`
- 206 occurrence `setState`/`StatefulWidget` di seluruh `lib/screens/`

Jika ada pertanyaan atau dokumentasi lama yang menyebut GetX — **abaikan, itu salah**.

---

## 4. Arsitektur Kode

```
lib/
├── main.dart                         # Entry point + portrait lock
├── theme/app_theme.dart              # Design tokens terpusat
├── models/models.dart                # Data models
├── services/api_service.dart         # Single HTTP layer + JWT management
└── screens/
    ├── auth/
    │   ├── splash_screen.dart        # [S1] Skenario Pengujian 1
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   └── forgot_password_screen.dart
    ├── beranda/
    │   ├── home_screen.dart
    │   ├── riwayat_screen.dart       # [S2] Skenario Pengujian 2
    │   ├── permohonan_detail_screen.dart
    │   └── notifikasi_screen.dart
    ├── akun/
    │   ├── akun_screen.dart
    │   └── profil_screen.dart
    └── layanan/surat/
        ├── form_surat_helpers.dart   # Shared widget library untuk semua form
        ├── umum/                     # 8 jenis surat umum
        └── kependudukan/
            ├── formulir_pendaftaran_peristiwa_screen.dart  # [S3] Skenario Pengujian 3
            └── ... (10 screen kependudukan lainnya)
```

---

## 5. Backend

- **Base URL:** `https://api.dekstra-capstone.site`
- **Auth:** JWT (access + refresh token) + OTP email 2-step
- **Endpoints utama:** lihat `README.md` untuk daftar lengkap

**Catatan pengujian TA:** Backend perlu aktif untuk S2 (Riwayat Permohonan) agar data list ter-render. S1 (Splash, diuji tanpa token) dan S3 (Formulir, rekaman berhenti sebelum submit) tidak memerlukan backend aktif.

---

## 6. Konteks Tugas Akhir — Fase Pengujian

Saat ini project memasuki **fase pengujian BAB IV**. Lihat `docs/testing_protocol.md` untuk prosedur lengkap.

### Skenario Pengujian

| Kode | Skenario | Screen File | Kompleksitas |
|---|---|---|---|
| S1 | Splash Screen | `auth/splash_screen.dart` | Rendah |
| S2 | Riwayat Permohonan | `beranda/riwayat_screen.dart` | Sedang |
| S3 | Formulir Pendaftaran Peristiwa Kependudukan (F-1.02) | `kependudukan/formulir_pendaftaran_peristiwa_screen.dart` | Tinggi |

### Kondisi Jaringan

**Tidak ada variasi kondisi jaringan.** J1/J2 (Wi-Fi/3G) sudah dihapus dari BAB III; abaikan dokumen lama yang masih menyebutnya.

### Keputusan Pengujian (November 2026)

- **S1 diuji tanpa token**: keluar lewat Akun → Keluar (menutup aplikasi tidak menghapus token). Rekaman berakhir saat tombol Masuk/Daftar tampil. Seluruh iterasi S1 dijalankan sebelum S2/S3. Iterasi yang berpindah ke Beranda dibatalkan dan diulang.
- **S3**: kolom teks memakai `TextEditingController`, jadi mengetik tidak memanggil `setState()` halaman. `setState()` halaman terjadi saat pindah tahap, memilih kategori, dan mencentang persyaratan. Rekaman S3 hanya mencakup tahap 1 → ketuk Lanjut → tahap 2 dimuat.
- **M5 (rebuild count)** hanya bisa direkam di **mode debug** (Performance View → Rebuild Stats); tidak tersedia di mode profile, dan Widget Inspector tidak menghitung rebuild.
- **M1–M4** dihitung dari berkas ekspor Performance View (DevTools tidak menampilkan angka agregat).
- Mesin grafis: Impeller (Vulkan). Layar 60 Hz.

### Metrik yang Diukur (7 Metrik)

1. Average frame build time (ms) — ekspor Performance View, mode profile
2. Average raster time (ms) — ekspor Performance View, mode profile
3. Worst frame build time (ms) — ekspor Performance View, mode profile
4. Jank frames percentage (%) — build atau raster > 16,67 ms
5. Widget rebuild count — Performance View → Rebuild Stats, **mode debug**
6. Peak heap usage (MB) — Memory View
7. CPU hot paths (%) — CPU Profiler

### Iterasi

- **10 iterasi** per skenario (30 sesi profile + 30 sesi debug untuk M5)
- **Iterasi 1** = warm-up, **dibuang** dari analisis
- **Iterasi 2–10** = data valid (9 iterasi)
- Analisis: rata-rata, min, maks, SD, interval kepercayaan 95%

### Perangkat Uji

- **Device:** Oppo A9 2020
- **SoC:** Snapdragon 665
- **GPU:** Adreno 610
- **RAM:** 8 GB
- **OS:** Android 10
- **Mode:** `flutter run --profile`

---

## 7. Software Versions

| Software | Versi |
|---|---|
| Flutter SDK | 3.41.6 |
| Dart | 3.11.4 |
| Flutter DevTools | 2.54.2 |

---

## 8. Branch & Workflow

- Branch aktif: `develop`
- Commit sebelum mulai kerja: `git fetch origin && git status`
- History Claude Code **tidak persisten** (dihapus otomatis setelah 30 hari) — gunakan file ini dan `docs/` sebagai sumber kebenaran konteks

---

## 9. File Referensi di Repo Ini

| File | Isi |
|---|---|
| `docs/environment_versions.md` | Versi SDK, Android SDK config, dependency tabel |
| `docs/portfolio.md` | Tech stack lengkap, 30 screen list, arsitektur, implementasi teknis |
| `docs/testing_protocol.md` | Prosedur pengujian step-by-step untuk BAB IV |
| `README.md` | API endpoint reference, user flow, screen structure |

---

## 10. Konteks Tambahan (jangan lupakan)

- Formatting TA: *State* dan *StatefulWidget* ditulis italic; `setState()` ditulis monospace Courier New
- Jumlah referensi final: **18 referensi** (per 2 November 2026; Syafarudin dihapus dan diganti BPS, ditambah 5 halaman dokumentasi Flutter)
- Justifikasi 10 iterasi: Ceccato et al. (ICST 2020) — ANOVA power analysis; Georges et al. (OOPSLA 2007) — warm-up justification
- Status revisi dan keputusan terbaru: lihat dokumen Project claude.ai `claude/status-ta-2026-11-02.md` (project "Apid's Capstone and Thesis Projects")
