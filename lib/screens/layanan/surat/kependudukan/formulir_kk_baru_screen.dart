import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

// ════════════════════════════════════════════════════════════════════════════
// B03 — Formulir Permohonan KK Baru WNI (F-1.15)
// ════════════════════════════════════════════════════════════════════════════
class FormulirKkBaruScreen extends StatefulWidget {
  const FormulirKkBaruScreen({super.key});
  @override
  State<FormulirKkBaruScreen> createState() => _KkBaruState();
}

class _KkBaruState extends State<FormulirKkBaruScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Wilayah
  final _provCtrl    = TextEditingController();
  final _kabCtrl     = TextEditingController();
  final _kecCtrl     = TextEditingController();
  final _desaCtrl    = TextEditingController();

  // Pemohon
  final _namaCtrl    = TextEditingController();
  final _nikCtrl     = TextEditingController();
  final _noKkSemCtrl = TextEditingController();
  final _noTelpCtrl  = TextEditingController();
  final _alamatCtrl  = TextEditingController();
  final _rtCtrl      = TextEditingController();
  final _rwCtrl      = TextEditingController();
  final _desaPemCtrl = TextEditingController();
  final _kecPemCtrl  = TextEditingController();
  final _kabPemCtrl  = TextEditingController();
  final _provPemCtrl = TextEditingController();
  final _kodeCtrl    = TextEditingController();

  // Keterangan
  String? _alasan;
  final _jumlahCtrl  = TextEditingController();

  // Anggota
  final List<AnggotaKK> _anggota = [AnggotaKK()];

  @override
  void dispose() {
    for (final c in [_provCtrl, _kabCtrl, _kecCtrl, _desaCtrl, _namaCtrl,
      _nikCtrl, _noKkSemCtrl, _noTelpCtrl, _alamatCtrl, _rtCtrl, _rwCtrl,
      _desaPemCtrl, _kecPemCtrl, _kabPemCtrl, _provPemCtrl, _kodeCtrl,
      _jumlahCtrl]) { c.dispose(); }
    for (final a in _anggota) { a.dispose(); }
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Formulir Permohonan KK Baru WNI');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Formulir KK Baru WNI'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            namaSuratCard('FORMULIR PERMOHONAN KK BARU WNI (F-1.15)'),
            const SizedBox(height: 16),

            buildDataWilayah(provinsi: _provCtrl, kabKota: _kabCtrl,
                kecamatan: _kecCtrl, desa: _desaCtrl),
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

              fieldLabel('No. KK Semula'),
              const SizedBox(height: 6),
              TextFormField(controller: _noKkSemCtrl,
                keyboardType: TextInputType.number, inputFormatters: nikFormatters,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Isi jika sebelumnya sudah memiliki KK')),
              const SizedBox(height: 14),

              fieldLabel('No. Telepon', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _noTelpCtrl, keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: 081234567890'),
                validator: validatePhone),
              const SizedBox(height: 14),

              ..._buildAlamatPemohon(),
            ]),
            const SizedBox(height: 16),

            // ── Keterangan Permohonan ────────────────────────────────
            sectionCard(children: [
              sectionHeader('Keterangan Permohonan'),
              const SizedBox(height: 16),

              fieldLabel('Alasan Permohonan', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(initialValue: _alasan,
                decoration: dropdownDeco('Pilih alasan permohonan'),
                items: kAlasanKkList.map((e) => DropdownMenuItem(value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _alasan = v),
                validator: (v) => v == null ? 'Wajib dipilih' : null),
              const SizedBox(height: 14),

              fieldLabel('Jumlah Anggota Keluarga', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _jumlahCtrl,
                keyboardType: TextInputType.number, inputFormatters: angkaFormatters,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Masukkan jumlah anggota keluarga', suffixText: 'Orang'),
                validator: (v) => validateRequired(v, 'Jumlah anggota')),
            ]),
            const SizedBox(height: 16),

            buildTabelAnggota(_anggota, setState),
            const SizedBox(height: 24),

            bottomButtons(onBack: () => Navigator.pop(context),
                onSubmit: _submit, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAlamatPemohon() => [
    ...buildAlamatBlock(
      alamat: _alamatCtrl, rt: _rtCtrl, rw: _rwCtrl,
      desa: _desaPemCtrl, kec: _kecPemCtrl, kab: _kabPemCtrl,
      prov: _provPemCtrl, kodePos: _kodeCtrl),
  ];
}
