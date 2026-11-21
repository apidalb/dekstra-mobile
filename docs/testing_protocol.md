# DEKSTRA — Protokol Pengujian Flutter DevTools
## Tugas Akhir: Analisis UI Jank dan Performa Rendering

> Referensi prosedur pengujian BAB IV. Isinya mengikuti BAB III naskah TA (revisi November 2026).
> Versi: 3.0 — 2026-11-21. **Final per 2026-11-21**: Pembimbing I tidak mengubah keputusan perangkat, statistik, dan sumber M10.
>
> **Catatan perubahan v3.0 (dari v2.0, 2026-11-06):**
> - Mesin grafis dikoreksi: Impeller dengan backend **OpenGL ES** (bukan Vulkan — lihat §2).
> - Ditambahkan lingkungan server lokal (Django via `adb reverse`) menggantikan asumsi backend produksi (§2, §9).
> - Metrik diperluas dari 7 menjadi **10** (M8 p95 build, M9 p95 raster, M10 Δ memori — §4).
> - Prosedur per iterasi ditulis ulang mengikuti skrip otomatisasi yang sudah divalidasi (§7): `uji_interaksi.ps1`, `resume_isolate.ps1`, `breakpoint_penanda.ps1`, `pantau_memori.ps1`, `simpan_ekspor.ps1`.
> - Metode M5 S1 diganti dari "Resume biasa + Rebuild Stats" menjadi breakpoint VM service + `ext.flutter.inspector.trackRebuildDirtyWidgets` (§7). Hot restart tidak dipakai karena mematikan penghitungan rebuild.
> - Ditambahkan §12 Penamaan Berkas & Pengolahan Data.
> - Versi 1.0 (2026-10-28) dan 2.0 (2026-11-06) **usang**: 1.0 masih memuat kondisi jaringan J1/J2 dan S1 dengan "hapus data app"; 2.0 masih memuat Impeller (Vulkan), 7 metrik, dan metode Resume biasa untuk M5 S1.

---

## 1. Tujuan Pengujian

Mengukur dan menganalisis *UI jank* serta performa *rendering* antarmuka DEKSTRA pada tiga skenario dengan tingkat kompleksitas berbeda, menggunakan Flutter DevTools.

Penelitian ini **tidak** memakai variasi kondisi jaringan. Kondisi J1/J2 (Wi-Fi/3G) dari versi 1.0 sudah dihapus dari BAB III. Satu-satunya kondisi jaringan yang dipakai adalah server backend lokal (lihat §2 dan §9) — bukan variasi yang dianalisis, melainkan lingkungan uji yang konsisten di seluruh iterasi.

---

## 2. Perangkat & Lingkungan

| Item | Spesifikasi |
|---|---|
| Perangkat | Satu unit: Oppo A9 2020 / CPH1937 (Snapdragon 665, Adreno 610, RAM 8 GB, Android 10 / API 29) |
| Layar | 60 Hz (batas *frame* 16,67 ms) |
| Mesin grafis | **Impeller dengan backend OpenGL ES.** Log `flutter run` menampilkan dulu *"Using the Impeller rendering backend (Vulkan)."* lalu *"(OpenGLES)."* — artinya Impeller mencoba Vulkan lebih dulu lalu beralih ke OpenGL ES. Konfigurasi bawaan dipakai; Vulkan **tidak** dipaksa lewat flag apa pun. |
| Flutter SDK | 3.41.6 stable (framework `db50e20168`, engine `5cdd327779`) |
| Dart SDK | 3.11.4 |
| Flutter DevTools | 2.54.2 |
| **Jangan `flutter upgrade`** sampai seluruh pengujian selesai — hasil tidak boleh tercampur antar versi SDK. |
| Mode profile | `flutter run --profile` — M1–M4, M6–M10 |
| Mode debug | `flutter run` (tanpa `--profile`) — M5 saja |

### Lingkungan jaringan/server

