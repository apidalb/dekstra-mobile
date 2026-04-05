import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class SuratKeteranganKelahiranScreen extends StatefulWidget {
  const SuratKeteranganKelahiranScreen({super.key});
  @override
  State<SuratKeteranganKelahiranScreen> createState() => _KelahiranState();
}

class _KelahiranState extends State<SuratKeteranganKelahiranScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Data Anak
  final _namaAnakCtrl   = TextEditingController();
  String? _jkAnak;
  final _tglLahirAnakCtrl = TextEditingController();
  final _waktuLahirCtrl = TextEditingController();
  final _tempatLahirAnakCtrl = TextEditingController();
  final _anakKeCtrl     = TextEditingController();

  // Data Ayah
  final _namaAyahCtrl  = TextEditingController();
  final _nikAyahCtrl   = TextEditingController();
  final _tempatAyahCtrl = TextEditingController();
  final _tglAyahCtrl   = TextEditingController();
  String? _agamaAyah;
  final _pekerjaanAyahCtrl = TextEditingController();
  final _kwrgAyahCtrl  = TextEditingController(text: 'WNI');
  final _alamatAyahCtrl = TextEditingController();

  // Data Ibu
  final _namaIbuCtrl   = TextEditingController();
  final _nikIbuCtrl    = TextEditingController();
  final _tempatIbuCtrl = TextEditingController();
  final _tglIbuCtrl    = TextEditingController();
  String? _agamaIbu;
  final _pekerjaanIbuCtrl = TextEditingController();
  final _kwrgIbuCtrl   = TextEditingController(text: 'WNI');
  final _alamatIbuCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _namaAnakCtrl, _tglLahirAnakCtrl, _waktuLahirCtrl, _tempatLahirAnakCtrl, _anakKeCtrl,
      _namaAyahCtrl, _nikAyahCtrl, _tempatAyahCtrl, _tglAyahCtrl,
      _pekerjaanAyahCtrl, _kwrgAyahCtrl, _alamatAyahCtrl,
      _namaIbuCtrl, _nikIbuCtrl, _tempatIbuCtrl, _tglIbuCtrl,
      _pekerjaanIbuCtrl, _kwrgIbuCtrl, _alamatIbuCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Surat Keterangan Kelahiran');
  }

  Widget _dataOrangTua(String title, {
    required TextEditingController nama, required TextEditingController nik,
    required TextEditingController tempat, required TextEditingController tgl,
    required String? agama, required ValueChanged<String?> onAgama,
    required TextEditingController pekerjaan,
    required TextEditingController kwrg, required TextEditingController alamat,
  }) {
    return sectionCard(children: [
      sectionHeader(title),
      const SizedBox(height: 16),

      fieldLabel('Nama Lengkap', required: true),
      const SizedBox(height: 6),
      TextFormField(controller: nama, style: GoogleFonts.poppins(fontSize: 13),
        decoration: InputDecoration(hintText: 'Masukkan nama $title'),
        validator: (v) => validateRequired(v, 'Nama')),
      const SizedBox(height: 14),

      fieldLabel('NIK', required: true),
      const SizedBox(height: 6),
      TextFormField(controller: nik, keyboardType: TextInputType.number,
        inputFormatters: nikFormatters, style: GoogleFonts.poppins(fontSize: 13),
        decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
        validator: validateNIK),
      const SizedBox(height: 14),

      fieldLabel('Tempat Lahir', required: true),
      const SizedBox(height: 6),
      TextFormField(controller: tempat, style: GoogleFonts.poppins(fontSize: 13),
        decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
        validator: (v) => validateRequired(v, 'Tempat lahir')),
      const SizedBox(height: 14),

      fieldLabel('Tanggal Lahir', required: true),
      const SizedBox(height: 6),
      TextFormField(controller: tgl, readOnly: true,
        onTap: () => pickDate(context, tgl),
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
            suffixIcon: Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary)),
        validator: (v) => validateDate(v, 'Tanggal lahir')),
      const SizedBox(height: 14),

      fieldLabel('Agama', required: true),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(value: agama,
        decoration: dropdownDeco('Pilih agama'),
        items: kAgamaList.map((e) => DropdownMenuItem(value: e,
            child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
        onChanged: onAgama,
        validator: (v) => v == null ? 'Agama wajib dipilih' : null),
      const SizedBox(height: 14),

      fieldLabel('Pekerjaan', required: true),
      const SizedBox(height: 6),
      TextFormField(controller: pekerjaan, style: GoogleFonts.poppins(fontSize: 13),
        decoration: const InputDecoration(hintText: 'Masukkan pekerjaan'),
        validator: (v) => validateRequired(v, 'Pekerjaan')),
      const SizedBox(height: 14),

      fieldLabel('Kewarganegaraan', required: true),
      const SizedBox(height: 6),
      TextFormField(controller: kwrg, style: GoogleFonts.poppins(fontSize: 13),
        decoration: const InputDecoration(hintText: 'Contoh: WNI'),
        validator: (v) => validateRequired(v, 'Kewarganegaraan')),
      const SizedBox(height: 14),

      fieldLabel('Alamat', required: true),
      const SizedBox(height: 6),
      TextFormField(controller: alamat, maxLines: 3,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: const InputDecoration(hintText: 'Masukkan alamat'),
        validator: (v) => validateRequired(v, 'Alamat')),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Surat Ket. Kelahiran'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            namaSuratCard('SURAT KETERANGAN KELAHIRAN'),
            const SizedBox(height: 16),

            // ── Data Anak ────────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Anak'),
              const SizedBox(height: 16),

              fieldLabel('Nama Anak', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _namaAnakCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama anak'),
                validator: (v) => validateRequired(v, 'Nama anak')),
              const SizedBox(height: 14),

              fieldLabel('Jenis Kelamin', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(value: _jkAnak,
                decoration: dropdownDeco('Pilih jenis kelamin'),
                items: kJenisKelaminList.map((e) => DropdownMenuItem(value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _jkAnak = v),
                validator: (v) => v == null ? 'Wajib dipilih' : null),
              const SizedBox(height: 14),

              fieldLabel('Tempat Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _tempatLahirAnakCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan tempat lahir anak'),
                validator: (v) => validateRequired(v, 'Tempat lahir')),
              const SizedBox(height: 14),

              fieldLabel('Tanggal Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _tglLahirAnakCtrl, readOnly: true,
                onTap: () => pickDate(context, _tglLahirAnakCtrl),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
                    suffixIcon: Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary)),
                validator: (v) => validateDate(v, 'Tanggal lahir')),
              const SizedBox(height: 14),

              fieldLabel('Waktu Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _waktuLahirCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: 08:30 WIB'),
                validator: (v) => validateRequired(v, 'Waktu lahir')),
              const SizedBox(height: 14),

              fieldLabel('Anak ke-', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _anakKeCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2)],
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: 1, 2, 3'),
                validator: (v) => validateRequired(v, 'Anak ke-')),
            ]),
            const SizedBox(height: 16),

            _dataOrangTua('Data Ayah',
              nama: _namaAyahCtrl, nik: _nikAyahCtrl,
              tempat: _tempatAyahCtrl, tgl: _tglAyahCtrl,
              agama: _agamaAyah, onAgama: (v) => setState(() => _agamaAyah = v),
              pekerjaan: _pekerjaanAyahCtrl, kwrg: _kwrgAyahCtrl, alamat: _alamatAyahCtrl),
            const SizedBox(height: 16),

            _dataOrangTua('Data Ibu',
              nama: _namaIbuCtrl, nik: _nikIbuCtrl,
              tempat: _tempatIbuCtrl, tgl: _tglIbuCtrl,
              agama: _agamaIbu, onAgama: (v) => setState(() => _agamaIbu = v),
              pekerjaan: _pekerjaanIbuCtrl, kwrg: _kwrgIbuCtrl, alamat: _alamatIbuCtrl),
            const SizedBox(height: 24),

            bottomButtons(onBack: () => Navigator.pop(context),
                onSubmit: _submit, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
