import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

// Data satu ahli waris
class _AhliWaris {
  final namaCtrl   = TextEditingController();
  final nikCtrl    = TextEditingController();
  final tempatCtrl = TextEditingController();
  final tglCtrl    = TextEditingController();
  final alamatCtrl = TextEditingController();

  void dispose() {
    namaCtrl.dispose(); nikCtrl.dispose();
    tempatCtrl.dispose(); tglCtrl.dispose(); alamatCtrl.dispose();
  }
}

class SuratKeteranganAhliWarisScreen extends StatefulWidget {
  const SuratKeteranganAhliWarisScreen({super.key});

  @override
  State<SuratKeteranganAhliWarisScreen> createState() =>
      _SuratKeteranganAhliWarisScreenState();
}

class _SuratKeteranganAhliWarisScreenState
    extends State<SuratKeteranganAhliWarisScreen> {
  final _formKey  = GlobalKey<FormState>();
  bool _isLoading = false;

  final _namaPewarisCtrl  = TextEditingController();
  final _namaWarisanCtrl  = TextEditingController();

  // Minimal 1, maks 7 sesuai template
  final List<_AhliWaris> _daftarWaris = [_AhliWaris()];

  @override
  void dispose() {
    _namaPewarisCtrl.dispose();
    _namaWarisanCtrl.dispose();
    for (final w in _daftarWaris) { w.dispose(); }
    super.dispose();
  }

  void _tambahWaris() {
    if (_daftarWaris.length < 7) {
      setState(() => _daftarWaris.add(_AhliWaris()));
    }
  }

  void _hapusWaris(int index) {
    if (_daftarWaris.length > 1) {
      _daftarWaris[index].dispose();
      setState(() => _daftarWaris.removeAt(index));
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Surat Keterangan Ahli Waris');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Surat Ket. Ahli Waris'),
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
            namaSuratCard('SURAT KETERANGAN AHLI WARIS'),
            const SizedBox(height: 16),

            // ── Data Pewaris ─────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Pewaris'),
              const SizedBox(height: 16),

              fieldLabel('Nama Pewaris (Almarhum/ah)', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaPewarisCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Masukkan nama pewaris'),
                validator: (v) => validateRequired(v, 'Nama pewaris'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Nama / Jenis Warisan', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaWarisanCtrl,
                maxLines: 2,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Contoh: sebidang tanah di Desa ..., rumah di Jl. ...'),
                validator: (v) => validateRequired(v, 'Nama warisan'),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Daftar Ahli Waris ────────────────────────────────────
            ...List.generate(_daftarWaris.length, (i) {
              final w = _daftarWaris[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: sectionCard(children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ahli Waris ${i + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (_daftarWaris.length > 1)
                        GestureDetector(
                          onTap: () => _hapusWaris(i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Hapus',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppTheme.border),
                  const SizedBox(height: 14),

                  fieldLabel('Nama Lengkap', required: true),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: w.namaCtrl,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
                    validator: (v) => validateRequired(v, 'Nama'),
                  ),
                  const SizedBox(height: 12),

                  fieldLabel('NIK', required: true),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: w.nikCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: nikFormatters,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: const InputDecoration(
                        hintText: 'Masukkan 16 digit NIK'),
                    validator: validateNIK,
                  ),
                  const SizedBox(height: 12),

                  fieldLabel('Tempat Lahir', required: true),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: w.tempatCtrl,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: const InputDecoration(
                        hintText: 'Masukkan tempat lahir'),
                    validator: (v) => validateRequired(v, 'Tempat lahir'),
                  ),
                  const SizedBox(height: 12),

                  fieldLabel('Tanggal Lahir', required: true),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: w.tglCtrl,
                    readOnly: true,
                    onTap: () => pickDate(context, w.tglCtrl),
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'dd/mm/yyyy',
                      suffixIcon: Icon(Icons.calendar_today,
                          size: 16, color: AppTheme.textSecondary),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Tanggal lahir wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),

                  fieldLabel('Alamat', required: true),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: w.alamatCtrl,
                    maxLines: 2,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: const InputDecoration(
                        hintText: 'Masukkan alamat'),
                    validator: (v) => validateRequired(v, 'Alamat'),
                  ),
                ]),
              );
            }),

            // Tombol tambah waris
            if (_daftarWaris.length < 7)
              OutlinedButton.icon(
                onPressed: _tambahWaris,
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Tambah Ahli Waris (${_daftarWaris.length}/7)',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),

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
