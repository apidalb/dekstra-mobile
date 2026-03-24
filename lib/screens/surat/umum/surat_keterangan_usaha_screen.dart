import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class SuratKeteranganUsahaScreen extends StatefulWidget {
  const SuratKeteranganUsahaScreen({super.key});

  @override
  State<SuratKeteranganUsahaScreen> createState() =>
      _SuratKeteranganUsahaScreenState();
}

class _SuratKeteranganUsahaScreenState
    extends State<SuratKeteranganUsahaScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Data Pemohon ───────────────────────────────────────────────────────────
  final _nikCtrl           = TextEditingController();
  final _namaCtrl          = TextEditingController();
  final _tempatLahirCtrl   = TextEditingController();
  final _tanggalLahirCtrl  = TextEditingController();
  String? _jenisKelamin;
  final _kewarganegaraanCtrl = TextEditingController(text: 'WNI');
  String? _agama;
  final _pekerjaanCtrl     = TextEditingController();
  final _alamatCtrl        = TextEditingController();
  final _noHpCtrl          = TextEditingController();

  // ── Data Usaha ─────────────────────────────────────────────────────────────
  final _namaUsahaCtrl    = TextEditingController();
  final _jenisUsahaCtrl   = TextEditingController();
  final _alamatUsahaCtrl  = TextEditingController();
  final _tujuanCtrl       = TextEditingController();

  bool _isLoading = false;

  static const List<String> _agamaList = [
    'Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu',
  ];

  @override
  void dispose() {
    _nikCtrl.dispose();
    _namaCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _tanggalLahirCtrl.dispose();
    _kewarganegaraanCtrl.dispose();
    _pekerjaanCtrl.dispose();
    _alamatCtrl.dispose();
    _noHpCtrl.dispose();
    _namaUsahaCtrl.dispose();
    _jenisUsahaCtrl.dispose();
    _alamatUsahaCtrl.dispose();
    _tujuanCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // Simulasi pengiriman
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (!mounted) return;
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppTheme.surface,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: AppTheme.primary, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Permohonan Terkirim!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Surat Keterangan Usaha Anda sedang diproses. Pantau status di halaman beranda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // tutup dialog
                    Navigator.pop(context); // kembali ke layanan
                  },
                  child: const Text('Kembali ke Layanan'),
                ),
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
        title: const Text('Surat Keterangan Usaha'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [

            // ── Nama Surat (read-only) ─────────────────────────────────
            _sectionCard(children: [
              _label('Nama Surat'),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  'SURAT KETERANGAN USAHA',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Data Pemohon ───────────────────────────────────────────
            _sectionCard(children: [
              _sectionHeader('Data Pemohon'),
              const SizedBox(height: 16),

              // NIK
              _label('NIK', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nikCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                style: GoogleFonts.poppins(fontSize: 13),
                decoration:
                    const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
                validator: (v) {
                  if (v!.isEmpty) return 'NIK wajib diisi';
                  if (v.length != 16) return 'NIK harus 16 digit';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Nama Lengkap
              _label('Nama Lengkap', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration:
                    const InputDecoration(hintText: 'Masukkan nama lengkap'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Tempat Lahir
              _label('Tempat Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tempatLahirCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration:
                    const InputDecoration(hintText: 'Masukkan tempat lahir'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Tempat lahir wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Tanggal Lahir
              _label('Tanggal Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tanggalLahirCtrl,
                readOnly: true,
                onTap: _selectDate,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'dd/mm/yyyy',
                  suffixIcon: Icon(Icons.calendar_today,
                      size: 16, color: AppTheme.textSecondary),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Tanggal lahir wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Jenis Kelamin
              _label('Jenis Kelamin', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _jenisKelamin,
                decoration: _dropdownDeco('Pilih jenis kelamin'),
                items: ['Laki-laki', 'Perempuan']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              style: GoogleFonts.poppins(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _jenisKelamin = v),
                validator: (v) =>
                    v == null ? 'Jenis kelamin wajib dipilih' : null,
              ),
              const SizedBox(height: 14),

              // Kewarganegaraan
              _label('Kewarganegaraan', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _kewarganegaraanCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration:
                    const InputDecoration(hintText: 'Contoh: WNI'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Kewarganegaraan wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Agama
              _label('Agama', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _agama,
                decoration: _dropdownDeco('Pilih agama'),
                items: _agamaList
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              style: GoogleFonts.poppins(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _agama = v),
                validator: (v) =>
                    v == null ? 'Agama wajib dipilih' : null,
              ),
              const SizedBox(height: 14),

              // Pekerjaan
              _label('Pekerjaan', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pekerjaanCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration:
                    const InputDecoration(hintText: 'Masukkan pekerjaan'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Pekerjaan wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Alamat
              _label('Alamat', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _alamatCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration:
                    const InputDecoration(hintText: 'Masukkan alamat'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Alamat wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // No HP / WA
              _label('No. HP / WhatsApp', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noHpCtrl,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Contoh: 081234567890'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nomor HP wajib diisi';
                  }
                  final d = v.trim().replaceAll(RegExp(r'\D'), '');
                  if (d.length < 9 || d.length > 13) {
                    return 'Nomor HP tidak valid (9–13 digit)';
                  }
                  return null;
                },
              ),
            ]),
            const SizedBox(height: 16),

            // ── Data Usaha ─────────────────────────────────────────────
            _sectionCard(children: [
              _sectionHeader('Data Usaha'),
              const SizedBox(height: 16),

              // Nama Usaha
              _label('Nama Usaha', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaUsahaCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration:
                    const InputDecoration(hintText: 'Masukkan nama usaha'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Nama usaha wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Jenis Usaha
              _label('Jenis Usaha', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _jenisUsahaCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Contoh: Perdagangan, Jasa, Pertanian'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Jenis usaha wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Alamat Usaha
              _label('Alamat Usaha', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _alamatUsahaCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration:
                    const InputDecoration(hintText: 'Masukkan alamat usaha'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Alamat usaha wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Tujuan Pengajuan
              _label('Tujuan Pengajuan', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tujuanCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Masukkan tujuan pengajuan'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Tujuan pengajuan wajib diisi' : null,
              ),
            ]),
            const SizedBox(height: 24),

            bottomButtons(
              onBack: () => Navigator.pop(context),
              onSubmit: _isLoading ? null : _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionCard({required List<Widget> children}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  Widget _sectionHeader(String title) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppTheme.border),
        ],
      );

  Widget _label(String text, {bool required = false}) => RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
          children: [
            TextSpan(text: text),
            if (required)
              const TextSpan(
                  text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      );

  InputDecoration _dropdownDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            fontSize: 13, color: AppTheme.textSecondary),
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
          borderSide:
              const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      );
}
