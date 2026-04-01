import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

const _jenisKtpList = [
  'KTP Baru', 'Perpanjangan KTP', 'KTP Hilang', 'KTP Rusak', 'KTP Luar Domisili',
];

// ════════════════════════════════════════════════════════════════════════════
// B05 — Formulir Permohonan KTP (F-1.21)
// ════════════════════════════════════════════════════════════════════════════
class FormulirKtpScreen extends StatefulWidget {
  const FormulirKtpScreen({super.key});
  @override
  State<FormulirKtpScreen> createState() => _KtpState();
}

class _KtpState extends State<FormulirKtpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Wilayah
  final _provCtrl  = TextEditingController();
  final _kabCtrl   = TextEditingController();
  final _kecCtrl   = TextEditingController();
  final _desaCtrl  = TextEditingController();

  // Jenis KTP
  String? _jenisKtp;

  // Pemohon
  final _namaCtrl   = TextEditingController();
  final _nikCtrl    = TextEditingController();
  final _noKkCtrl   = TextEditingController();
  final _noTelpCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _rtCtrl     = TextEditingController();
  final _rwCtrl     = TextEditingController();
  final _kodeCtrl   = TextEditingController();

  @override
  void dispose() {
    for (final c in [_provCtrl, _kabCtrl, _kecCtrl, _desaCtrl, _namaCtrl,
      _nikCtrl, _noKkCtrl, _noTelpCtrl, _alamatCtrl, _rtCtrl, _rwCtrl,
      _kodeCtrl]) { c.dispose(); }
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Formulir Permohonan KTP');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Formulir Permohonan KTP'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            namaSuratCard('FORMULIR PERMOHONAN KTP (F-1.21)'),
            const SizedBox(height: 16),

            buildDataWilayah(provinsi: _provCtrl, kabKota: _kabCtrl,
                kecamatan: _kecCtrl, desa: _desaCtrl),
            const SizedBox(height: 16),

            // ── Jenis Permohonan ─────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Jenis Permohonan KTP'),
              const SizedBox(height: 16),

              fieldLabel('Permohonan KTP', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(value: _jenisKtp,
                decoration: dropdownDeco('Pilih jenis permohonan KTP'),
                items: _jenisKtpList.map((e) => DropdownMenuItem(value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _jenisKtp = v),
                validator: (v) => v == null ? 'Jenis permohonan wajib dipilih' : null),
            ]),
            const SizedBox(height: 16),

            // ── Data Pemohon ─────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Pemohon'),
              const SizedBox(height: 16),

              fieldLabel('Nama Lengkap', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _namaCtrl, style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
                validator: (v) => validateRequired(v, 'Nama')),
              const SizedBox(height: 14),

              fieldLabel('NIK', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _nikCtrl,
                keyboardType: TextInputType.number, inputFormatters: nikFormatters,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
                validator: validateNIK),
              const SizedBox(height: 14),

              fieldLabel('No. KK', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _noKkCtrl,
                keyboardType: TextInputType.number, inputFormatters: nikFormatters,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan 16 digit Nomor KK'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'No. KK wajib diisi';
                  if (v.length != 16) return 'No. KK harus 16 digit';
                  return null;
                }),
              const SizedBox(height: 14),

              fieldLabel('No. Telepon', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _noTelpCtrl, keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: 081234567890'),
                validator: validatePhone),
              const SizedBox(height: 14),

              fieldLabel('Alamat Pemohon', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _alamatCtrl, maxLines: 2,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan alamat pemohon'),
                validator: (v) => validateRequired(v, 'Alamat')),
              const SizedBox(height: 14),

              fieldLabel('RT', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _rtCtrl, keyboardType: TextInputType.number,
                inputFormatters: angkaFormatters, style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: 001'),
                validator: (v) => validateRequired(v, 'RT')),
              const SizedBox(height: 14),

              fieldLabel('RW', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _rwCtrl, keyboardType: TextInputType.number,
                inputFormatters: angkaFormatters, style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: 002'),
                validator: (v) => validateRequired(v, 'RW')),
              const SizedBox(height: 14),

              fieldLabel('Kode Pos', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _kodeCtrl, keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5)],
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: 50271'),
                validator: (v) => validateRequired(v, 'Kode Pos')),
            ]),
            const SizedBox(height: 24),

            bottomButtons(onBack: () => Navigator.pop(context),
                onSubmit: _submit, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
