# DEKSTRA — Portfolio Description

## 1. Project Name & Purpose

**DEKSTRA** (Desa Digital — Layanan Surat Warga) adalah aplikasi mobile Android yang mendigitalisasi proses pengajuan surat administratif dan kependudukan di tingkat desa/kelurahan.

**Masalah yang diselesaikan:** Warga umumnya harus datang langsung ke kantor desa, mengantri, mengisi formulir kertas, dan menunggu proses persetujuan berlapis yang bisa memakan beberapa hari. DEKSTRA memindahkan seluruh alur tersebut ke smartphone — warga mengisi formulir digital, melampirkan dokumen, dan memantau status persetujuan secara real-time tanpa perlu hadir secara fisik.

---

## 2. Complete Tech Stack

| Kategori | Teknologi |
|---|---|
| **Framework** | Flutter 3.x (Dart SDK ≥3.0) |
| **UI Design System** | Material Design 3, custom theme (teal `#2D7A6F`) |
| **Typography** | Google Fonts — Poppins (via `google_fonts ^6.1.0`) |
| **HTTP Client** | `http ^1.2.0` |
| **Authentication** | JWT (access + refresh token) + OTP email 2-step |
| **Local Storage** | `shared_preferences ^2.2.2` |
| **File/Image** | `image_picker ^1.0.7` |
| **URL Handling** | `url_launcher ^6.2.0` |
| **Backend** | Django REST Framework + Celery (dikonsumsi via REST API) |
| **Min Android SDK** | API 21 (Android 5.0 Lollipop) |
| **Version Control** | Git (branching: `develop` → `main`) |
| **Build Tools** | Gradle, flutter_launcher_icons |

---

## 3. All Screens (30 Files)

**Auth (4 screens)**
- Splash Screen — animated logo, auto session restore
- Login Screen — NIK/email + password + OTP
- Register Screen — pendaftaran akun baru dengan upload KTP & KK
- Forgot Password Screen — reset via OTP email

**Main Navigation (6 screens)**
- Home Screen — dashboard beranda
- Layanan Screen — katalog surat (grid, tab, search)
- Riwayat Screen — riwayat pengajuan
- Notifikasi Screen — notifikasi status
- Akun Screen — menu akun
- Profil Screen — edit profil

**Detail**
- Permohonan Detail Screen — detail + timeline persetujuan

**Layanan Umum (8 form screens)**
- Surat Keterangan Usaha
- Surat Keterangan Tempat Usaha
- Surat Pengantar Barang
- Surat Keterangan Tidak Mampu
- Permohonan Izin Keramaian
- Surat Pengantar SKCK
- Surat Keterangan Ahli Waris
- Surat Keterangan Lainnya

**Layanan Kependudukan (11 form screens)**
- Formulir KK Pengganti (F-1.01)
- Formulir Pendaftaran Peristiwa Kependudukan (F-1.02)
- Formulir Permohonan KK Baru (F-1.15)
- Formulir Perubahan KK (F-1.16)
- Formulir Permohonan KTP (F-1.21)
- Surat Keterangan Domisili
- Surat Keterangan Hilang KK
- Surat Keterangan Pindah
- Formulir Perpindahan Penduduk (F-1.03)
- Surat Keterangan Kelahiran (F-2.01)
- Surat Keterangan Kematian (F-2.29)

---

## 4. Architecture Overview

```
lib/
├── main.dart                    # Entry point + orientation lock
├── theme/app_theme.dart         # Centralized design tokens (colors, typography, button/input themes)
├── services/api_service.dart    # Single API layer — semua HTTP calls + token management
└── screens/
    ├── auth/                    # Auth flow screens
    ├── beranda/                 # Post-login main screens
    ├── akun/                    # Profile management
    └── layanan/surat/
        ├── form_surat_helpers.dart   # Shared widget library (core)
        ├── umum/                     # 8 general letter screens
        └── kependudukan/             # 11 civil registration screens
```

**Design Patterns:**
- **Feature-based folder structure** — screens dikelompokkan per domain
- **Shared helper library** (`form_surat_helpers.dart`) — semua 19 form screen menggunakan widget dan validator yang sama
- **Single service layer** — satu file `api_service.dart` menangani seluruh HTTP, token storage, dan error parsing
- **Generic Stepper Widget** (`SuratStepperPage`) — satu komponen reusable yang dipakai seluruh form surat
- **Centralized theme** — design tokens (warna, font, border radius) terdefinisi satu tempat

