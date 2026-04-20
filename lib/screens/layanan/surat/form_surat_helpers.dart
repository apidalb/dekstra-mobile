import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_theme.dart';
import '../../../services/api_service.dart';

// ── Shared helpers for all surat form screens ─────────────────────────────────

const List<String> kAgamaList = [
  'Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu',
];

const List<String> kJenisKelaminList = ['Laki-laki', 'Perempuan'];

const List<String> kStatusPernikahanList = [
  'Belum Menikah', 'Menikah', 'Cerai Hidup', 'Cerai Mati',
];

// ── Section card ──────────────────────────────────────────────────────────────
Widget sectionCard({required List<Widget> children}) => Container(
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

// ── Section header with divider ───────────────────────────────────────────────
Widget sectionHeader(String title) => Column(
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

// ── Field label ───────────────────────────────────────────────────────────────
Widget fieldLabel(String text, {bool required = false}) => RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 13,
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

// ── Nama surat read-only ──────────────────────────────────────────────────────
Widget namaSuratCard(String nama) => sectionCard(children: [
      fieldLabel('Nama Surat'),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(
          nama,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    ]);

// ── Dropdown decoration ───────────────────────────────────────────────────────
InputDecoration dropdownDeco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary),
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

// ── Standard bottom buttons ───────────────────────────────────────────────────
Widget bottomButtons({
  required VoidCallback onBack,
  required VoidCallback? onSubmit,
  bool isLoading = false,
}) =>
    Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
            child: const Text('Kembali', maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Ajukan Surat', maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );

// ── Konversi tanggal "dd/mm/yyyy" → "yyyy-mm-dd" untuk backend ───────────────
String ddmmyyyyToIso(String v) {
  if (v.isEmpty) return '';
  final parts = v.split('/');
  if (parts.length != 3) return v;
  return '${parts[2]}-${parts[1]}-${parts[0]}';
}

// ── Reusable date picker field ────────────────────────────────────────────────
Future<void> pickDate(
    BuildContext context, TextEditingController ctrl) async {
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
    ctrl.text = '${picked.day.toString().padLeft(2, '0')}/'
        '${picked.month.toString().padLeft(2, '0')}/'
        '${picked.year}';
  }
}

Future<void> pickFutureDate(
    BuildContext context, TextEditingController ctrl) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now().add(const Duration(days: 1)),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (c, child) => Theme(
      data: Theme.of(c).copyWith(
        colorScheme: const ColorScheme.light(primary: AppTheme.primary),
      ),
      child: child!,
    ),
  );
  if (picked != null) {
    ctrl.text = '${picked.day.toString().padLeft(2, '0')}/'
        '${picked.month.toString().padLeft(2, '0')}/'
        '${picked.year}';
  }
}

// ── Common validator helpers ──────────────────────────────────────────────────
String? validateRequired(String? v, String fieldName) {
  if (v == null || v.trim().isEmpty) return '$fieldName wajib diisi';
  return null;
}

String? validateNIK(String? v) {
  if (v == null || v.isEmpty) return 'NIK wajib diisi';
  if (v.length != 16) return 'NIK harus 16 digit';
  return null;
}

String? validatePhone(String? v) {
  if (v == null || v.trim().isEmpty) return 'Nomor HP wajib diisi';
  final d = v.trim().replaceAll(RegExp(r'\D'), '');
  if (d.length < 9 || d.length > 13) return 'Nomor HP tidak valid (9–13 digit)';
  return null;
}

// ── NIK input formatters ──────────────────────────────────────────────────────
List<TextInputFormatter> get nikFormatters => [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(16),
    ];

// ── Angka input formatter ─────────────────────────────────────────────────────
List<TextInputFormatter> get angkaFormatters => [
      FilteringTextInputFormatter.digitsOnly,
    ];

// ── Kode Pos input formatters ─────────────────────────────────────────────────
List<TextInputFormatter> get kodePosFormatters => [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(5),
    ];


