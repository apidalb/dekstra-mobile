import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class SuratKeteranganDomisiliScreen extends StatefulWidget {
  const SuratKeteranganDomisiliScreen({super.key});
  @override
  State<SuratKeteranganDomisiliScreen> createState() => _DomisiliState();
}

class _DomisiliState extends State<SuratKeteranganDomisiliScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _namaCtrl     = TextEditingController();
  final _nikCtrl      = TextEditingController();
  final _tempatCtrl   = TextEditingController();
  final _tglCtrl      = TextEditingController();
  String? _jk;
  String? _agama;
  final _pekerjaanCtrl = TextEditingController();
  String? _status;
  final _kwrgCtrl     = TextEditingController(text: 'WNI');
  final _alamatCtrl   = TextEditingController();
  final _noKkCtrl     = TextEditingController();
  final _kepalaKkCtrl = TextEditingController();
  final _keperluanCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [_namaCtrl, _nikCtrl, _tempatCtrl, _tglCtrl,
      _pekerjaanCtrl, _kwrgCtrl, _alamatCtrl, _noKkCtrl,
      _kepalaKkCtrl, _keperluanCtrl]) { c.dispose(); }
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Surat Keterangan Domisili');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Surat Ket. Domisili'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            namaSuratCard('SURAT KETERANGAN DOMISILI'),
            const SizedBox(height: 16),

            sectionCard(children: [
              sectionHeader('Data Pemohon'),
              const SizedBox(height: 16),

              fieldLabel('Nama Lengkap', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _namaCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
                validator: (v) => validateRequired(v, 'Nama lengkap')),
              const SizedBox(height: 14),

              fieldLabel('NIK', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _nikCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: nikFormatters,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
                validator: validateNIK),
              const SizedBox(height: 14),

              fieldLabel('Tempat Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _tempatCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
                validator: (v) => validateRequired(v, 'Tempat lahir')),
              const SizedBox(height: 14),

              fieldLabel('Tanggal Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _tglCtrl, readOnly: true,
                onTap: () => pickDate(context, _tglCtrl),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
                    suffixIcon: Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary)),
                validator: (v) => validateDate(v, 'Tanggal lahir')),
              const SizedBox(height: 14),

              fieldLabel('Jenis Kelamin', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(value: _jk,
                decoration: dropdownDeco('Pilih jenis kelamin'),
                items: kJenisKelaminList.map((e) => DropdownMenuItem(value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _jk = v),
                validator: (v) => v == null ? 'Jenis kelamin wajib dipilih' : null),
              const SizedBox(height: 14),

              fieldLabel('Agama', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(value: _agama,
                decoration: dropdownDeco('Pilih agama'),
                items: kAgamaList.map((e) => DropdownMenuItem(value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _agama = v),
                validator: (v) => v == null ? 'Agama wajib dipilih' : null),
              const SizedBox(height: 14),

              fieldLabel('Pekerjaan', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _pekerjaanCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan pekerjaan'),
                validator: (v) => validateRequired(v, 'Pekerjaan')),
              const SizedBox(height: 14),

              fieldLabel('Status Pernikahan', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(value: _status,
                decoration: dropdownDeco('Pilih status pernikahan'),
                items: kStatusPernikahanList.map((e) => DropdownMenuItem(value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _status = v),
                validator: (v) => v == null ? 'Status wajib dipilih' : null),
              const SizedBox(height: 14),

              fieldLabel('Kewarganegaraan', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _kwrgCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: WNI'),
                validator: (v) => validateRequired(v, 'Kewarganegaraan')),
              const SizedBox(height: 14),

              fieldLabel('Alamat', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _alamatCtrl, maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan alamat lengkap'),
                validator: (v) => validateRequired(v, 'Alamat')),
              const SizedBox(height: 14),

              fieldLabel('Nomor Kartu Keluarga', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _noKkCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: nikFormatters,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan 16 digit No. KK'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'No. KK wajib diisi';
                  if (v.length != 16) return 'No. KK harus 16 digit';
                  return null;
                }),
              const SizedBox(height: 14),

              fieldLabel('Nama Kepala Keluarga', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _kepalaKkCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama kepala keluarga'),
                validator: (v) => validateRequired(v, 'Nama kepala keluarga')),
              const SizedBox(height: 14),

              fieldLabel('Keperluan', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _keperluanCtrl, maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan keperluan surat'),
                validator: (v) => validateRequired(v, 'Keperluan')),
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