Satu kondisi jaringan dipakai di seluruh pengujian: **server Django lokal** berjalan di laptop pada port 8000, diakses dari perangkat lewat USB dengan `adb reverse tcp:8000 tcp:8000` (bukan Wi-Fi/3G, dan bukan URL produksi).

- `kBaseUrl` di `lib/services/api_service.dart` diubah sementara ke `http://127.0.0.1:8000` — ini **perubahan lokal yang tidak pernah di-commit**. Repo tetap memakai URL produksi (`https://api.dekstra-capstone.site`) di setiap commit.
- Sebelum setiap sesi pengujian, jalankan `persiapan_sesi.ps1` (folder backend, lokal, tidak di-commit) dengan urutan:
  1. `adb devices` — pastikan perangkat terhubung (`device`, bukan `offline`/`unauthorized`).
  2. `adb reverse tcp:8000 tcp:8000`.
  3. Pulihkan database uji (`db_uji_s2.sqlite3`) ke `db.sqlite3`.
  4. `python manage.py seed_uji_riwayat --cek` — **harus** melaporkan `SAMA` (data riwayat sesuai).
  5. `python manage.py runserver 0.0.0.0:8000`.
- Akun uji untuk S2: `uji.riwayat@example.com`, berisi 20 permohonan (12 Selesai, 8 Ditolak). Kode OTP login **muncul di terminal server** (backend pakai `EMAIL_BACKEND` console di lingkungan uji), bukan email sungguhan.
- **Kalau USB terputus di tengah sesi:** sambungkan ulang kabel, lalu di luar rekaman — periksa `adb reverse --list` (pasang ulang kalau kosong — ini sering hilang begitu transport USB berganti), pastikan server masih berjalan, dan pastikan aplikasi kembali ke Beranda sebelum melanjutkan iterasi.

---

## 3. Skenario Pengujian

| Kode | Halaman | Berkas | Kompleksitas | Kondisi awal |
|---|---|---|---|---|
| S1 | Splash Screen | `lib/screens/auth/splash_screen.dart` | Rendah | **Tanpa token** (sudah keluar akun) |
| S2 | Riwayat Permohonan | `lib/screens/beranda/riwayat_screen.dart` | Sedang | Sudah masuk akun (akun uji), server lokal aktif |
| S3 | Formulir Pendaftaran Peristiwa Kependudukan (F-1.02) | `lib/screens/layanan/surat/kependudukan/formulir_pendaftaran_peristiwa_screen.dart` | Tinggi | Sudah masuk akun, semua kolom kosong |

### Interaksi standar (sesuai Tabel 3.3)

| Skenario | Mulai rekam | Interaksi | Berhenti |
|---|---|---|---|
| S1 | Logo muncul | Tidak ada (tunggu saja) | Tombol **Masuk** dan **Daftar** tampil |
| S2 | Halaman Riwayat dibuka lewat tombol **Riwayat** di Beranda | 3 swipe ke bawah lalu 3 swipe ke atas pada area daftar (75%↔25% tinggi area daftar, durasi 1.000 ms per swipe, jeda 2 detik antar-swipe) | Setelah guliran terakhir |
| S3 | Halaman formulir F-1.02 terbuka (Layanan → Kependudukan → F-1.02) | Isi 4 kolom tahap 1 (Nama, NIK, No. KK, No. HP) per karakter — termasuk swipe untuk menampilkan kolom No. HP saat papan ketik menutupinya (Tabel 3.3) — lalu ketuk **Lanjut** | Tahap 2 selesai dimuat. **Jangan** sampai submit |

Interaksi S2 dan S3 dijalankan **otomatis** lewat `uji_interaksi.ps1` (lihat §7) — skrip ini hanya memakai `adb input tap`/`swipe`/`text`/`keyevent`, tidak ada `uiautomator dump` atau `screencap` selama interaksi berjalan.

---

## 4. Metrik (10 Metrik, sesuai Tabel 3.4)

