import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Base URL ──────────────────────────────────────────────────────────────────
// Flutter Web (Chrome) : backend di localhost karena browser & server sama-sama di PC
// Android emulator     : 10.0.2.2 = alamat host machine dari dalam emulator
// Perangkat fisik      : ganti dengan IP LAN PC, contoh: 192.168.1.5
// Production           : ganti dengan domain HTTPS
final String kBaseUrl =
    kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

// ════════════════════════════════════════════════════════════════════════════
// Token storage helpers
// ════════════════════════════════════════════════════════════════════════════
const _keyAccess  = 'access_token';
const _keyRefresh = 'refresh_token';

Future<String?> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyAccess);
}

Future<String?> getRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyRefresh);
}

Future<void> saveTokens({
  required String access,
  required String refresh,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyAccess, access);
  await prefs.setString(_keyRefresh, refresh);
}

Future<void> clearTokens() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyAccess);
  await prefs.remove(_keyRefresh);
  await prefs.remove('user_nik');
  await prefs.remove('user_email');
  await prefs.remove('user_peran');
}

Future<void> saveUserInfo({
  required String nik,
  required String email,
  required int peran,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_nik',   nik);
  await prefs.setString('user_email', email);
  await prefs.setInt('user_peran',    peran);
}

Future<Map<String, dynamic>> getUserInfo() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'nik'  : prefs.getString('user_nik')   ?? '',
    'email': prefs.getString('user_email') ?? '',
    'peran': prefs.getInt('user_peran')    ?? 1,
  };
}

// ════════════════════════════════════════════════════════════════════════════
// ApiException — membawa status code dan pesan error dari DRF
// ════════════════════════════════════════════════════════════════════════════
class ApiException implements Exception {
  final int statusCode;
  final dynamic _body;

  const ApiException(this.statusCode, this._body);

