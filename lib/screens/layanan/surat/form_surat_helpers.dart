import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

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

// ── Success dialog ────────────────────────────────────────────────────────────
void showSuccessDialog(BuildContext context, String namaSurat) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (_) => Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppTheme.surface,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
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
              '$namaSurat Anda sedang diproses. Pantau status di halaman beranda.',
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
