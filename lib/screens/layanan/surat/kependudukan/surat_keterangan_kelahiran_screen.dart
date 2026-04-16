import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../form_surat_helpers.dart';

class SuratKeteranganKelahiranScreen extends StatefulWidget {
  const SuratKeteranganKelahiranScreen({super.key});
  @override
  State<SuratKeteranganKelahiranScreen> createState() => _KelahiranState();
}

class _KelahiranState extends State<SuratKeteranganKelahiranScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();
  final _fk3 = GlobalKey<FormState>();

  // Data Anak
  final _namaAnakCtrl     = TextEditingController();
  String? _jkAnak;
  final _tglLahirAnakCtrl = TextEditingController();
  final _waktuLahirCtrl   = TextEditingController();
  final _anakKeCtrl       = TextEditingController();

  // Data Ayah
  final _namaAyahCtrl      = TextEditingController();
  final _nikAyahCtrl       = TextEditingController();
  final _tempatAyahCtrl    = TextEditingController();
  final _tglAyahCtrl       = TextEditingController();
  String? _agamaAyah;
  final _pekerjaanAyahCtrl = TextEditingController();
  String? _kwrgAyah;
  final _alamatAyahCtrl    = TextEditingController();

  // Data Ibu
  final _namaIbuCtrl      = TextEditingController();
  final _nikIbuCtrl       = TextEditingController();
  final _tempatIbuCtrl    = TextEditingController();
  final _tglIbuCtrl       = TextEditingController();
  String? _agamaIbu;
  final _pekerjaanIbuCtrl = TextEditingController();
  String? _kwrgIbu;
  final _alamatIbuCtrl    = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _namaAnakCtrl, _tglLahirAnakCtrl, _waktuLahirCtrl, _anakKeCtrl,
      _namaAyahCtrl, _nikAyahCtrl, _tempatAyahCtrl, _tglAyahCtrl,
      _pekerjaanAyahCtrl, _alamatAyahCtrl,
      _namaIbuCtrl, _nikIbuCtrl, _tempatIbuCtrl, _tglIbuCtrl,
      _pekerjaanIbuCtrl, _alamatIbuCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async => {
    'nama_anak'          : _namaAnakCtrl.text,
    'jenis_kelamin_anak' : _jkAnak,
    'tanggal_lahir_anak' : ddmmyyyyToIso(_tglLahirAnakCtrl.text),
    'waktu_lahir'        : _waktuLahirCtrl.text,
    'anak_ke'            : _anakKeCtrl.text,
    'nama_ayah'          : _namaAyahCtrl.text,
    'nik_ayah'           : _nikAyahCtrl.text,
    'tempat_lahir_ayah'  : _tempatAyahCtrl.text,
    'tanggal_lahir_ayah' : ddmmyyyyToIso(_tglAyahCtrl.text),
    'agama_ayah'         : _agamaAyah,
    'pekerjaan_ayah'     : _pekerjaanAyahCtrl.text,
    'kewarganegaraan_ayah': _kwrgAyah,
    'alamat_ayah'        : _alamatAyahCtrl.text,
    'nama_ibu'           : _namaIbuCtrl.text,
    'nik_ibu'            : _nikIbuCtrl.text,
    'tempat_lahir_ibu'   : _tempatIbuCtrl.text,
    'tanggal_lahir_ibu'  : ddmmyyyyToIso(_tglIbuCtrl.text),
    'agama_ibu'          : _agamaIbu,
    'pekerjaan_ibu'      : _pekerjaanIbuCtrl.text,
    'kewarganegaraan_ibu': _kwrgIbu,
    'alamat_ibu'         : _alamatIbuCtrl.text,
  };

  Widget _buildDataAnak() => Form(
    key: _fk1,
    child: Column(children: [
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
        DropdownButtonFormField<String>(initialValue: _jkAnak,
          decoration: dropdownDeco('Pilih jenis kelamin'),
          items: kJenisKelaminList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _jkAnak = v),
          validator: (v) => v == null ? 'Wajib dipilih' : null),
        const SizedBox(height: 14),
        fieldLabel('Tanggal Lahir', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tglLahirAnakCtrl, readOnly: true,
          onTap: () => pickDate(context, _tglLahirAnakCtrl),
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
              suffixIcon: Icon(Icons.calendar_today, size: 16)),
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
    ]),
  );

  Widget _buildOrangTuaStep(String title, GlobalKey<FormState> fk, {
    required TextEditingController nama, required TextEditingController nik,
    required TextEditingController tempat, required TextEditingController tgl,
    required String? agama, required ValueChanged<String?> onAgama,
    required TextEditingController pekerjaan,
    required String? kwrg, required ValueChanged<String?> onKwrg,
    required TextEditingController alamat,
  }) => Form(
    key: fk,
    child: Column(children: [
      sectionCard(children: [
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
              suffixIcon: Icon(Icons.calendar_today, size: 16)),
          validator: (v) => validateDate(v, 'Tanggal lahir')),
        const SizedBox(height: 14),
        fieldLabel('Agama', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: agama,
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
        DropdownButtonFormField<String>(initialValue: kwrg,
          decoration: dropdownDeco('Pilih kewarganegaraan'),
          items: kKewarganegaraanList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: onKwrg,
          validator: (v) => v == null ? 'Kewarganegaraan wajib dipilih' : null),
        const SizedBox(height: 14),
        fieldLabel('Alamat', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: alamat, maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan alamat'),
          validator: (v) => validateRequired(v, 'Alamat')),
      ]),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Surat Ket. Kelahiran',
    dataSteps: [
      SuratDataStep(title: 'Data Anak',
        formKey: _fk1, content: _buildDataAnak()),
      SuratDataStep(title: 'Data Ayah',
        formKey: _fk2, content: _buildOrangTuaStep('Data Ayah', _fk2,
          nama: _namaAyahCtrl, nik: _nikAyahCtrl,
          tempat: _tempatAyahCtrl, tgl: _tglAyahCtrl,
          agama: _agamaAyah, onAgama: (v) => setState(() => _agamaAyah = v),
          pekerjaan: _pekerjaanAyahCtrl,
          kwrg: _kwrgAyah, onKwrg: (v) => setState(() => _kwrgAyah = v),
          alamat: _alamatAyahCtrl)),
      SuratDataStep(title: 'Data Ibu',
        formKey: _fk3, content: _buildOrangTuaStep('Data Ibu', _fk3,
          nama: _namaIbuCtrl, nik: _nikIbuCtrl,
          tempat: _tempatIbuCtrl, tgl: _tglIbuCtrl,
          agama: _agamaIbu, onAgama: (v) => setState(() => _agamaIbu = v),
          pekerjaan: _pekerjaanIbuCtrl,
          kwrg: _kwrgIbu, onKwrg: (v) => setState(() => _kwrgIbu = v),
          alamat: _alamatIbuCtrl)),
    ],
    jenisSurat: 'B10',
    onBuildPayload: _buildPayload,
  );
}
