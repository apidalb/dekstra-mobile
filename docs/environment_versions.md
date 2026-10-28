# DEKSTRA — Versi Environment & Dependency

Dokumen ini merangkum versi SDK dan dependency utama yang digunakan pada project DEKSTRA, untuk keperluan lampiran data Tugas Akhir. Data diambil langsung dari `pubspec.yaml` dan `android/app/build.gradle.kts` per commit terakhir di branch `develop`.

## 1. SDK & Environment

| Item | Nilai | Sumber |
|---|---|---|
| Dart SDK constraint | `>=3.0.0 <4.0.0` | `pubspec.yaml` |
| Flutter SDK version | Tidak dipin eksplisit di project — mengikuti Flutter SDK yang terinstal di environment developer/build | — |
| State management (GetX) | **Tidak digunakan** — package `get` tidak terdaftar di `dependencies` | `pubspec.yaml` |
| Java/Kotlin compatibility | Java 17 (`JavaVersion.VERSION_17`) | `android/app/build.gradle.kts` |

## 2. Android SDK

| Item | Nilai | Sumber |
|---|---|---|
| `minSdk` | Mengikuti default Flutter SDK (`flutter.minSdkVersion`), tidak di-override | `android/app/build.gradle.kts` |
| `targetSdk` | Mengikuti default Flutter SDK (`flutter.targetSdkVersion`), tidak di-override | `android/app/build.gradle.kts` |
| `compileSdk` | Mengikuti default Flutter SDK (`flutter.compileSdkVersion`) | `android/app/build.gradle.kts` |
| `min_sdk_android` (khusus icon generator, bukan minSdk aplikasi) | 21 | `pubspec.yaml` (config `flutter_launcher_icons`) |

> **Catatan:** Karena `minSdk`/`targetSdk`/`compileSdk` tidak di-hardcode di project, angka pastinya bergantung pada versi Flutter SDK yang terinstal saat build. Untuk mendapatkan angka definitif (mis. untuk ditulis di laporan TA sebagai "minSdk 21" / "targetSdk 34"), jalankan `flutter doctor -v` atau `flutter --version` di environment build yang digunakan.

## 3. State Management

| Item | Nilai | Sumber |
|---|---|---|
| Library eksternal (Provider/Bloc/Riverpod/GetX) | **Tidak digunakan** — tidak ada di `pubspec.yaml` maupun di import file `.dart` manapun | `pubspec.yaml`, grep seluruh `lib/**/*.dart` |
| Pola yang dipakai | `StatefulWidget` + `setState()` bawaan Flutter (state lokal per-screen) | 30 file screen di `lib/screens/`, 206 occurrence `setState`/`StatefulWidget`/`ChangeNotifier` |
| `main.dart` | Hanya import `flutter/material.dart`, `flutter/services.dart`, `theme/app_theme.dart`, `splash_screen.dart` — tidak ada wrapper `ChangeNotifierProvider`, `MultiProvider`, `BlocProvider`, atau `ProviderScope` | `lib/main.dart` |

## 4. Dependencies

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
  http: ^1.2.0
  shared_preferences: ^2.2.2
  image_picker: ^1.0.7
  url_launcher: ^6.2.0

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^3.0.0
  flutter_launcher_icons: ^0.14.3
```
