import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class SuratKeteranganLainnyaScreen extends StatefulWidget {
  const SuratKeteranganLainnyaScreen({super.key});

  @override
  State<SuratKeteranganLainnyaScreen> createState() =>
      _SuratKeteranganLainnyaScreenState();
}

class _SuratKeteranganLainnyaScreenState
    extends State<SuratKeteranganLainnyaScreen> {
  final _formKey  = GlobalKey<FormState>();
  bool _isLoading = false;

  final _namaCtrl      = TextEditingController();
  final _nikCtrl       = TextEditingController();
  final _tempatCtrl    = TextEditingController();
  final _tglCtrl       = TextEditingController();
  String? _jenisKelamin;
  String? _agama;
  final _pekerjaanCtrl = TextEditingController();
  final _alamatCtrl    = TextEditingController();
  final _keperluanCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _namaCtrl, _nikCtrl, _tempatCtrl, _tglCtrl,
      _pekerjaanCtrl, _alamatCtrl, _keperluanCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Surat Keterangan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Surat Keterangan Lainnya'),
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
            namaSuratCard('SURAT KETERANGAN'),
            const SizedBox(height: 16),

            sectionCard(children: [
              sectionHeader('Data Pemohon'),
              const SizedBox(height: 16),

              fieldLabel('Nama Lengkap', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
                validator: (v) => validateRequired(v, 'Nama lengkap'),
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

              fieldLabel('Tempat Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tempatCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
                validator: (v) => validateRequired(v, 'Tempat lahir'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Tanggal Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tglCtrl,
                readOnly: true,
                onTap: () => pickDate(context, _tglCtrl),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'dd/mm/yyyy',
                  suffixIcon: Icon(Icons.calendar_today,
                      size: 16, color: AppTheme.textSecondary),
                ),
                validator: (v) => validateDate(v, 'Tanggal lahir'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Jenis Kelamin', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _jenisKelamin,
                decoration: dropdownDeco('Pilih jenis kelamin'),
                items: kJenisKelaminList
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: GoogleFonts.poppins(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _jenisKelamin = v),
                validator: (v) => v == null ? 'Jenis kelamin wajib dipilih' : null,
              ),
              const SizedBox(height: 14),

              fieldLabel('Agama', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _agama,
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

              fieldLabel('Alamat', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _alamatCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan alamat'),
                validator: (v) => validateRequired(v, 'Alamat'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Keperluan', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _keperluanCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Masukkan keperluan surat keterangan'),
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
