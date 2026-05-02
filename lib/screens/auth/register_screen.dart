import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import 'login_screen.dart';

// ── Konversi nilai form ke integer backend ────────────────────────────────────
const Map<String, int> _jenisKelaminMap = {
  'Laki-laki': 1,
  'Perempuan' : 2,
};

const Map<String, int> _agamaMap = {
  'Islam'                                    : 1,
  'Kristen'                                  : 2,
  'Katolik'                                  : 3,
  'Hindu'                                    : 4,
  'Buddha'                                   : 5,
  'Konghucu'                                 : 6,
  'Kepercayaan Terhadap Tuhan Yang Maha Esa' : 7,
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
  String? _agama;
  final _tempatLahirController  = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _alamatController       = TextEditingController();

  // RW / RT — diisi dari API
  List<Map<String, dynamic>> _rwList   = [];
  List<Map<String, dynamic>> _rtList   = [];
  bool _isLoadingRw = false;
  bool _isLoadingRt = false;
  int? _selectedRw;    // kode_rw
  int? _selectedRtId;  // WilayahRT.id

  final _formKey1 = GlobalKey<FormState>();

  // ── Step 2: Buat Akun ──────────────────────────────────────────────────────
  final _teleponController         = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  final _formKey2 = GlobalKey<FormState>();

  // ── Step 3: Unggah Dokumen ─────────────────────────────────────────────────
  XFile? _fotoKK;
  XFile? _fotoKTP;
  final ImagePicker _picker = ImagePicker();

  // ── Step 4: Review ─────────────────────────────────────────────────────────
  bool _agreeTerms  = false;
  bool _isSubmitting = false;

  static const List<String> _stepLabels = [
    'Data\nPribadi',
    'Buat\nAkun',
    'Unggah\nDokumen',
    'Review',
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

  @override
  void initState() {
    super.initState();
    _loadRwList();
  }

  // ── Muat daftar RW dari API ────────────────────────────────────────────────
  Future<void> _loadRwList() async {
    setState(() => _isLoadingRw = true);
    try {
      final list = await ApiService.getWilayahRw();
      if (mounted) setState(() => _rwList = list);
    } catch (_) {
      // Gagal load RW — dropdown tetap kosong, user bisa retry dengan scroll
    } finally {
      if (mounted) setState(() => _isLoadingRw = false);
    }
  }

  // ── Muat daftar RT saat RW dipilih ────────────────────────────────────────
  Future<void> _loadRtList(int kodeRw) async {
    setState(() {
      _isLoadingRt = true;
      _rtList      = [];
      _selectedRtId = null;
    });
    try {
      final list = await ApiService.getWilayahRt(kodeRw);
      if (mounted) setState(() => _rtList = list);
    } catch (_) {
      // Gagal load RT
    } finally {
      if (mounted) setState(() => _isLoadingRt = false);
    }
  }

  // ── Kirim data registrasi ke backend ──────────────────────────────────────
  Future<void> _submitRegister() async {
    setState(() => _isSubmitting = true);
    try {
      // Konversi tanggal dari dd/mm/yyyy ke YYYY-MM-DD
      final parts  = _tanggalLahirController.text.split('/');
      final isoDate = '${parts[2]}-${parts[1]}-${parts[0]}';

      await ApiService.register(
        noKk         : _kkController.text.trim(),
        nik          : _nikController.text.trim(),
        namaLengkap  : _namaController.text.trim(),
        jenisKelamin : _jenisKelaminMap[_jenisKelamin]!,
        agama        : _agamaMap[_agama]!,
        tempatLahir  : _tempatLahirController.text.trim(),
        tanggalLahir : isoDate,
        alamat       : _alamatController.text.trim(),
        rtId         : _selectedRtId!,
        kodeRw       : _selectedRw!,
        email        : _emailController.text.trim(),
        noHp         : _teleponController.text.trim(),
        password     : _passwordController.text,
        fotoKk       : _fotoKK!,
        fotoKtp      : _fotoKTP!,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterSuccessScreen(email: _emailController.text),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Gagal terhubung ke server. Periksa koneksi internet Anda.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
      _showConfirmDialog();
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

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_outlined,
                    color: AppTheme.primary, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Konfirmasi Pendaftaran',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pastikan semua data yang Anda masukkan sudah benar.\nData yang telah dikirim tidak dapat diubah kembali.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitRegister();
                    },
                    child: const Text('Ya, Kirim Data'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Periksa Kembali'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
      case 0:  return _buildStep1();
      case 1:  return _buildStep2();
      case 2:  return _buildStep3();
      case 3:  return _buildStep4();
      default: return const SizedBox();
    }
  }

  // ── Step 1: Data Pribadi ───────────────────────────────────────────────────
  Widget _buildStep1() {

    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor KK
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
            value: _jenisKelamin,
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

          // Agama
          _label('Agama', required: true),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _agama,
            isExpanded: true,
            style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
            decoration: _dropdownDeco('Pilih Agama Anda'),
            items: const [
              'Islam',
              'Kristen',
              'Katolik',
              'Hindu',
              'Buddha',
              'Konghucu',
              'Kepercayaan Terhadap Tuhan Yang Maha Esa',
            ]
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: GoogleFonts.poppins(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _agama = v),
            validator: (v) => v == null ? 'Agama wajib dipilih' : null,
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
          const SizedBox(height: 16),

          // RW
          _label('RW', required: true),
          const SizedBox(height: 6),
          _isLoadingRw
              ? const LinearProgressIndicator()
              : DropdownButtonFormField<int>(
                  value: _selectedRw,
                  decoration: _dropdownDeco(
                    _rwList.isEmpty ? 'Memuat data RW...' : 'Pilih RW',
                  ),
                  items: _rwList
                      .map((rw) => DropdownMenuItem<int>(
                            value: rw['kode_rw'] as int,
                            child: Text('RW ${rw['kode_rw']}',
                                style: GoogleFonts.poppins(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedRw   = v;
                      _selectedRtId = null;
                    });
                    if (v != null) _loadRtList(v);
                  },
                  validator: (v) => v == null ? 'RW wajib dipilih' : null,
                ),
          const SizedBox(height: 16),

          // RT — nonaktif sampai RW dipilih
          _label('RT', required: true),
          const SizedBox(height: 6),
          _isLoadingRt
              ? const LinearProgressIndicator()
              : DropdownButtonFormField<int>(
                  value: _selectedRtId,
                  decoration: _dropdownDeco(
                    _selectedRw == null
                        ? 'Pilih RW terlebih dahulu'
                        : 'Pilih RT',
                  ),
                  items: _rtList
                      .map((rt) => DropdownMenuItem<int>(
                            value: rt['id'] as int,
                            child: Text('RT ${rt['kode_rt']}',
                                style: GoogleFonts.poppins(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: _selectedRw == null
                      ? null
                      : (v) => setState(() => _selectedRtId = v),
                  validator: (v) => v == null ? 'RT wajib dipilih' : null,
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
              if (!v.startsWith('0')) {
                return 'Nomor telepon harus diawali 0 (bukan +62 atau 62)';
              }
              final digits = v.trim().replaceAll(RegExp(r'\D'), '');
              if (digits.length < 10 || digits.length > 15) {
                return 'Nomor telepon tidak valid (10–15 digit)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

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
              return null;
            },
          ),
          const SizedBox(height: 16),

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
              if (!RegExp(r'[a-z]').hasMatch(v)) return 'Harus ada huruf kecil';
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
          desc: 'Unggah dokumen dengan format JPG, JPEG, PNG maks 2 MB',
          file: _fotoKK,
          onTap: () => _pickImage(true),
          onRemove: () => setState(() => _fotoKK = null),
        ),
        const SizedBox(height: 20),
        _uploadCard(
          label: 'Foto Kartu Tanda Penduduk (KTP)',
          hint: 'Unggah Dokumen Kartu Tanda Penduduk (KTP)',
          desc: 'Unggah dokumen dengan format JPG, JPEG, PNG maks 2 MB',
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
                        child: const Icon(Icons.upload_outlined,
                            color: AppTheme.primary, size: 24),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        hint,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: _buildXFileImage(
                          file,
                          width: double.infinity,
                          height: 200,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
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
        _reviewSection('Informasi Dasar', [
          _ReviewRow('Nomor KK',      _kkController.text),
          _ReviewRow('NIK',           _nikController.text),
          _ReviewRow('Nama Lengkap',  _namaController.text),
          _ReviewRow('Tempat Lahir',  _tempatLahirController.text),
          _ReviewRow('Tanggal Lahir', _tanggalLahirController.text),
          _ReviewRow('Jenis Kelamin', _jenisKelamin ?? '-'),
          _ReviewRow('Agama',         _agama ?? '-'),
          _ReviewRow('Alamat Lengkap',_alamatController.text),
          _ReviewRow('RW', _selectedRw != null ? 'RW $_selectedRw' : '-'),
          _ReviewRow('RT', () {
            if (_selectedRtId == null) return '-';
            final rt = _rtList.where((r) => r['id'] == _selectedRtId).firstOrNull;
            return rt != null ? 'RT ${rt['kode_rt']}' : '-';
          }()),
        ]),
        const SizedBox(height: 16),

        _reviewSection('Informasi Akun', [
          _ReviewRow('Nomor Telepon', _teleponController.text),
          _ReviewRow('Email',         _emailController.text),
        ]),
        const SizedBox(height: 16),

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
          _reviewDocItem('Kartu Keluarga (KK)', _fotoKK),
          const SizedBox(height: 12),
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
            child: _buildXFileImage(
              file,
              width: double.infinity,
              height: 140,
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

  // ── Bottom Buttons ─────────────────────────────────────────────────────────
  Widget _buildBottomButtons() {
    final nextLabel = _currentStep == 3 ? 'DAFTAR' : 'LANJUT';
    final isFirst   = _currentStep == 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                onPressed: _isSubmitting ? null : _back,
                child: const Text('KEMBALI'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _next,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(nextLabel),
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

  // Menampilkan gambar dari XFile secara cross-platform (Android/iOS/Web)
  // Web tidak mendukung Image.file — gunakan Image.network (XFile.path = object URL di web)
  Widget _buildXFileImage(XFile file,
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (kIsWeb) {
      return Image.network(file.path, width: width, height: height, fit: fit);
    }
    return Image.file(File(file.path), width: width, height: height, fit: fit);
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
}

class _ReviewRow {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);
}

// ── RegisterSuccessScreen ─────────────────────────────────────────────────────
class RegisterSuccessScreen extends StatelessWidget {
  final String email;
  const RegisterSuccessScreen({super.key, required this.email});

  String _maskEmail(String v) {
    final at = v.indexOf('@');
    if (at <= 1) return v;
    return '${v[0]}${'*' * (at - 1)}${v.substring(at)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          child: Column(
            children: [
              // ── Icon ──────────────────────────────────────────────────
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mark_email_read_outlined,
                        color: AppTheme.primary, size: 46),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.access_time,
                        color: Color(0xFFD97706), size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'Pendaftaran Berhasil!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Akun Anda sedang dalam proses verifikasi oleh Admin. Proses ini biasanya memakan waktu 1x24 jam pada hari kerja.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),

              // ── Email notifikasi ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.email_outlined,
                          color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifikasi akan dikirimkan ke',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            _maskEmail(email),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Apa yang terjadi selanjutnya ──────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APA YANG TERJADI SELANJUTNYA?',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _nextStep(1,
                        'Admin akan memverifikasi data dan dokumen yang Anda kirimkan.'),
                    const SizedBox(height: 10),
                    _nextStep(2,
                        'Anda akan mendapatkan notifikasi melalui email yang Anda daftarkan.'),
                    const SizedBox(height: 10),
                    _nextStep(3,
                        'Setelah diverifikasi, Anda dapat masuk menggunakan akun yang telah terdaftar.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Jika Anda tidak menerima email dalam 24 jam, silakan hubungi kantor desa setempat untuk informasi lebih lanjut.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),

              // ── Tombol kembali ke login ────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  ),
                  child: const Text('Kembali ke Halaman Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nextStep(int no, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$no',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
