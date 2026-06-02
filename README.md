# DEKSTRA — Aplikasi Layanan Surat Digital Desa

Aplikasi mobile Flutter untuk pengurusan surat kependudukan dan umum secara digital di tingkat desa/kelurahan.

---

## Tech Stack

| Layer | Teknologi |
|---|---|
| Mobile | Flutter (Dart) |
| Backend | Django REST Framework |
| Auth | JWT + OTP Email |
| HTTP | `package:http` |
| State | `setState` / `ValueNotifier` |
| Storage | `shared_preferences` |

---

## Cara Menjalankan

**Prasyarat:** Flutter SDK ≥ 3.x, Android Studio atau VS Code

```bash
# Install dependencies
flutter pub get

# Jalankan di emulator/device
flutter run

# Build APK release
flutter build apk --release
```

---

## Struktur Layar

```
lib/
├── main.dart
├── theme/
├── services/
│   └── api_service.dart
└── screens/
    ├── auth/          # Splash, Login, Register, Reset Password
    ├── beranda/       # Home, Notifikasi
    ├── profil/        # Profil pengguna
    └── layanan/
        └── surat/
            ├── umum/           # A01 SKU, A02 SK Tempat Usaha
            └── kependudukan/   # B03–B10
```

---

## Jenis Surat

**Layanan Umum (8)**

| Nama Surat |
|---|
| Surat Keterangan Usaha |
| Surat Keterangan Tempat Usaha |
| Surat Keterangan Pengantar Barang |
| Surat Keterangan Tidak Mampu (Sekolah) |
| Permohonan Izin Keramaian / Pesta |
| Surat Pengantar SKCK |
| Surat Keterangan Ahli Waris |
| Surat Keterangan Lainnya |

**Layanan Kependudukan (11)**

| Nama Surat |
|---|
| Formulir Kartu Keluarga (F-1.01) |
| Formulir Pendaftaran Peristiwa Kependudukan (F-1.02) |
| Formulir Permohonan KK Baru WNI (F-1.15) |
| Formulir Permohonan Perubahan KK WNI (F-1.16) |
| Formulir Permohonan KTP (F-1.21) |
| Surat Keterangan Domisili |
| Surat Keterangan Hilang Kartu Keluarga |
| Surat Keterangan Pindah |
| Formulir Pendaftaran Perpindahan Penduduk (F-1.03) |
| Surat Keterangan Kelahiran (F-2.01) |
| Surat Keterangan Kematian (F-2.29) |

---

## API Endpoints

**Base URL:** `https://api.dekstra-capstone.site`

### Wilayah

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| GET | `/wilayah/rw/` | — | Daftar semua RW |
| GET | `/wilayah/rt/?rw={kodeRw}` | — | Daftar RT berdasarkan RW |

### Autentikasi

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| POST | `/auth/register/` | — | Registrasi akun baru (multipart/form-data) |
| POST | `/auth/otp/request/login/` | — | Request OTP login ke email |
| POST | `/auth/login/` | — | Login dengan OTP, terima JWT |
| POST | `/auth/otp/request/reset-password/` | — | Request OTP reset password |
| POST | `/auth/otp/verify/reset-password/` | — | Verifikasi OTP & ganti password |
| POST | `/auth/refresh/` | — | Refresh access token |

**Login Flow:**
1. `POST /auth/otp/request/login/` → OTP dikirim ke email
2. `POST /auth/login/` dengan OTP → terima `access` + `refresh` JWT

**Register Fields (multipart):** `nomor_kk`, `nik`, `nama_lengkap`, `jenis_kelamin` (int), `agama` (int), `tempat_lahir`, `tanggal_lahir` (YYYY-MM-DD), `alamat`, `rt` (id), `rw` (kode_rw), `email`, `no_hp`, `password`, `kk_file` (image), `ktp_file` (image)

### Profil

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| GET | `/profil/` | Bearer | Data profil pengguna |
| PUT | `/profil/` | Bearer | Update nama, no_hp, alamat |

### Pengajuan Surat

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| GET | `/pengajuan-surat/` | Bearer | Daftar permohonan aktif milik warga |
| POST | `/pengajuan-surat/` | Bearer | Submit permohonan surat baru |
| POST | `/upload/berkas-surat/` | Bearer | Upload berkas pendukung (multipart) |

**Submit Payload:**
```json
{
  "jenis_surat": "A01",
  "data": { ... }
}
```

### Riwayat Pengajuan

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| GET | `/riwayat-pengajuan/` | Bearer | Riwayat permohonan (Disetujui/Ditolak) |
| GET | `/riwayat-pengajuan/{nomor_permohonan}/` | Bearer | Detail + timeline permohonan |

### Notifikasi

| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| GET | `/notifikasi/` | Bearer | Daftar notifikasi milik user |
| POST | `/notifikasi/{id}/read/` | Bearer | Tandai notifikasi sudah dibaca |

---

## Alur Pengguna

```
Daftar → (Admin setujui akun) → Login (NIK/email + password + OTP)
→ Pilih jenis surat → Isi formulir step-by-step → Submit
→ Notifikasi status (RT → RW → Kepala Desa) → Surat selesai
```

---

## Catatan

- Hanya role **Warga** yang dapat menggunakan aplikasi mobile ini
- Orientasi layar dikunci ke **portrait** (atas & bawah)
- Token JWT disimpan di `SharedPreferences`, auto-refresh jika expired