---

## 5. Notable Technical Implementations

**A. Generic Multi-Step Form Wizard (`SuratStepperPage`)**
Komponen inti yang menangani seluruh 19 form surat. Menerima list `SuratDataStep` (step data yang dinamis), mengelola navigasi antar step dengan per-step form validation, lalu secara otomatis menambahkan dua step fixed di akhir: Upload Dokumen dan Kirim Pengajuan (dengan agreement checkbox). Setelah submit, melakukan sequential API calls: `POST /pengajuan-surat/` kemudian `POST /upload/berkas-surat/` untuk setiap file lampiran.

**B. JWT Authentication dengan Auto Session Restore**
`SplashScreen` secara otomatis memeriksa token tersimpan di `SharedPreferences`. Jika ada token tapi expired (HTTP 401), mencoba `refreshAccessToken()` menggunakan refresh token. Jika berhasil, langsung masuk ke `HomeScreen` tanpa perlu login ulang. Alur ini transparan bagi pengguna.

**C. 2-Step OTP Login**
Login membutuhkan dua API call: pertama `POST /auth/otp/request/login/` mengirim OTP ke email, lalu `POST /auth/login/` dengan OTP + kredensial menerima JWT. Sama diterapkan untuk reset password.

**D. Centralized Error Handling (`ApiException`)**
Kelas `ApiException` mem-parse berbagai format error DRF (`{"detail": "..."}`, `{"field": ["..."]}`, `{"non_field_errors": [...]}`) menjadi pesan string tunggal yang siap ditampilkan ke user via `SnackBar`.

**E. Input Validation Layer**
Validator terpusat di `form_surat_helpers.dart`: `validateNIK` (16 digit), `validatePhone` (9–13 digit), `validateNonZeroInt`, `validateDate`, `validateRequired`. Input formatter `nikFormatters`, `angkaFormatters`, `kodePosFormatters` memastikan keyboard type dan panjang karakter dibatasi di sisi UI.

**F. Dynamic Family Member Table**
Komponen `buildTabelAnggota` dengan `AnggotaKK` model memungkinkan pengguna menambah/menghapus anggota keluarga secara dinamis dengan `setState`, setiap baris memiliki controller dan validator sendiri.

**G. Screen Orientation Lock**
`SystemChrome.setPreferredOrientations([portraitUp, portraitDown])` dipanggil di `main()` sebelum `runApp()` memastikan UI hanya berjalan portrait di semua device Android.

---

## 6. Target Users & Use Case

**Primary User:** Warga desa (role: Warga) dengan smartphone Android
**Secondary Users (backend/admin panel):** RT, RW, Kepala Desa sebagai approver

**Use Case:**
Warga membutuhkan surat keterangan (misal: SKU untuk permohonan kredit, atau Surat Pindah untuk lapor diri di daerah baru). Alih-alih datang ke kantor, warga membuka DEKSTRA, memilih jenis surat, mengisi formulir multi-step, melampirkan foto dokumen pendukung, dan submit. Permohonan masuk ke antrian persetujuan RT → RW → Kepala Desa. Setiap perubahan status mengirimkan notifikasi ke aplikasi.

---

## 7. Notable Challenges Solved

| Challenge | Solusi |
|---|---|
| 19 form surat memiliki struktur berbeda namun UI serupa | Generic `SuratStepperPage` + `SuratDataStep` — setiap form hanya mendefinisikan step content dan payload, infrastruktur wizard dihandle oleh satu komponen |
| Field payload harus exact-match dengan template dokumen backend | Cross-check manual setiap key antara Flutter form dan Django template variable |
| Image upload bekerja di web & mobile | `MultipartFile.fromBytes()` (bukan `fromPath`) sehingga tidak bergantung pada `dart:io` |
| Token expired tanpa memaksa logout | Silent token refresh di splash screen — jika access token expired, refresh otomatis sebelum navigasi |
| Form dengan anggota keluarga yang jumlahnya dinamis | `List<AnggotaKK>` dengan controller lifecycle management (`dispose()` manual saat item dihapus) |
| Build error cross-drive (project D:, Pub cache C:) | `flutter clean` sebelum build untuk reset Kotlin incremental cache |
