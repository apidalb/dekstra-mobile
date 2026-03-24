import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

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
