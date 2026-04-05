import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';
import '../beranda/home_screen.dart';

// ── Dummy data akun terdaftar ─────────────────────────────────────────────────
const Set<String> _registeredNiks = {
  '1234567890123456',
};
const Set<String> _registeredEmails = {
  'existing@desktra.com',
};

// ── RegisterScreen ────────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;

  // ── Step 1: Data Pribadi ───────────────────────────────────────────────────
  final _kkController           = TextEditingController();
  final _nikController          = TextEditingController();
  final _namaController         = TextEditingController();
  String? _jenisKelamin;
  final _tempatLahirController  = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _alamatController       = TextEditingController();
  final _formKey1               = GlobalKey<FormState>();

  // ── Step 2: Buat Akun ──────────────────────────────────────────────────────
  final _teleponController          = TextEditingController();
  final _emailController            = TextEditingController();
  final _passwordController         = TextEditingController();
  final _confirmPasswordController  = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  final _formKey2       = GlobalKey<FormState>();

  // ── Step 3: Unggah Dokumen ─────────────────────────────────────────────────
  XFile? _fotoKK;
  XFile? _fotoKTP;
  final ImagePicker _picker = ImagePicker();

  // ── Step 4: Review ─────────────────────────────────────────────────────────
  bool _agreeTerms = false;

  // ── Step 5: OTP ────────────────────────────────────────────────────────────
  // Hanya opsi email sesuai versi web

  static const List<String> _stepLabels = [
    'Data\nPribadi',
    'Buat\nAkun',
    'Unggah\nDokumen',
    'Review',
    'OTP',
  ];

  @override
  void dispose() {
    _kkController.dispose();
    _nikController.dispose();
    _namaController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirController.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  Future<void> _pickImage(bool isKK) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked != null) {
      setState(() {
        if (isKK) {
          _fotoKK = picked;
        } else {
          _fotoKTP = picked;
        }
      });
    }
  }

  void _next() {
    if (_currentStep == 0) {
      if (!_formKey1.currentState!.validate()) return;
    } else if (_currentStep == 1) {
      if (!_formKey2.currentState!.validate()) return;
    } else if (_currentStep == 2) {
      // Validasi: kedua dokumen harus diunggah
      if (_fotoKK == null || _fotoKTP == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            _fotoKK == null && _fotoKTP == null
                ? 'Harap unggah foto KK dan KTP'
                : _fotoKK == null
                    ? 'Harap unggah foto Kartu Keluarga (KK)'
                    : 'Harap unggah foto Kartu Tanda Penduduk (KTP)',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }
    } else if (_currentStep == 3) {
      if (!_agreeTerms) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Harap centang pernyataan persetujuan',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }
    } else if (_currentStep == 4) {
      // Step OTP — langsung masuk
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userName: _namaController.text,
            userEmail: _emailController.text,
          ),
        ),
        (route) => false,
      );
      return;
    }

    setState(() => _currentStep++);
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Daftar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: _back,
        ),
      ),
      body: Column(
        children: [
          // ── Stepper Header ─────────────────────────────────────────
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              children: [
                Text(
                  'Pendaftaran Akun',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildStepper(),
              ],
            ),
          ),

          // ── Scrollable Content ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: _buildStepContent(),
            ),
          ),

          // ── Bottom Buttons ─────────────────────────────────────────
          _buildBottomButtons(),
        ],
      ),
    );
  }

  // ── Stepper ────────────────────────────────────────────────────────────────
  Widget _buildStepper() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_stepLabels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final isDone = _currentStep > i ~/ 2;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 17),
              child: Container(
                height: 2,
                color: isDone ? AppTheme.primary : AppTheme.border,
              ),
            ),
          );
        }
        final idx      = i ~/ 2;
        final isActive = _currentStep == idx;
        final isDone   = _currentStep > idx;
        return SizedBox(
          width: 52,
          child: Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: (isActive || isDone)
                      ? AppTheme.primary
                      : const Color(0xFFD1D5DB),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${idx + 1}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _stepLabels[idx],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  color: (isActive || isDone)
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Step Dispatcher ────────────────────────────────────────────────────────
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      case 3: return _buildStep4();
      case 4: return _buildStep5();
      default: return const SizedBox();
    }
  }

  // ── Step 1: Data Pribadi ───────────────────────────────────────────────────
  // Menggabungkan "Identitas Dasar" + "Data Pribadi" dari versi sebelumnya
  // agar sesuai dengan alur web (semua data diri dalam satu langkah).
  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KK
          _label('Nomor Kartu Keluarga (KK)', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _kkController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: const InputDecoration(
                hintText: 'Isi dengan 16 digit Nomor KK Anda'),
            validator: (v) {
              if (v!.isEmpty) return 'Nomor KK wajib diisi';
              if (v.length != 16) return 'Nomor KK harus 16 digit';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // NIK
          _label('Nomor Induk Kependudukan (NIK)', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nikController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: const InputDecoration(
                hintText: 'Isi dengan 16 digit NIK Anda'),
            validator: (v) {
              if (v!.isEmpty) return 'NIK wajib diisi';
              if (v.length != 16) return 'NIK harus 16 digit';
              if (_registeredNiks.contains(v)) {
                return 'NIK sudah terdaftar, silakan langsung masuk';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Nama Lengkap
          _label('Nama Lengkap', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _namaController,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: const InputDecoration(
                hintText: 'Masukkan Nama Lengkap sesuai KTP Anda'),
            validator: (v) =>
                v!.isEmpty ? 'Nama lengkap wajib diisi' : null,
          ),
          const SizedBox(height: 16),

          // Jenis Kelamin
          _label('Jenis Kelamin', required: true),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _jenisKelamin,
            decoration: _dropdownDeco('Pilih Jenis Kelamin Anda'),
            items: ['Laki-laki', 'Perempuan']
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: GoogleFonts.poppins(fontSize: 14)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _jenisKelamin = v),
            validator: (v) =>
                v == null ? 'Jenis kelamin wajib dipilih' : null,
          ),
          const SizedBox(height: 16),

          // Tempat Lahir
          _label('Tempat Lahir', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _tempatLahirController,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: const InputDecoration(
                hintText: 'Masukkan Tempat Lahir sesuai KTP Anda'),
            validator: (v) =>
                v!.isEmpty ? 'Tempat lahir wajib diisi' : null,
          ),
          const SizedBox(height: 16),

          // Tanggal Lahir
          _label('Tanggal Lahir', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _tanggalLahirController,
            readOnly: true,
            onTap: _selectDate,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'dd/mm/yyyy',
              hintStyle: GoogleFonts.poppins(
                  color: AppTheme.textSecondary, fontSize: 14),
              suffixIcon: const Icon(Icons.calendar_today,
                  color: AppTheme.textSecondary, size: 18),
            ),
            validator: (v) =>
                v!.isEmpty ? 'Tanggal lahir wajib diisi' : null,
          ),
          const SizedBox(height: 16),

          // Alamat Lengkap
          _label('Alamat Lengkap', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _alamatController,
            maxLines: 4,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: const InputDecoration(
                hintText: 'Masukkan Alamat Lengkap sesuai KTP Anda'),
            validator: (v) =>
                v!.isEmpty ? 'Alamat lengkap wajib diisi' : null,
          ),
          const SizedBox(height: 24),

          // Link sudah punya akun
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sudah punya akun? ',
                style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary, fontSize: 14),
              ),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: Text(
                  'Masuk',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 2: Buat Akun ──────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor Telepon
          _label('Nomor Telepon', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _teleponController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration:
                const InputDecoration(hintText: 'Contoh: 081234567890'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Nomor telepon wajib diisi';
              final digits = v.trim().replaceAll(RegExp(r'\D'), '');
              if (digits.length < 9 || digits.length > 13) {
                return 'Nomor telepon tidak valid (9–13 digit)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          _label('Email', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration:
                const InputDecoration(hintText: 'Contoh: nama@email.com'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email wajib diisi';
              if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(v.trim())) {
                return 'Format email tidak valid';
              }
              if (_registeredEmails.contains(v.trim().toLowerCase())) {
                return 'Email sudah terdaftar, silakan langsung masuk';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Kata Sandi
          _label('Kata Sandi', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buat Kata Sandi Anda',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v!.isEmpty) return 'Kata sandi wajib diisi';
              if (v.length < 8) return 'Minimal 8 karakter';
              if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Harus ada huruf besar';
              if (!RegExp(r'[0-9]').hasMatch(v)) return 'Harus ada angka';
              return null;
            },
          ),
          const SizedBox(height: 6),
          Text(
            '* Minimal 8 karakter\n* Terdiri dari Huruf besar, kecil, dan angka',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),

          // Konfirmasi Kata Sandi
          _label('Konfirmasi Kata Sandi', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Masukkan ulang kata sandi',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v!.isEmpty) return 'Konfirmasi wajib diisi';
              if (v != _passwordController.text) {
                return 'Kata sandi tidak cocok';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── Step 3: Unggah Dokumen ─────────────────────────────────────────────────
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _uploadCard(
          label: 'Foto Kartu Keluarga (KK)',
          hint: 'Unggah Dokumen Kartu Keluarga (KK)',
          desc: 'Format JPG, JPEG, PNG · Maks. 2 MB',
          file: _fotoKK,
          onTap: () => _pickImage(true),
          onRemove: () => setState(() => _fotoKK = null),
        ),
        const SizedBox(height: 20),
        _uploadCard(
          label: 'Foto Kartu Tanda Penduduk (KTP)',
          hint: 'Unggah Dokumen Kartu Tanda Penduduk (KTP)',
          desc: 'Format JPG, JPEG, PNG · Maks. 2 MB',
          file: _fotoKTP,
          onTap: () => _pickImage(false),
          onRemove: () => setState(() => _fotoKTP = null),
        ),
      ],
    );
  }

  Widget _uploadCard({
    required String label,
    required String hint,
    required String desc,
    required XFile? file,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: file == null ? onTap : null,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 160),
            decoration: BoxDecoration(
              color: file != null ? Colors.transparent : AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: file != null ? AppTheme.primary : AppTheme.border,
                width: file != null ? 1.5 : 1,
              ),
            ),
            child: file == null
                // ── Area kosong ─────────────────────────────────────
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 28),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.upload_outlined,
                          color: AppTheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        hint,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  )
                // ── Preview gambar terpilih ──────────────────────────
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(
                          File(file.path),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Overlay nama file + tombol hapus
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(11),
                              bottomRight: Radius.circular(11),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.image_outlined,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  file.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: onRemove,
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        // Tombol ganti foto (jika sudah ada)
        if (file != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                'Ganti Foto',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Step 4: Review ─────────────────────────────────────────────────────────
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informasi Dasar
        _reviewSection('Informasi Dasar', [
          _ReviewRow('Nomor KK', _kkController.text),
          _ReviewRow('NIK', _nikController.text),
          _ReviewRow('Nama Lengkap', _namaController.text),
          _ReviewRow('Jenis Kelamin', _jenisKelamin ?? '-'),
          _ReviewRow('Tempat Lahir', _tempatLahirController.text),
          _ReviewRow('Tanggal Lahir', _tanggalLahirController.text),
          _ReviewRow('Alamat Lengkap', _alamatController.text),
        ]),
        const SizedBox(height: 16),

        // Informasi Akun
        _reviewSection('Informasi Akun', [
          _ReviewRow('Nomor Telepon', _teleponController.text),
          _ReviewRow('Email', _emailController.text),
        ]),
        const SizedBox(height: 16),

        // Dokumen Pendukung
        _reviewDocumentSection(),
        const SizedBox(height: 16),

        // Checkbox persetujuan
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _agreeTerms,
                onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                activeColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              Expanded(
                child: Text(
                  'Saya menyatakan bahwa seluruh data yang saya isikan adalah benar dan dapat dipertanggungjawabkan.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewSection(String title, List<_ReviewRow> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        r.label,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        r.value.isNotEmpty ? r.value : '-',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _reviewDocumentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dokumen Pendukung',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // KK preview
          _reviewDocItem('Kartu Keluarga (KK)', _fotoKK),
          const SizedBox(height: 12),

          // KTP preview
          _reviewDocItem('Kartu Tanda Penduduk (KTP)', _fotoKTP),
        ],
      ),
    );
  }

  Widget _reviewDocItem(String label, XFile? file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        if (file != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(file.path),
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
              child: Text(
                'Belum ada dokumen',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppTheme.textSecondary),
              ),
            ),
          ),
      ],
    );
  }

  // ── Step 5: OTP ────────────────────────────────────────────────────────────
  // Sesuai web: hanya opsi email (tanpa opsi nomor telepon)
  Widget _buildStep5() {
    final maskedEmail = _maskEmail(_emailController.text);
    return Column(
      children: [
        const SizedBox(height: 8),
        _otpOption(
          Icons.email_outlined,
          'Kirim Melalui Email',
          'Kirim kode OTP melalui email $maskedEmail',
        ),
      ],
    );
  }

  Widget _otpOption(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 14, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  // ── Bottom Buttons ─────────────────────────────────────────────────────────
  Widget _buildBottomButtons() {
    final nextLabel = _currentStep == 3
        ? 'KIRIM OTP'
        : _currentStep == 4
            ? 'SELESAI'
            : 'LANJUT';
    final isFirst = _currentStep == 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirst) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _back,
                child: const Text('KEMBALI'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _next,
              child: Text(nextLabel),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _label(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
        children: [
          TextSpan(text: text),
          if (required)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  InputDecoration _dropdownDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            color: AppTheme.textSecondary, fontSize: 14),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  String _maskEmail(String v) {
    final at = v.indexOf('@');
    if (at <= 1) return v;
    return '${v[0]}${'*' * (at - 1)}${v.substring(at)}';
  }
}

class _ReviewRow {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);
}