// ── Helpers khusus kependudukan ──────────────────────────────────────────────
// ── Konstanta bersama ─────────────────────────────────────────────────────────
const kShdkList = [
  'Kepala Keluarga', 'Suami', 'Istri', 'Anak', 'Menantu',
  'Cucu', 'Orang Tua', 'Mertua', 'Famili Lain', 'Pembantu', 'Lainnya',
];

const kAlasanKkList = [
  'Membentuk Keluarga Baru', 'Pergantian Kepala Keluarga',
  'Pisah KK', 'Pindah Datang', 'Numpang KK',
  'WNI dari LN karena Pindah', 'Rentan Adminduk',
];

// ── Model anggota keluarga ────────────────────────────────────────────────────
class AnggotaKK {
  final namaCtrl = TextEditingController();
  final nikCtrl  = TextEditingController();
  String? shdk;
  void dispose() { namaCtrl.dispose(); nikCtrl.dispose(); }
}

// ── Section Data Wilayah (vertikal) ──────────────────────────────────────────
Widget buildDataWilayah({
  required TextEditingController provinsi,
  required TextEditingController kabKota,
  required TextEditingController kecamatan,
  required TextEditingController desa,
}) {
  return sectionCard(children: [
    sectionHeader('Data Wilayah'),
    const SizedBox(height: 16),

    fieldLabel('Nama Pemerintah Provinsi', required: true),
    const SizedBox(height: 6),
    TextFormField(controller: provinsi, style: GoogleFonts.poppins(fontSize: 13),
      decoration: const InputDecoration(hintText: 'Contoh: Jawa Tengah'),
      validator: (v) => validateRequired(v, 'Provinsi')),
    const SizedBox(height: 14),

    fieldLabel('Nama Pemerintah Kabupaten/Kota', required: true),
    const SizedBox(height: 6),
    TextFormField(controller: kabKota, style: GoogleFonts.poppins(fontSize: 13),
      decoration: const InputDecoration(hintText: 'Contoh: Kota Semarang'),
      validator: (v) => validateRequired(v, 'Kabupaten/Kota')),
    const SizedBox(height: 14),

    fieldLabel('Nama Kecamatan', required: true),
    const SizedBox(height: 6),
    TextFormField(controller: kecamatan, style: GoogleFonts.poppins(fontSize: 13),
      decoration: const InputDecoration(hintText: 'Contoh: Semarang Tengah'),
      validator: (v) => validateRequired(v, 'Kecamatan')),
    const SizedBox(height: 14),

    fieldLabel('Nama Kelurahan/Desa', required: true),
    const SizedBox(height: 6),
    TextFormField(controller: desa, style: GoogleFonts.poppins(fontSize: 13),
      decoration: const InputDecoration(hintText: 'Contoh: Miroto'),
      validator: (v) => validateRequired(v, 'Desa/Kelurahan')),
  ]);
}

// ── Tabel anggota keluarga ────────────────────────────────────────────────────
Widget buildTabelAnggota(List<AnggotaKK> anggota, StateSetter setState) {
  return sectionCard(children: [
    sectionHeader('Data Anggota Keluarga'),
    const SizedBox(height: 12),
    ...List.generate(anggota.length, (i) {
      final a = anggota[i];
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('${i + 1}.',
                style: GoogleFonts.poppins(fontSize: 13,
                    fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const Spacer(),
            if (anggota.length > 1)
              GestureDetector(
                onTap: () { a.dispose(); setState(() => anggota.removeAt(i)); },
                child: Text('Hapus',
                    style: GoogleFonts.poppins(fontSize: 12,
                        color: Colors.red, fontWeight: FontWeight.w500)),
              ),
          ]),
          const SizedBox(height: 8),
          fieldLabel('Nama Lengkap', required: true),
          const SizedBox(height: 6),
          TextFormField(controller: a.namaCtrl,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
            validator: (v) => validateRequired(v, 'Nama')),
          const SizedBox(height: 10),
          fieldLabel('NIK', required: true),
          const SizedBox(height: 6),
          TextFormField(controller: a.nikCtrl,
            keyboardType: TextInputType.number, inputFormatters: nikFormatters,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
            validator: validateNIK),
          const SizedBox(height: 10),
          fieldLabel('Status Hubungan dalam Keluarga', required: true),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(initialValue: a.shdk,
            decoration: dropdownDeco('Pilih status hubungan'),
            items: kShdkList.map((e) => DropdownMenuItem(value: e,
                child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
            onChanged: (v) => setState(() => a.shdk = v),
            validator: (v) => v == null ? 'Wajib dipilih' : null),
          if (i < anggota.length - 1)
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Divider(height: 1, color: AppTheme.border),
            ),
        ]),
      );
    }),
    TextButton.icon(
      onPressed: () => setState(() => anggota.add(AnggotaKK())),
      icon: const Icon(Icons.add, size: 16),
      label: Text('Tambah Anggota',
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
    ),
  ]);
}

