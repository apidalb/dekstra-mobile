import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class SuratKeteranganTidakMampuScreen extends StatefulWidget {
  const SuratKeteranganTidakMampuScreen({super.key});

  @override
  State<SuratKeteranganTidakMampuScreen> createState() =>
      _SuratKeteranganTidakMampuScreenState();
}

class _SuratKeteranganTidakMampuScreenState
    extends State<SuratKeteranganTidakMampuScreen> {
  final _formKey   = GlobalKey<FormState>();
  bool _isLoading  = false;

  // Data Anak
  final _namaAnakCtrl   = TextEditingController();
  final _tempatAnakCtrl = TextEditingController();
  final _tglAnakCtrl    = TextEditingController();
  final _sekolahCtrl    = TextEditingController();
  final _kelasCtrl      = TextEditingController();

  // Data Orang Tua
  final _namaOrtuCtrl   = TextEditingController();
  final _tempatOrtuCtrl = TextEditingController();
  final _tglOrtuCtrl    = TextEditingController();
  final _kwrgCtrl       = TextEditingController(text: 'WNI');
  String? _agama;
  final _pekerjaanCtrl  = TextEditingController();
  final _penghasilanCtrl = TextEditingController();

  // Keperluan
  final _keperluanCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _namaAnakCtrl, _tempatAnakCtrl, _tglAnakCtrl, _sekolahCtrl,
      _kelasCtrl, _namaOrtuCtrl, _tempatOrtuCtrl, _tglOrtuCtrl,
      _kwrgCtrl, _pekerjaanCtrl, _penghasilanCtrl, _keperluanCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Surat Keterangan Tidak Mampu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('SKTM (Sekolah)'),
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
            namaSuratCard('SURAT KETERANGAN TIDAK MAMPU'),
            const SizedBox(height: 16),

            // ── Data Anak ────────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Anak'),
              const SizedBox(height: 16),

              fieldLabel('Nama Anak', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaAnakCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama anak'),
                validator: (v) => validateRequired(v, 'Nama anak'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Tempat Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tempatAnakCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
                validator: (v) => validateRequired(v, 'Tempat lahir'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Tanggal Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tglAnakCtrl,
                readOnly: true,
                onTap: () => pickDate(context, _tglAnakCtrl),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'dd/mm/yyyy',
                  suffixIcon: Icon(Icons.calendar_today,
                      size: 16, color: AppTheme.textSecondary),
                ),
                validator: (v) => validateDate(v, 'Tanggal lahir'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Asal Sekolah', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _sekolahCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: SDN 1 Gantiwarno'),
                validator: (v) => validateRequired(v, 'Asal sekolah'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Kelas', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _kelasCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: 5, VII, X IPA'),
                validator: (v) => validateRequired(v, 'Kelas'),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Data Orang Tua ───────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Orang Tua / Wali'),
              const SizedBox(height: 16),

              fieldLabel('Nama Orang Tua / Wali', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaOrtuCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama orang tua'),
                validator: (v) => validateRequired(v, 'Nama orang tua'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Tempat Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tempatOrtuCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
                validator: (v) => validateRequired(v, 'Tempat lahir'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Tanggal Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tglOrtuCtrl,
                readOnly: true,
                onTap: () => pickDate(context, _tglOrtuCtrl),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'dd/mm/yyyy',
                  suffixIcon: Icon(Icons.calendar_today,
                      size: 16, color: AppTheme.textSecondary),
                ),
                validator: (v) => validateDate(v, 'Tanggal lahir'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Kewarganegaraan', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _kwrgCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: WNI'),
                validator: (v) => validateRequired(v, 'Kewarganegaraan'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Agama', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _agama,
                decoration: dropdownDeco('Pilih agama'),
                items: kAgamaList
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: GoogleFonts.poppins(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _agama = v),
                validator: (v) => v == null ? 'Agama wajib dipilih' : null,
              ),
              const SizedBox(height: 14),

              fieldLabel('Pekerjaan', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pekerjaanCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan pekerjaan'),
                validator: (v) => validateRequired(v, 'Pekerjaan'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Penghasilan per Bulan', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _penghasilanCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Contoh: 1500000',
                  prefixText: 'Rp ',
                  prefixStyle: TextStyle(color: AppTheme.textPrimary),
                ),
                validator: (v) => validateRequired(v, 'Penghasilan'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Keperluan', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _keperluanCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Contoh: mengajukan beasiswa, pembebasan SPP'),
                validator: (v) => validateRequired(v, 'Keperluan'),
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