| No | Metrik | Sumber | Mode | Satuan |
|---|---|---|---|---|
| M1 | Rata-rata waktu penyusunan *frame* (build, UI thread) | `flutterFrames` di berkas ekspor, frame di dalam rentang penanda | profile | ms |
| M2 | Rata-rata waktu penggambaran *frame* (raster thread) | `flutterFrames` di berkas ekspor, frame di dalam rentang penanda | profile | ms |
| M3 | Waktu penyusunan *frame* terlama (build) | `flutterFrames` di berkas ekspor, frame di dalam rentang penanda | profile | ms |
| M4 | Persentase *jank frame* (build **atau** raster > 16,67 ms) | `flutterFrames` di berkas ekspor, frame di dalam rentang penanda | profile | % |
| M5 | Jumlah pembangunan ulang *widget* (rebuild count) | `rebuildCountModel` di berkas ekspor sesi debug | **debug** | kali |
| M6 | Penggunaan memori puncak (*peak heap*) | Maksimum `heapUsage` pada CSV `pantau_memori.ps1`, di dalam rentang penanda | profile | MB |
| M7 | Fungsi dengan beban CPU tertinggi (*hot path*) | CPU Profiler, self time tertinggi di luar `dart:developer` | profile | % |
| M8 | p95 waktu penyusunan *frame* (build) | `flutterFrames` di berkas ekspor, frame di dalam rentang penanda (interpolasi linear per sesi) | profile | ms |
| M9 | p95 waktu penggambaran *frame* (raster) | `flutterFrames` di berkas ekspor, frame di dalam rentang penanda (interpolasi linear per sesi) | profile | ms |
| M10 | Δ memori "All Classes" (sesudah − sebelum) | Profile Memory (tooltip kolom Total Size, byte, dibagi 1.048.576), setelah **GC + Refresh** | profile | MB |

Catatan:
- DevTools **tidak** menampilkan angka agregat (rata-rata, terlama, persentase *jank*, p95). M1–M4, M8, M9 dihitung dari berkas ekspor oleh skrip `olah_data_bab4.py` (lihat §12).
- Ambang *jank* yang dipakai adalah 16,67 ms persis (BAB III), acuan persentase jank yang dapat diterima **< 5%**. Aturan bawaan DevTools membulatkan ke bawah, sehingga hasilnya bisa sedikit berbeda dari tanda merah di layar.
- Opsi "Count widget builds" (penghitung *rebuild*) **tidak bisa diaktifkan** di mode profile, karena bergantung pada `debugOnRebuildDirtyWidget` yang hanya ada di mode debug. *Widget Inspector* tidak menghitung *rebuild*.
- Untuk M10, nilai "Dart/Flutter" (heap Dart) dicatat juga sebagai pembanding, tapi angka resmi M10 memakai "All Classes".

---

## 5. Iterasi

- 10 iterasi per skenario. Iterasi 1 adalah pemanasan dan **dibuang**; iterasi 2–10 = 9 data valid (Ceccato dkk., ICST 2020; Georges dkk., OOPSLA 2007).
- Sesi mode profile: 3 skenario × 10 iterasi = **30 sesi** (M1–M4, M6–M10).
- Sesi mode debug (M5): 3 skenario × 10 iterasi = **30 sesi**, dengan interaksi standar yang sama (S1 memakai metode breakpoint, lihat §7).

---

## 6. Urutan Pengujian

1. **Keluar dari akun** (Akun → Keluar). Menutup aplikasi saja tidak menghapus token.
2. Jalankan **seluruh iterasi S1** (profile, lalu debug) — supaya keluar/masuk akun cukup sekali per sesi pengujian.
3. **Masuk kembali** ke akun uji (OTP dari terminal server).
4. Jalankan seluruh iterasi S2, lalu S3 (profile dulu, baru debug, untuk tiap skenario).

---

## 7. Prosedur per Iterasi

### Persiapan (sekali per sesi pengujian)
1. Baterai ≥ 50%, aplikasi lain ditutup, kecerahan layar dikunci.
2. Hubungkan perangkat lewat USB (USB *debugging* aktif), lalu cek dengan `adb devices`.
3. Jalankan `persiapan_sesi.ps1` (§2) **sebelum setiap sesi pengujian** (S1, S2, maupun S3) — basis data uji dipulihkan dan server dinyalakan sebelum setiap sesi, lalu dibiarkan menyala selama seluruh skenario (S2 satu-satunya yang benar-benar memanggil API).

