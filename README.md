# DEKSTRA — Digital Village Letter Service Application

A Flutter mobile application for processing administrative and civil registration letters digitally at the village level.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter (Dart) |
| Backend | Django REST Framework |
| Auth | JWT + OTP Email |
| HTTP | `package:http` |
| State | `setState` / `ValueNotifier` |
| Storage | `shared_preferences` |

---

## Getting Started

**Prerequisites:** Flutter SDK ≥ 3.x, Android Studio or VS Code

```bash
# Install dependencies
flutter pub get

# Run on emulator/device
flutter run

# Build release APK
flutter build apk --release
```

---

## Screen Structure

```
lib/
├── main.dart
├── theme/
├── services/
│   └── api_service.dart
└── screens/
    ├── auth/          # Splash, Login, Register, Reset Password
    ├── beranda/       # Home, Notifications, History, Request Detail
    ├── profil/        # User profile
    └── layanan/
        └── surat/
            ├── umum/           # General letters (8 types)
            └── kependudukan/   # Civil registration letters (11 types)
```

---

## Letter Services

**General Letters (8)**

| Letter Name |
|---|
| Business Certificate |
| Business Location Certificate |
| Goods Delivery Cover Letter |
| Certificate of Underprivilege (Education) |
| Permit for Public Gatherings / Events |
| Police Record (SKCK) Cover Letter |
| Certificate of Heir |
| Other General Certificate |

**Civil Registration Letters (11)**

| Letter Name |
|---|
| Family Card Form (F-1.01) |
| Civil Event Registration Form (F-1.02) |
| New Family Card Application — Indonesian Citizen (F-1.15) |
| Family Card Amendment Application — Indonesian Citizen (F-1.16) |
| National ID Card Application (F-1.21) |
| Certificate of Domicile |
| Certificate of Lost Family Card |
| Certificate of Relocation |
| Resident Relocation Registration Form (F-1.03) |
| Birth Certificate (F-2.01) |
| Death Certificate (F-2.29) |

---

## API Endpoints

**Base URL:** `https://api.dekstra-capstone.site`

### Area / Region

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/wilayah/rw/` | — | List all RW (neighbourhood units) |
| GET | `/wilayah/rt/?rw={kodeRw}` | — | List RT by RW |

### Authentication

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/auth/register/` | — | Register new account (multipart/form-data) |
| POST | `/auth/otp/request/login/` | — | Request login OTP via email |
| POST | `/auth/login/` | — | Login with OTP, receive JWT |
| POST | `/auth/otp/request/reset-password/` | — | Request password reset OTP |
| POST | `/auth/otp/verify/reset-password/` | — | Verify OTP & set new password |
| POST | `/auth/refresh/` | — | Refresh access token |

**Login Flow:**
1. `POST /auth/otp/request/login/` → OTP sent to email
2. `POST /auth/login/` with OTP → receive `access` + `refresh` JWT

**Register Fields (multipart):** `nomor_kk`, `nik`, `nama_lengkap`, `jenis_kelamin` (int), `agama` (int), `tempat_lahir`, `tanggal_lahir` (YYYY-MM-DD), `alamat`, `rt` (id), `rw` (kode_rw), `email`, `no_hp`, `password`, `kk_file` (image), `ktp_file` (image)

### Profile

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/profil/` | Bearer | Get user profile |
| PUT | `/profil/` | Bearer | Update name, phone, address |

### Letter Submission

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/pengajuan-surat/` | Bearer | List active submissions |
| POST | `/pengajuan-surat/` | Bearer | Submit a new letter request |
| POST | `/upload/berkas-surat/` | Bearer | Upload supporting documents (multipart) |

**Submit Payload:**
```json
{
  "jenis_surat": "A01",
  "data": { ... }
}
```

### Submission History

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/riwayat-pengajuan/` | Bearer | History of approved/rejected submissions |
| GET | `/riwayat-pengajuan/{nomor_permohonan}/` | Bearer | Submission detail + timeline |

### Notifications

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/notifikasi/` | Bearer | List user notifications |
| POST | `/notifikasi/{id}/read/` | Bearer | Mark notification as read |

---

## User Flow

```
Register → (Admin approves account) → Login (NIK/email + password + OTP)
→ Select letter type → Fill multi-step form → Submit
→ Status notifications (RT → RW → Village Head) → Letter completed
```

---

## Notes

- Only the **Warga (Resident)** role can access this mobile application
- Screen orientation is locked to **portrait** mode (up & down)
- JWT tokens are stored in `SharedPreferences`, auto-refreshed when expired