// ── Blok alamat lengkap (vertikal) ────────────────────────────────────────────
List<Widget> buildAlamatBlock({
  required TextEditingController alamat,
  required TextEditingController rt,
  required TextEditingController rw,
  required TextEditingController desa,
  required TextEditingController kec,
  required TextEditingController kab,
  required TextEditingController prov,
  required TextEditingController kodePos,
}) {
  return [
    fieldLabel('Alamat', required: true),
    const SizedBox(height: 6),
    TextFormField(controller: alamat, maxLines: 2,
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: const InputDecoration(hintText: 'Masukkan alamat'),
      validator: (v) => validateRequired(v, 'Alamat')),
    const SizedBox(height: 12),

    fieldLabel('RT', required: true),
    const SizedBox(height: 6),
    TextFormField(controller: rt, keyboardType: TextInputType.number,
      inputFormatters: angkaFormatters, style: GoogleFonts.poppins(fontSize: 13),
      decoration: const InputDecoration(hintText: 'Contoh: 001'),
      validator: (v) => validateRequired(v, 'RT')),
    const SizedBox(height: 12),

    fieldLabel('RW', required: true),
    const SizedBox(height: 6),
    TextFormField(controller: rw, keyboardType: TextInputType.number,
      inputFormatters: angkaFormatters, style: GoogleFonts.poppins(fontSize: 13),
      decoration: const InputDecoration(hintText: 'Contoh: 002'),
      validator: (v) => validateRequired(v, 'RW')),
    const SizedBox(height: 12),

    fieldLabel('Desa/Kelurahan', required: true),
    const SizedBox(height: 6),
    TextFormField(controller: desa, style: GoogleFonts.poppins(fontSize: 13),
      decoration: const InputDecoration(hintText: 'Masukkan desa/kelurahan'),
      validator: (v) => validateRequired(v, 'Desa')),
    const SizedBox(height: 12),

    fieldLabel('Kecamatan', required: true),
    const SizedBox(height: 6),
    TextFormField(controller: kec, style: GoogleFonts.poppins(fontSize: 13),
      decoration: const InputDecoration(hintText: 'Masukkan kecamatan'),
      validator: (v) => validateRequired(v, 'Kecamatan')),
    const SizedBox(height: 12),

    fieldLabel('Kabupaten/Kota', required: true),
    const SizedBox(height: 6),
    TextFormField(controller: kab, style: GoogleFonts.poppins(fontSize: 13),
      decoration: const InputDecoration(hintText: 'Masukkan kabupaten/kota'),
      validator: (v) => validateRequired(v, 'Kabupaten/Kota')),
    const SizedBox(height: 12),

    fieldLabel('Provinsi', required: true),
    const SizedBox(height: 6),
    TextFormField(controller: prov, style: GoogleFonts.poppins(fontSize: 13),
      decoration: const InputDecoration(hintText: 'Masukkan provinsi'),
      validator: (v) => validateRequired(v, 'Provinsi')),
    const SizedBox(height: 12),

    fieldLabel('Kode Pos', required: true),
    const SizedBox(height: 6),
    TextFormField(controller: kodePos, keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5)],
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: const InputDecoration(hintText: 'Contoh: 50271'),
      validator: (v) => validateRequired(v, 'Kode Pos')),
  ];
}

// ── Validator tanggal (readOnly date fields) ──────────────────────────────────
String? validateDate(String? v, String fieldName) {
  if (v == null || v.isEmpty) return '$fieldName wajib diisi';
  return null;
}