### Skrip yang dipakai

Semua skrip berikut disimpan **secara lokal di folder kerja repo** (`D:\...\desktra\`, sesuai kondisi laptop penguji) dan **tidak pernah di-commit** — terdaftar di `.git/info/exclude` sehingga tidak muncul di riwayat Git maupun `git status` sebagai perubahan ter-stage:

| Skrip | Fungsi |
|---|---|
| `uji_interaksi.ps1` | Interaksi otomatis S2/S3 (adb input saja), opsi `-PantauMemori`, `-Penanda`, `-Kembali`, `-TanpaKonfirmasi`, `-Iterasi` |
| `resume_isolate.ps1` | Resume isolate Dart VM yang `--start-paused` (S1 profile), dengan `-Penanda -TungguDetik 5` |
| `breakpoint_penanda.ps1` | Metode M5 S1 (lihat di bawah): breakpoint di `main.dart:18`, `-Tahap Pasang`/`-Tahap Lanjut` |
| `pantau_memori.ps1` | Pemantau heap Dart lewat VM service, dipanggil otomatis oleh `-PantauMemori` |
| `simpan_ekspor.ps1` | Memindahkan ekspor DevTools terbaru dari Downloads ke folder data (di luar repo), dengan penamaan baku (§12) |

Berkas keluaran (ekspor, penanda, CSV memori, `catatan_manual.csv`) disimpan **di luar repo**, di folder sibling repo ini (lihat §12 untuk path persis) — lewat `simpan_ekspor.ps1`: data sungguhan ke `../data_penelitian_ta/`, percobaan/gladi (`-Percobaan`) ke `../uji_devtools_output/`.

### Langkah — S1 profile (M1–M4, M6–M9, M10)
1. **Keluar akun** (Akun → Keluar), pastikan tombol Masuk/Daftar tampil dengan server menyala, lalu force-stop aplikasi.
2. `flutter run --profile --start-paused`.
3. Buka DevTools dari URL di terminal. Buka **Performance View** — **jangan tekan Clear**. Aplikasi masih tertahan (`--start-paused`) sehingga belum ada *frame*; seluruh *frame* splash terekam setelah *resume*.
4. Buka **Memory View** → **GC** + **Refresh** → catat nilai "All Classes" dan "Dart/Flutter" **sebelum** (untuk M10).
5. Buka **CPU Profiler** → tekan **Record** (isolate masih *paused*).
6. **Wajib** (sumber M6): jalankan `pantau_memori.ps1 -VmServiceUri <uri> -Keluaran P1_S1_memori_it<NN>.csv` di proses/jendela terpisah (latar belakang). Tunggu ±2 detik, lalu jalankan `resume_isolate.ps1 -VmServiceUri <uri> -Penanda -TungguDetik 5 -Perangkat P1 -Skenario S1 -Mode profile -Iterasi it<NN>`. Penanda mulai dicatat tepat sebelum `resume`; penanda selesai 5 detik sesudahnya (`getVMTimelineMicros` lewat VM service).
7. Tunggu sampai tombol Masuk/Daftar tampil, lalu **hentikan `pantau_memori.ps1`** (buat berkas penanda `<csv>.stop` — skrip ini **tidak berhenti otomatis**, menunggu berkas itu) dan **Stop** di CPU Profiler, catat *hot path* (M7).
8. **Export** Performance View (tanpa Clear).
9. **GC** + **Refresh** lagi di Memory View → catat nilai **sesudah** (untuk M10).
10. `simpan_ekspor.ps1` dengan `-Iterasi` yang sama.
11. **Isi `catatan_manual.csv`** untuk iterasi ini (heap sebelum/sesudah, hot path, % CPU — §12).
12. Tutup aplikasi (`q` di `flutter run`, lalu force-stop).

### Langkah — S1 debug (M5)

Hot restart **tidak dipakai** untuk sesi ini karena mematikan penghitungan *rebuild* (DevTools mereset Rebuild Stats dan tidak menangkap frame setelah restart). Metode yang dipakai adalah breakpoint VM service:

1. `flutter run --start-paused` (debug).
2. Buka DevTools dari URL di terminal → **Performance View** (jangan Clear).
3. `breakpoint_penanda.ps1 -Tahap Pasang`: memasang breakpoint di `package:dekstra/main.dart:18` (tepat sebelum `runApp()`), resume dari `PauseStart` sampai berhenti lagi di breakpoint itu (`PauseBreakpoint` — titik ini sudah melewati `WidgetsFlutterBinding.ensureInitialized()`), lalu memanggil `ext.flutter.inspector.trackRebuildDirtyWidgets` dengan `enabled:"true"`. **Kotak "Count widget builds" di Rebuild Stats boleh tetap tampak tidak tercentang sepanjang sesi** — penghitungan dinyalakan oleh panggilan ekstensi itu, bukan oleh kotak itu sendiri (terbukti di gladi 1 dan gladi 2: total 38 rebuild tetap tercatat di ekspor walau kotaknya tidak tercentang di layar).
4. `breakpoint_penanda.ps1 -Tahap Lanjut -TungguDetik 5 -Perangkat P1 -Iterasi it<NN>`: breakpoint dilepas, isolate di-*resume*, penanda dicatat (mulai sebelum resume, selesai 5 detik sesudahnya).
5. **Export** Performance View.
6. `simpan_ekspor.ps1` dengan `-Iterasi` yang sama (mode `debug`).
7. Tutup aplikasi.

### Langkah — S2/S3 profile (M1–M4, M6–M10)
1. Posisi awal skenario (§3) — navigasi pakai ketukan koordinat yang sudah dikalibrasi, **tanpa** `uiautomator`.
2. Buka Memory View → **GC** + **Refresh** → catat nilai **sebelum** (M10).
3. Buka Performance View → **Clear** (frame halaman sebelumnya dibuang).
4. `uji_interaksi.ps1 -Skenario <S2|S3> -PantauMemori -Penanda -TanpaKonfirmasi -Iterasi <it>`.
5. **Export**.
6. **GC** + **Refresh** lagi → catat nilai **sesudah** (M10).
7. `uji_interaksi.ps1 -Skenario <S2|S3> -Kembali` — kembali ke posisi awal.
8. Buka CPU Profiler → **Record**.
9. `uji_interaksi.ps1 -Skenario <S2|S3> -TanpaKonfirmasi` (**tanpa** `-PantauMemori`/`-Penanda` — ini rekaman CPU, jangan menimpa berkas iterasi yang sudah ada).
10. **Stop** CPU Profiler → catat *hot path* (M7).
11. `simpan_ekspor.ps1` dengan `-Iterasi` yang sama.
12. **Isi `catatan_manual.csv`** untuk iterasi ini (§12).
13. Tutup aplikasi.

### Langkah — S2/S3 debug (M5)
1. Posisi awal skenario, Beranda/daftar Kependudukan paling atas (tanpa `uiautomator`).
2. Buka Rebuild Stats → centang **Count widget builds** → **Clear**.
3. `uji_interaksi.ps1 -Skenario <S2|S3> -Penanda -TanpaKonfirmasi -Iterasi <it>` (mode debug, **tanpa** `-PantauMemori`).
4. **Export**.
5. `simpan_ekspor.ps1` dengan `-Iterasi` yang sama (mode `debug`).
6. Tutup aplikasi.

### Aturan umum semua sesi
- **Enhance Tracing (Trace widget builds) tidak diaktifkan** — menambah beban ke frame timeline.
- **Tidak ada `uiautomator dump`/`screencap` selama rekaman berlangsung.** Kalau terpaksa dipakai di luar rekaman (mis. verifikasi posisi), **aplikasi harus dimulai ulang (force-stop + relaunch)** sebelum merekam — `uiautomator` mengaktifkan accessibility bridge yang membuat semantics tree Flutter ikut aktif dan menambah beban yang bertahan sepanjang proses app berjalan.
- Penanda waktu antar skrip memakai `getVMTimelineMicros` lewat VM service, supaya jam-nya sama persis dengan `startTime` pada `flutterFrames` di berkas ekspor.

---

## 8. Validasi Khusus & Pengulangan Iterasi

- **S1 masuk ke Beranda** berarti token masih tersimpan. **Batalkan dan ulangi** setelah keluar akun, lalu catat jumlah iterasi yang diulang (dipakai di BAB IV 4.1).
- **Hanya untuk sesi S1 profile** (sesi debug S1 tidak diperiksa durasinya): `olah_data_bab4.py` v7 memotong rekaman pada *frame* terakhir sebelum jeda > 200 ms (dihitung setelah detik pertama), lalu memberi peringatan bila durasi di luar **1,15–1,40 detik** ATAU frame pertama > **#4** — pada kedua kasus, periksa layar/token lalu ulangi iterasi bila ternyata S1 masuk ke Beranda atau *frame* awal hilang.
- **S3 tidak mencapai tahap 2** (misalnya validasi gagal, keyboard menutupi tombol Lanjut, atau kolom tidak terisi karena offset koordinat) → **ulangi iterasi**. Verifikasi tahap 2 tercapai lewat satu *screencap* **setelah Export** (bukan selama rekaman frame maupun rekaman CPU).

---

## 9. Catatan S2 dan S3

- **S2 memerlukan server lokal aktif** (§2) — endpoint `GET /riwayat-pengajuan/` dari `kBaseUrl` lokal (`http://127.0.0.1:8000`, lewat `adb reverse`), bukan URL produksi.
- Akun uji: `uji.riwayat@example.com`, 20 permohonan (12 Selesai, 8 Ditolak). Login dua langkah (kredensial lalu OTP) — OTP dibaca dari terminal server (`EMAIL_BACKEND` console), bukan email sungguhan.
- Kalau yang tampil keadaan galat atau daftar kosong (server tidak aktif / `adb reverse` terlepas), data iterasi itu **tidak dipakai** — periksa §2 (reconnect) sebelum melanjutkan.
- **S3:** keempat kolom teks memakai `TextEditingController`, jadi mengetik tidak memanggil `setState()` halaman. `setState()` halaman berjalan saat berpindah tahap (ketuk Lanjut). S3 tidak memanggil API karena rekaman berhenti sebelum submit — tapi server tetap dibiarkan menyala (§2, §7).

---

## 10. Analisis

- Statistik deskriptif komparatif dari 9 iterasi valid per skenario untuk **seluruh metrik numerik (M1–M6, M8–M10, dan persentase M7)**: rata-rata, minimum, maksimum, standar deviasi, dan interval kepercayaan 95% (distribusi t, df = 8). Tidak memakai uji inferensial, kecuali diminta pembimbing.
- M8/M9 (p95 build dan raster) dihitung **per sesi** (bukan digabung antar-iterasi dulu), dengan interpolasi linear, baru kemudian diringkas (rata-rata, dsb.) lintas 9 iterasi valid seperti metrik lain.
- **RM2** (analisis rebuild per kelas pemilik, hanya sesi debug) dianalisis **per berkas** dan **per kelas pemilik widget** — `PermohonanCard` didefinisikan di `home_screen.dart` tapi dipakai juga oleh `riwayat_screen.dart` (S2), jadi rebuild `PermohonanCard` dilaporkan terpisah dari rebuild murni `home_screen.dart`/Beranda sendiri. Sesuai naskah 3.3.6: keterkaitan indikator kompleksitas skenario dengan jumlah *rebuild* dinilai dari **kesesuaian urutan S1–S3** serta penelusuran per berkas dan kelas pemilik — **bukan** koefisien korelasi statistik (n = 3 terlalu kecil untuk itu).
- **Pemotongan frame**: frame yang dianalisis adalah yang berada **di dalam rentang penanda waktu** (mulai–selesai). Kalau suatu sesi tidak punya berkas penanda (mis. sesi lama/gladi), pakai aturan cadangan: potong pada jeda > 5 detik antar-frame.
- Frame yang berasal dari **polling notifikasi** (`Timer.periodic` 30 detik di `home_screen.dart`) **tetap dihitung** selama berada di dalam rentang penanda — tidak dibuang sebagai "noise", karena itu bagian nyata dari beban runtime Beranda.
- **Gambar Widget Inspector** diambil di **satu sesi debug S3 tambahan**, dijalankan setelah seluruh 10 iterasi selesai — dipakai hanya sebagai ilustrasi di BAB IV, **bukan** bagian dari data analisis kuantitatif.

---

## 11. Troubleshooting

| Masalah | Solusi |
|---|---|
| DevTools tidak terhubung | Hentikan `flutter run`, lalu jalankan ulang |
| Opsi "Count widget builds" tidak bisa dicentang di mode profile | Wajar; gunakan sesi debug. Untuk S1 debug: kotak boleh tetap tampak tidak tercentang sepanjang sesi; penghitungan dinyalakan oleh panggilan ekstensi lewat breakpoint (§7), bukan kegagalan |
| S1 berpindah ke Beranda | Keluar akun, lalu ulangi iterasi |
| S3 tidak mencapai tahap 2 | Ulangi iterasi; cek koordinat ketukan (keyboard bisa menggeser posisi field/tombol) |
| S2 galat/kosong | Periksa server lokal + `adb reverse --list`; tunda S2 bila tidak aktif |
| USB terputus di tengah sesi | Sambungkan ulang, cek `adb reverse --list`, server, dan posisi Beranda — semua di luar rekaman (§2) |
| Hasil iterasi menyimpang ekstrem | Jangan dihapus; catat dan bahas di BAB IV |
| Galat build | `flutter clean && flutter pub get`, lalu ulangi |

---

## 12. Penamaan Berkas & Pengolahan Data

### Penamaan

Semua nama berkas diturunkan dari satu nilai `-Iterasi` yang konsisten lintas skrip (`-Perangkat`, `-Skenario`, `-Mode` sama):

- Ekspor: `P1_<S>_<profile|debug>_it<NN>.json`
- Penanda waktu: `P1_<S>_<profile|debug>_it<NN>_penanda.json`
- CSV memori: `P1_<S>_memori_it<NN>.csv`

Akhiran **`_uji<NN>`** (bukan `_it<NN>`) menandai berkas **percobaan/gladi**, bukan data pengujian sungguhan — tidak pernah tercampur folder maupun dianalisis sebagai data BAB IV.

**Lokasi** (ditentukan oleh `simpan_ekspor.ps1`, relatif terhadap root repo ini):

| Isi | Data sungguhan (`-Iterasi it<NN>`) | Percobaan/gladi (`-Iterasi uji<NN>`, dengan `-Percobaan`) |
|---|---|---|
| Ekspor, penanda, CSV memori | `../data_penelitian_ta/` | `../uji_devtools_output/` |

`catatan_manual.csv` (angka yang dibaca manual dari DevTools: heap sebelum/sesudah, hot path, % CPU) memakai header persis berikut (jangan diubah):

```
perangkat,skenario,iterasi,heap_sebelum_profile,heap_sesudah_profile,heap_sebelum_dartflutter,heap_sesudah_dartflutter,cpu_hot_path,cpu_persen,abaikan_m10,catatan
```

### Pengolahan

- Pengolahan data memakai `olah_data_bab4.py` v7 (skrip Python, **di luar repo**).
- `batas_kelas.json` (daftar kelas/baris untuk analisis RM2 per kelas pemilik) dibuat **sekali sebelum pengujian**, dari salinan kerja repo ini yang dipakai pengujian, dengan `python olah_data_bab4.py --buat-batas-kelas "<folder repo>"` — tidak perlu diulang karena **kode aplikasi tidak diubah selama masa pengujian**.