  /// Kembalikan pesan error yang dapat ditampilkan ke user.
  /// DRF mengembalikan: {"detail": "..."} atau {"field": ["error", ...], ...}
  String get message {
    if (_body is Map) {
      final m = _body as Map<String, dynamic>;
      // {"detail": "..."} — DRF standar
      if (m.containsKey('detail')) return m['detail'].toString();
      // {"non_field_errors": ["..."]} — ValidationError tanpa field
      if (m.containsKey('non_field_errors')) {
        final v = m['non_field_errors'];
        if (v is List && v.isNotEmpty) return v.first.toString();
      }
      // {"field": ["error", ...]} — field-level errors
      final msgs = m.entries
          .where((e) => e.key != 'non_field_errors')
          .map((e) {
            final val = e.value;
            if (val is List && val.isNotEmpty) return val.first.toString();
            return val.toString();
          })
          .join('\n');
      return msgs.isNotEmpty ? msgs : 'Terjadi kesalahan (HTTP $statusCode)';
    }
    return 'Terjadi kesalahan (HTTP $statusCode)';
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ════════════════════════════════════════════════════════════════════════════
// ApiService
// ════════════════════════════════════════════════════════════════════════════
class ApiService {

  // ── Header helpers ──────────────────────────────────────────────────────
  static Future<Map<String, String>> _jsonHeaders({bool auth = false}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getAccessToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ── Response helper ─────────────────────────────────────────────────────
  // Decode body dan lempar ApiException jika status code bukan 2xx
  static Map<String, dynamic> _handleResponse(http.Response res) {
    final body = res.body.isNotEmpty
        ? jsonDecode(res.body) as Map<String, dynamic>
        : <String, dynamic>{};
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(res.statusCode, body);
  }

  // ════════════════════════════════════════════════════════════════════════
  // Wilayah (dibutuhkan sebelum register)
  // ════════════════════════════════════════════════════════════════════════

  /// Daftar semua RW
  /// GET /wilayah/rw/
  /// Response: [{"kode_rw": 1, "nama": "RW 001"}, ...]
  static Future<List<Map<String, dynamic>>> getWilayahRw() async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/wilayah/rw/'),
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    }
    throw ApiException(res.statusCode, jsonDecode(res.body));
  }

  /// Daftar RT berdasarkan kode RW
  /// GET /wilayah/rt/?rw={kodeRw}
  /// Response: [{"id": 1, "kode_rt": 1, "rw": 1}, ...]
  static Future<List<Map<String, dynamic>>> getWilayahRt(int kodeRw) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/wilayah/rt/?rw=$kodeRw'),
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    }
    throw ApiException(res.statusCode, jsonDecode(res.body));
  }

  // ════════════════════════════════════════════════════════════════════════
  // Auth — Register
  // ════════════════════════════════════════════════════════════════════════

  /// Registrasi akun baru
  /// POST /auth/register/  (multipart/form-data)
  ///
  /// [tanggalLahir]   format YYYY-MM-DD
  /// [jenisKelamin]   integer: 1=Laki-laki, 2=Perempuan
  /// [agama]          integer: 1=Islam 2=Kristen 3=Katolik 4=Hindu 5=Buddha
  ///                            6=Konghucu 7=Kepercayaan
  /// [rtId]           WilayahRT.id  (dari getWilayahRt)
  /// [kodeRw]         WilayahRW.kode_rw (dari getWilayahRw)
  /// [fotoKk]         XFile dari image_picker — bekerja di web & mobile
  /// [fotoKtp]        XFile dari image_picker — bekerja di web & mobile
  ///
  /// Response sukses: {"id": ..., "nik": "..."} — HTTP 201
  static Future<Map<String, dynamic>> register({
    required String noKk,
    required String nik,
    required String namaLengkap,
    required int    jenisKelamin,
    required int    agama,
    required String tempatLahir,
    required String tanggalLahir,
    required String alamat,
    required int    rtId,
    required int    kodeRw,
    required String email,
    required String noHp,
    required String password,
    required XFile  fotoKk,
    required XFile  fotoKtp,
  }) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$kBaseUrl/auth/register/'),
    );

    req.fields.addAll({
      'nomor_kk'     : noKk,
      'nik'          : nik,
      'nama_lengkap' : namaLengkap,
      'jenis_kelamin': jenisKelamin.toString(),
      'agama'        : agama.toString(),
      'tempat_lahir' : tempatLahir,
      'tanggal_lahir': tanggalLahir,
      'alamat'       : alamat,
      'rt'           : rtId.toString(),
      'rw'           : kodeRw.toString(),
      'email'        : email,
      'no_hp'        : noHp,
      'password'     : password,
    });

    // fromBytes bekerja di web & mobile — fromPath hanya mobile (dart:io)
    final kkBytes  = await fotoKk.readAsBytes();
    final ktpBytes = await fotoKtp.readAsBytes();
    req.files.addAll([
      http.MultipartFile.fromBytes('kk_file',  kkBytes,  filename: fotoKk.name),
      http.MultipartFile.fromBytes('ktp_file', ktpBytes, filename: fotoKtp.name),
    ]);

    final streamed = await req.send();
    final res      = await http.Response.fromStream(streamed);
    return _handleResponse(res);
  }

  // ════════════════════════════════════════════════════════════════════════
  // Auth — Login (2 step)
  // ════════════════════════════════════════════════════════════════════════

  /// Step 1 — Minta OTP login dikirim ke email
  /// POST /auth/otp/request/login/
  ///
  /// [identifier]  NIK (16 digit) atau email
  /// Response: {"otp": "123456"} — sementara OTP di response body (dev mode)
  static Future<Map<String, dynamic>> requestLoginOtp({
    required String identifier,
    required String password,
  }) async {
    final isEmail = identifier.contains('@');
    final body    = <String, String>{
      isEmail ? 'email' : 'nik': identifier,
      'password': password,
    };
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/otp/request/login/'),
      headers: await _jsonHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  /// Step 2 — Login dengan OTP, terima JWT
  /// POST /auth/login/
  ///
  /// Response: {"refresh": "...", "access": "...", "peran": 1,
  ///            "nik": "...", "email": "..."}
  /// Token disimpan otomatis ke SharedPreferences.
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    required String otp,
  }) async {
    final isEmail = identifier.contains('@');
    final body    = <String, String>{
      isEmail ? 'email' : 'nik': identifier,
      'password': password,
      'otp'     : otp,
    };
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/login/'),
      headers: await _jsonHeaders(),
      body: jsonEncode(body),
    );
    final data = _handleResponse(res);
    await saveTokens(
      access : data['access']  as String,
      refresh: data['refresh'] as String,
    );
    await saveUserInfo(
      nik  : data['nik']   as String,
      email: data['email'] as String,
      peran: data['peran'] as int,
    );
    return data;
  }

  // ════════════════════════════════════════════════════════════════════════
  // Auth — Reset Password (2 step)
  // ════════════════════════════════════════════════════════════════════════

  /// Step 1 — Minta OTP reset password
  /// POST /auth/otp/request/reset-password/
  static Future<void> requestResetPasswordOtp({
    required String email,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/otp/request/reset-password/'),
      headers: await _jsonHeaders(),
      body: jsonEncode({'email': email}),
    );
    _handleResponse(res);
  }

  /// Step 2 — Verifikasi OTP dan ganti password
  /// POST /auth/otp/verify/reset-password/
  static Future<void> verifyResetPasswordOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/otp/verify/reset-password/'),
      headers: await _jsonHeaders(),
      body: jsonEncode({
        'email'       : email,
        'otp'         : otp,
        'new_password': newPassword,
      }),
    );
    _handleResponse(res);
  }

  /// Logout — hapus token lokal
  static Future<void> logout() async {
    await clearTokens();
  }

  // ════════════════════════════════════════════════════════════════════════
  // Profil
  // ════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getProfil() async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/profil/'),
      headers: await _jsonHeaders(auth: true),
    );
    return _handleResponse(res);
  }

  static Future<void> updateProfil({
    required String nama,
    required String noTelepon,
    required String alamat,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profil/'),
      headers: await _jsonHeaders(auth: true),
      body: jsonEncode({
        'nama_lengkap': nama,
        'no_hp'       : noTelepon,
        'alamat'      : alamat,
      }),
    );
    _handleResponse(res);
  }

  // ════════════════════════════════════════════════════════════════════════
  // Permohonan
  // ════════════════════════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getPermohonan() async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/pengajuan-surat/'),
      headers: await _jsonHeaders(auth: true),
    );
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> submitPermohonan({
    required String jenisSurat,
    required Map<String, dynamic> data,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/pengajuan-surat/'),
      headers: await _jsonHeaders(auth: true),
      body: jsonEncode({'jenis_surat': jenisSurat, 'data': data}),
    );
    return _handleResponse(res);
  }

  /// Upload berkas pendukung ke permohonan yang sudah dibuat.
  /// POST /upload/berkas-surat/  (multipart)
  ///
  /// [nomorPermohonan]  nomor permohonan dari response submitPermohonan
  /// [file]             XFile dari image_picker
  static Future<Map<String, dynamic>> uploadBerkasSurat({
    required String nomorPermohonan,
    required XFile file,
  }) async {
    final token = await getAccessToken();
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$kBaseUrl/upload/berkas-surat/'),
    );
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.fields['nomor_permohonan'] = nomorPermohonan;
    final bytes = await file.readAsBytes();
    req.files.add(
      http.MultipartFile.fromBytes('file_berkas', bytes, filename: file.name),
    );
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _handleResponse(res);
  }
}