// ── Tambahan konstanta bersama ────────────────────────────────────────────────
const kKewarganegaraanList = ['WNI', 'WNA'];

const kHariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

const kAlasanPindahList = [
  'Pekerjaan', 'Pendidikan', 'Keamanan', 'Kesehatan', 'Perumahan', 'Keluarga', 'Lainnya',
];

const kStatusHubunganKematianList = [
  'Anak', 'Suami', 'Istri', 'Orang Tua', 'Saudara Kandung', 'Keponakan', 'Cucu', 'Lainnya',
];

// ══════════════════════════════════════════════════════════════════════════════
// STEPPER INFRASTRUCTURE
// ══════════════════════════════════════════════════════════════════════════════

/// Satu langkah data dalam wizard form surat.
class SuratDataStep {
  final String title;
  /// Key untuk validasi. Sertakan Form(key: formKey) di dalam [content].
  final GlobalKey<FormState>? formKey;
  /// Konten step (termasuk Form widget jika perlu validasi).
  final Widget content;
  const SuratDataStep({required this.title, this.formKey, required this.content});
}

/// Halaman stepper lengkap untuk semua form surat.
/// Mengelola navigasi antar step, Upload Dokumen, dan Kirim Pengajuan.
class SuratStepperPage extends StatefulWidget {
  final String appBarTitle;
  /// Kode jenis surat sesuai seed backend (contoh: 'A01', 'B06').
  final String jenisSurat;
  final List<SuratDataStep> dataSteps;
  /// Dipanggil saat user mengajukan: kembalikan Map data form (snake_case).
  final Future<Map<String, dynamic>> Function() onBuildPayload;

  const SuratStepperPage({
    super.key,
    required this.appBarTitle,
    required this.jenisSurat,
    required this.dataSteps,
    required this.onBuildPayload,
  });

  @override
  State<SuratStepperPage> createState() => _SuratStepperPageState();
}

class _SuratStepperPageState extends State<SuratStepperPage> {
  int _currentStep = 0;
  bool _isLoading  = false;
  bool _agreed1    = false;
  bool _agreed2    = false;
  List<XFile> _uploadFiles = [];

  int get _uploadStepIndex => widget.dataSteps.length;
  int get _kirimStepIndex  => widget.dataSteps.length + 1;
  int get _totalSteps      => widget.dataSteps.length + 2;

  String _stepLabel(int index) {
    if (index < widget.dataSteps.length) return widget.dataSteps[index].title;
    if (index == _uploadStepIndex) return 'Upload\nDokumen';
    return 'Kirim\nPengajuan';
  }

  void _goNext() {
    if (_currentStep < widget.dataSteps.length) {
      final fk = widget.dataSteps[_currentStep].formKey;
      if (fk != null && fk.currentState != null) {
        if (!fk.currentState!.validate()) return;
      }
    }
    if (_currentStep < _totalSteps - 1) setState(() => _currentStep++);
  }

  void _goBack() {
    if (_currentStep > 0) setState(() => _currentStep--);
    else Navigator.pop(context);
  }

