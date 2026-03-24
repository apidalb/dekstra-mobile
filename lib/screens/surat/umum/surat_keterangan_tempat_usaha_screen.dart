import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class SuratKeteranganTempatUsahaScreen extends StatefulWidget {
  const SuratKeteranganTempatUsahaScreen({super.key});

  @override
  State<SuratKeteranganTempatUsahaScreen> createState() =>
      _SuratKeteranganTempatUsahaScreenState();
}

class _SuratKeteranganTempatUsahaScreenState
    extends State<SuratKeteranganTempatUsahaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Data Usaha
  final _namaUsahaCtrl   = TextEditingController();
  final _jenisUsahaCtrl  = TextEditingController();
  final _alamatUsahaCtrl = TextEditingController();
  final _nibCtrl         = TextEditingController();
  final _npwpCtrl        = TextEditingController();

  // Data Pemilik
  final _namaCtrl  = TextEditingController();
  final _nikCtrl   = TextEditingController();
  final _alamatCtrl = TextEditingController();

  // Tujuan
  final _tujuanCtrl = TextEditingController();

  @override
  void dispose() {
    _namaUsahaCtrl.dispose(); _jenisUsahaCtrl.dispose();
    _alamatUsahaCtrl.dispose(); _nibCtrl.dispose(); _npwpCtrl.dispose();
    _namaCtrl.dispose(); _nikCtrl.dispose(); _alamatCtrl.dispose();
    _tujuanCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Surat Keterangan Tempat Usaha');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Surat Ket. Tempat Usaha'),
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
            namaSuratCard('SURAT KETERANGAN TEMPAT USAHA'),
            const SizedBox(height: 16),

            // ── Data Usaha ───────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Usaha'),
              const SizedBox(height: 16),

              fieldLabel('Nama Usaha', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaUsahaCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama usaha'),
                validator: (v) => validateRequired(v, 'Nama usaha'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Jenis Usaha', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _jenisUsahaCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Contoh: Perdagangan, Jasa, Pertanian'),
                validator: (v) => validateRequired(v, 'Jenis usaha'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Alamat Usaha', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _alamatUsahaCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan alamat usaha'),
                validator: (v) => validateRequired(v, 'Alamat usaha'),
              ),
              const SizedBox(height: 14),

              fieldLabel('No. Induk Berusaha (NIB)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nibCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Nomor NIB (opsional)'),
              ),
              const SizedBox(height: 14),

              fieldLabel('NPWP'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _npwpCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Nomor NPWP (opsional)'),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Data Pemilik ─────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Pemilik'),
              const SizedBox(height: 16),

              fieldLabel('Nama Pemilik', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama pemilik'),
                validator: (v) => validateRequired(v, 'Nama pemilik'),
              ),
              const SizedBox(height: 14),

              fieldLabel('NIK', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nikCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: nikFormatters,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
                validator: validateNIK,
              ),
              const SizedBox(height: 14),

              fieldLabel('Alamat', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _alamatCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan alamat pemilik'),
                validator: (v) => validateRequired(v, 'Alamat'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Tujuan Pengajuan', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tujuanCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan tujuan pengajuan'),
                validator: (v) => validateRequired(v, 'Tujuan pengajuan'),
              ),
            ]),
            const SizedBox(height: 24),

            bottomButtons(
              onBack: () => Navigator.pop(context),
              onSubmit: _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
