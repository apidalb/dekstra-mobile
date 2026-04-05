import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── Base URL — ganti sesuai URL backend saat integrasi ───────────────────────
// Contoh: 'https://yourdomain.com/api' atau 'http://10.0.2.2:8000/api' (emulator)
const String _baseUrl = 'http://localhost:8000/api';

// ════════════════════════════════════════════════════════════════════════════
// Token storage helpers
// ════════════════════════════════════════════════════════════════════════════
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
}

// ════════════════════════════════════════════════════════════════════════════
// ApiService
// ════════════════════════════════════════════════════════════════════════════
class ApiService {

  // ── Header helpers ──────────────────────────────────────────────────────
  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ════════════════════════════════════════════════════════════════════════
  // Auth
  // ════════════════════════════════════════════════════════════════════════

  /// Login dengan NIK atau email + password
  /// POST /auth/login/
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    // TODO: implementasi saat backend siap
    throw UnimplementedError('login() belum diimplementasi');
  }

  /// Registrasi akun baru
  /// POST /auth/register/
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String nik,
    required String noKk,
    required String email,
    required String noTelepon,
    required String password,
  }) async {
    // TODO: implementasi saat backend siap
    throw UnimplementedError('register() belum diimplementasi');
  }

  /// Kirim kode reset password ke email
  /// POST /auth/forgot-password/
  static Future<void> forgotPassword({required String email}) async {
    // TODO: implementasi saat backend siap
    throw UnimplementedError('forgotPassword() belum diimplementasi');
  }

  /// Logout — hapus token lokal
  static Future<void> logout() async {
    await clearToken();
  }

  // ════════════════════════════════════════════════════════════════════════
  // Profil
  // ════════════════════════════════════════════════════════════════════════

  /// Ambil data profil warga yang sedang login
  /// GET /profil/
  static Future<Map<String, dynamic>> getProfil() async {
    // TODO: implementasi saat backend siap
    throw UnimplementedError('getProfil() belum diimplementasi');
  }

  /// Update data profil (nama, telepon, alamat)
  /// PUT /profil/
  static Future<void> updateProfil({
    required String nama,
    required String noTelepon,
    required String alamat,
  }) async {
    // TODO: implementasi saat backend siap
    throw UnimplementedError('updateProfil() belum diimplementasi');
  }

  // ════════════════════════════════════════════════════════════════════════
  // Permohonan
  // ════════════════════════════════════════════════════════════════════════

  /// Ambil daftar permohonan milik warga yang sedang login
  /// GET /permohonan/
  static Future<List<Map<String, dynamic>>> getPermohonan() async {
    // TODO: implementasi saat backend siap
    throw UnimplementedError('getPermohonan() belum diimplementasi');
  }

  /// Ambil detail satu permohonan berdasarkan id
  /// GET /permohonan/{id}/
  static Future<Map<String, dynamic>> getPermohonanDetail(int id) async {
    // TODO: implementasi saat backend siap
    throw UnimplementedError('getPermohonanDetail() belum diimplementasi');
  }

  /// Ajukan permohonan surat baru
  /// POST /permohonan/
  static Future<Map<String, dynamic>> submitPermohonan({
    required String jenisSurat,
    required Map<String, dynamic> data,
  }) async {
    // TODO: implementasi saat backend siap
    throw UnimplementedError('submitPermohonan() belum diimplementasi');
  }

  // ════════════════════════════════════════════════════════════════════════
  // Notifikasi
  // ════════════════════════════════════════════════════════════════════════

  /// Ambil daftar notifikasi milik warga
  /// GET /notifikasi/
  static Future<List<Map<String, dynamic>>> getNotifikasi() async {
    // TODO: implementasi saat backend siap
    throw UnimplementedError('getNotifikasi() belum diimplementasi');
  }

  /// Tandai semua notifikasi sebagai sudah dibaca
  /// POST /notifikasi/baca-semua/
  static Future<void> bacaSemuaNotifikasi() async {
    // TODO: implementasi saat backend siap
    throw UnimplementedError('bacaSemuaNotifikasi() belum diimplementasi');
  }
}