  Future<void> _handleSubmit() async {
    if (!_agreed1 || !_agreed2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Harap centang semua pernyataan persetujuan.',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final data   = await widget.onBuildPayload();
      final result = await ApiService.submitPermohonan(
        jenisSurat: widget.jenisSurat,
        data: data,
      );
      final nomor = result['nomor_permohonan'] as String;
      for (final file in _uploadFiles) {
        await ApiService.uploadBerkasSurat(nomorPermohonan: nomor, file: file);
      }
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      homeTabIndex.value = 0;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Permohonan berhasil diajukan.',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: Colors.red.shade700,
      ));
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('SocketException') ||
              e.toString().contains('Connection') ||
              e.toString().contains('TimeoutException')
          ? 'Gagal terhubung ke server. Periksa koneksi Anda.'
          : 'Terjadi kesalahan: $e';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: Colors.red.shade700,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentStep == _kirimStepIndex;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.appBarTitle,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(children: [
        _buildStepIndicator(),
        const Divider(height: 1, color: AppTheme.border),
        Expanded(
          child: IndexedStack(
            index: _currentStep,
            children: [
              ...widget.dataSteps.map(_buildDataContent),
              _UploadDokumenContent(
                onFilesChanged: (files) =>
                    setState(() => _uploadFiles = List.from(files)),
              ),
              _KirimPengajuanContent(
                dataStepTitles: widget.dataSteps.map((s) => s.title).toList(),
                agreed1: _agreed1,
                agreed2: _agreed2,
                onAgreed1Changed: (v) => setState(() => _agreed1 = v ?? false),
                onAgreed2Changed: (v) => setState(() => _agreed2 = v ?? false),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _goBack,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  side: const BorderSide(color: AppTheme.primary),
                  foregroundColor: AppTheme.primary,
                  textStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                child: const Text('Kembali'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (isLast ? _handleSubmit : _goNext),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  textStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isLast ? 'Ajukan Surat' : 'Selanjutnya'),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            final done = _currentStep > i ~/ 2;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Container(height: 2,
                    color: done ? AppTheme.primary : AppTheme.border),
              ),
            );
          }
          final step = i ~/ 2;
          final done    = _currentStep > step;
          final current = _currentStep == step;
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (done || current) ? AppTheme.primary : Colors.transparent,
                border: Border.all(
                  color: (done || current) ? AppTheme.primary : AppTheme.border,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text('${step + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: current ? Colors.white : AppTheme.textSecondary,
                        )),
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              width: 52,
              child: Text(
                _stepLabel(step),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 8.5, height: 1.3,
                  fontWeight: (done || current) ? FontWeight.w600 : FontWeight.w400,
                  color: (done || current) ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _buildDataContent(SuratDataStep step) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [step.content],
    );
  }
}

// ── Upload Dokumen step ───────────────────────────────────────────────────────
class _UploadDokumenContent extends StatefulWidget {
  final ValueChanged<List<XFile>>? onFilesChanged;
  const _UploadDokumenContent({this.onFilesChanged});
  @override
  State<_UploadDokumenContent> createState() => _UploadDokumenContentState();
}

class _UploadDokumenContentState extends State<_UploadDokumenContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<XFile> _files = [];
  final _picker = ImagePicker();
  static const _maxFiles = 5;
  static const _instructions = [
    'Ketuk area upload atau tombol "Unggah File" untuk memilih gambar.',
    'Pastikan file dalam format JPG atau PNG dengan ukuran maksimal 5 MB.',
    'Anda dapat mengunggah hingga $_maxFiles gambar dokumen.',
    'Ketuk ikon hapus untuk membatalkan file yang sudah dipilih.',
  ];

  Future<void> _pickImages() async {
    if (_files.length >= _maxFiles) return;
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() {
      for (final f in picked) {
        if (_files.length < _maxFiles) _files.add(f);
      }
    });
    widget.onFilesChanged?.call(List.from(_files));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final canAdd = _files.length < _maxFiles;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        sectionCard(children: [
          sectionHeader('Unggah Dokumen'),
          const SizedBox(height: 12),
          ..._instructions.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 18, height: 18,
                margin: const EdgeInsets.only(right: 8, top: 1),
                decoration: const BoxDecoration(
                    color: AppTheme.primary, shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}',
                    style: GoogleFonts.poppins(
                        fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              Expanded(child: Text(e.value,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary))),
            ]),
          )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Text(
              'Upload dokumen bersifat opsional. Lewati langkah ini jika tidak ada dokumen pendukung yang perlu dilampirkan.',
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF92400E)),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: canAdd ? _pickImages : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: canAdd ? AppTheme.primary.withValues(alpha: 0.4) : AppTheme.border),
                color: canAdd
                    ? AppTheme.primary.withValues(alpha: 0.04)
                    : AppTheme.background,
              ),
              child: Column(children: [
                Icon(Icons.upload_file_outlined, size: 36,
                    color: canAdd ? AppTheme.primary : AppTheme.textSecondary),
                const SizedBox(height: 8),
                Text('Pilih Dokumen',
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: canAdd ? AppTheme.primary : AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Text('JPG atau PNG, maks 5 MB per file',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
                Text('Foto KTP, KK, atau dokumen pendukung lainnya',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: canAdd ? _pickImages : null,
              icon: const Icon(Icons.upload_outlined, size: 16),
              label: Text(canAdd
                  ? 'Unggah File (${_files.length}/$_maxFiles)'
                  : 'Batas file tercapai ($_maxFiles/$_maxFiles)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
                textStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        sectionCard(children: [
          sectionHeader('Daftar Dokumen'),
          const SizedBox(height: 12),
          if (_files.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Column(children: [
                Icon(Icons.folder_open_outlined, size: 36, color: AppTheme.textSecondary),
                const SizedBox(height: 8),
                Text('Belum ada file yang diunggah',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
                Text('Ketuk area di atas untuk memilih gambar',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
              ])),
            )
          else
            ..._files.asMap().entries.map((e) {
              final name = e.value.name;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.image_outlined, color: AppTheme.primary),
                title: Text(name,
                    style: GoogleFonts.poppins(fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() => _files.removeAt(e.key));
                    widget.onFilesChanged?.call(List.from(_files));
                  },
                ),
              );
            }),
        ]),
      ],
    );
  }
}

