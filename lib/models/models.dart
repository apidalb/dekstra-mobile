// ════════════════════════════════════════════════════════════════════════════
// lib/models/models.dart
// Semua model data aplikasi DEKSTRA
// ════════════════════════════════════════════════════════════════════════════

// ── Permohonan ────────────────────────────────────────────────────────────────
class Permohonan {
  final int id;
  final String jenisSurat;
  final DateTime tanggal;
  final String status;

  const Permohonan({
    required this.id,
    required this.jenisSurat,
    required this.tanggal,
    required this.status,
  });

  String get tanggalFormatted =>
      '${tanggal.year}-'
      '${tanggal.month.toString().padLeft(2, '0')}-'
      '${tanggal.day.toString().padLeft(2, '0')}';

  factory Permohonan.fromJson(Map<String, dynamic> json) {
    return Permohonan(
      id:         json['id'] as int,
      jenisSurat: json['jenis_surat'] as String,
      tanggal:    DateTime.parse(json['tanggal'] as String),
      status:     json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':          id,
    'jenis_surat': jenisSurat,
    'tanggal':     tanggal.toIso8601String(),
    'status':      status,
  };
}

// ── TimelineStep (untuk PermohonanDetail) ─────────────────────────────────────
class TimelineStep {
  final String title;
  final String? timestamp;
  final String description;
  final String? oleh;

  const TimelineStep({
    required this.title,
    this.timestamp,
    required this.description,
    this.oleh,
  });

  factory TimelineStep.fromJson(Map<String, dynamic> json) {
    return TimelineStep(
      title:       json['title'] as String,
      timestamp:   json['timestamp'] as String?,
      description: json['description'] as String,
      oleh:        json['oleh'] as String?,
    );
  }
}

// ── UserProfil ────────────────────────────────────────────────────────────────
class UserProfil {
  final String noKk;
  final String nik;
  final String namaLengkap;
  final String jenisKelamin;
  final String tempatLahir;
  final String tanggalLahir;
  final String alamat;
  final String email;
  final String noTelepon;

  const UserProfil({
    required this.noKk,
    required this.nik,
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.alamat,
    required this.email,
    required this.noTelepon,
  });

  factory UserProfil.fromJson(Map<String, dynamic> json) {
    return UserProfil(
      noKk:         json['no_kk']          as String,
      nik:          json['nik']             as String,
      namaLengkap:  json['nama_lengkap']    as String,
      jenisKelamin: json['jenis_kelamin']   as String,
      tempatLahir:  json['tempat_lahir']    as String,
      tanggalLahir: json['tanggal_lahir']   as String,
      alamat:       json['alamat']          as String,
      email:        json['email']           as String,
      noTelepon:    json['no_telepon']      as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'no_kk':         noKk,
    'nik':           nik,
    'nama_lengkap':  namaLengkap,
    'jenis_kelamin': jenisKelamin,
    'tempat_lahir':  tempatLahir,
    'tanggal_lahir': tanggalLahir,
    'alamat':        alamat,
    'email':         email,
    'no_telepon':    noTelepon,
  };
}

// ── Notifikasi ────────────────────────────────────────────────────────────────
class Notifikasi {
  final int id;
  final String judul;
  final String pesan;
  final DateTime waktu;
  final bool dibaca;

  const Notifikasi({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.waktu,
    required this.dibaca,
  });

  String get waktuFormatted {
    final now    = DateTime.now();
    final diff   = now.difference(waktu);
    if (diff.inMinutes < 60)  return '${diff.inMinutes} menit lalu';
    if (diff.inHours   < 24)  return '${diff.inHours} jam lalu';
    if (diff.inDays    < 7)   return '${diff.inDays} hari lalu';
    return '${waktu.day.toString().padLeft(2,'0')}/'
           '${waktu.month.toString().padLeft(2,'0')}/'
           '${waktu.year}';
  }

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      id:     json['id']     as int,
      judul:  json['judul']  as String,
      pesan:  json['pesan']  as String,
      waktu:  DateTime.parse(json['waktu'] as String),
      dibaca: json['dibaca'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':     id,
    'judul':  judul,
    'pesan':  pesan,
    'waktu':  waktu.toIso8601String(),
    'dibaca': dibaca,
  };
}
