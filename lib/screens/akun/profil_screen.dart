import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

// Data profil dummy — diisi dari data pendaftaran
// Pada implementasi nyata, data ini akan datang dari API / local storage
class _ProfilData {
  final String noKK;
  final String nik;
  final String namaLengkap;
  final String jenisKelamin;
  final String tempatLahir;
  final String tanggalLahir;
  final String alamat;
  final String email;
  final String noTelepon;

  const _ProfilData({
    required this.noKK,
    required this.nik,
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.alamat,
    required this.email,
    required this.noTelepon,
  });
}

// ── ProfilScreen ──────────────────────────────────────────────────────────────
class ProfilScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const ProfilScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    // Data dummy profil
    final profil = _ProfilData(
      noKK:         '1111111111111111',
      nik:          '1111111111111111',
      namaLengkap:  userName,
      jenisKelamin: 'Laki-laki',
      tempatLahir:  'Semarang',
      tanggalLahir: '2000-02-29',
      alamat:       'Jalan Semarang No. 123',
      email:        userEmail,
      noTelepon:    '081111111111',
    );

    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    // Ambil dua initial jika nama minimal dua kata
    final parts = userName.trim().split(' ');
    final avatar = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : initial;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [

          // ── Kartu identitas pengguna ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDeco(),
            child: Row(
              children: [
                // Avatar lingkaran dengan inisial
                Container(
                  width: 56, height: 56,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      avatar,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Nama + email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profil.namaLengkap,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        profil.email,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Tombol Edit Profil
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showEditDialog(context, profil),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit Profil'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Informasi Pribadi ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDeco(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Pribadi',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(color: AppTheme.border, height: 1),
                const SizedBox(height: 14),

                _infoField('Nomor Kartu Keluarga (KK)', profil.noKK),
                _infoField('Nomor Induk Kependudukan (NIK)', profil.nik),
                _infoField('Nama Lengkap', profil.namaLengkap),
                _infoField('Jenis Kelamin', profil.jenisKelamin),
                _infoField('Tempat Lahir', profil.tempatLahir),
                _infoField('Tanggal Lahir', profil.tanggalLahir),
                _infoField('Alamat Lengkap', profil.alamat, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Informasi Akun ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDeco(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Akun',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(color: AppTheme.border, height: 1),
                const SizedBox(height: 14),

                _infoField('Email', profil.email),
                _infoField('Nomor Telepon', profil.noTelepon, isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit Profil dialog ─────────────────────────────────────────────────────
  void _showEditDialog(BuildContext context, _ProfilData profil) {
    final namaCtrl    = TextEditingController(text: profil.namaLengkap);
    final telpCtrl    = TextEditingController(text: profil.noTelepon);
    final alamatCtrl  = TextEditingController(text: profil.alamat);
    final formKey     = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppTheme.surface,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        'Edit Profil',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close,
                            size: 20, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hanya nama, nomor telepon, dan alamat yang dapat diubah.',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 16),

                  // Nama Lengkap
                  _dialogLabel('Nama Lengkap'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: namaCtrl,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: const InputDecoration(
                        hintText: 'Masukkan nama lengkap',
                        isDense: true),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 14),

                  // Nomor Telepon
                  _dialogLabel('Nomor Telepon'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: telpCtrl,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: const InputDecoration(
                        hintText: 'Contoh: 081234567890',
                        isDense: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Nomor telepon tidak boleh kosong';
                      }
                      final digits =
                          v.trim().replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 9 || digits.length > 13) {
                        return 'Nomor telepon tidak valid (9–13 digit)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Alamat
                  _dialogLabel('Alamat Lengkap'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: alamatCtrl,
                    maxLines: 3,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: const InputDecoration(
                        hintText: 'Masukkan alamat lengkap',
                        isDense: true),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Alamat tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 20),

                  // Tombol
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              // TODO: simpan perubahan ke state / API
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('Profil berhasil diperbarui',
                                    style: GoogleFonts.poppins()),
                                backgroundColor: AppTheme.primary,
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          },
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogLabel(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      );

  // ── Card & field helpers ───────────────────────────────────────────────────
  BoxDecoration _cardDeco() => BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      );

  /// Satu baris label di atas, nilai di bawah, dipisahkan divider tipis
  Widget _infoField(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 148,
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value.isNotEmpty ? value : '-',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppTheme.border),
      ],
    );
  }
}