// ── Kirim Pengajuan step ──────────────────────────────────────────────────────
class _KirimPengajuanContent extends StatelessWidget {
  final List<String> dataStepTitles;
  final bool agreed1;
  final bool agreed2;
  final ValueChanged<bool?> onAgreed1Changed;
  final ValueChanged<bool?> onAgreed2Changed;

  const _KirimPengajuanContent({
    required this.dataStepTitles,
    required this.agreed1,
    required this.agreed2,
    required this.onAgreed1Changed,
    required this.onAgreed2Changed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        sectionCard(children: [
          sectionHeader('Kirim Pengajuan'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _reminder('Periksa kembali setiap data yang telah Anda isi sebelum mengirim pengajuan.'),
              const SizedBox(height: 4),
              _reminder('Pastikan tidak ada kesalahan dalam pengisian data. Kesalahan pengajuan tidak dapat diperbaiki setelah pengajuan dikirim.'),
              const SizedBox(height: 4),
              _reminder('Jika ingin memperbaiki data, gunakan tombol Kembali untuk kembali ke langkah tertentu.'),
            ]),
          ),
          const SizedBox(height: 16),
          ...dataStepTitles.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _reviewCard(e.key + 1, e.value),
          )),
          _reviewCard(dataStepTitles.length + 1, 'Upload Dokumen'),
        ]),
        const SizedBox(height: 12),
        sectionCard(children: [
          CheckboxListTile(
            value: agreed1,
            onChanged: onAgreed1Changed,
            title: Text(
              'Saya Menyatakan Data Yang Saya Kirim Sudah Benar dan Jika Kemudian Hari Terjadi Masalah Hukum Maka Saya Siap Mempertanggungjawabkan Data Yang Saya Kirim',
              style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textPrimary),
            ),
            activeColor: AppTheme.primary,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          const SizedBox(height: 4),
          CheckboxListTile(
            value: agreed2,
            onChanged: onAgreed2Changed,
            title: Text(
              'Saya Menyetujui Bahwa Permohonan Data Akan Diproses Pada Hari dan Jam Kerja. Apabila Permohonan Data Diajukan Di Luar Hari dan Jam Kerja Maka Permohonan Akan Diproses Pada Hari dan Jam Kerja Berikutnya',
              style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textPrimary),
            ),
            activeColor: AppTheme.primary,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ]),
      ],
    );
  }

  static Widget _reviewCard(int n, String title) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppTheme.primaryLight,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
    ),
    child: Row(children: [
      Container(
        width: 24, height: 24,
        decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
        child: Center(child: Text('$n',
            style: GoogleFonts.poppins(
                fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
      const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
    ]),
  );

  static Widget _reminder(String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 5, right: 6),
        child: Icon(Icons.circle, size: 5, color: Color(0xFF92400E)),
      ),
      Expanded(child: Text(text,
          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF92400E)))),
    ],
  );
}
