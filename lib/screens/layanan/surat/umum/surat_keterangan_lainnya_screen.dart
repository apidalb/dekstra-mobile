import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class SuratKeteranganLainnyaScreen extends StatefulWidget {
  const SuratKeteranganLainnyaScreen({super.key});
  @override
  State<SuratKeteranganLainnyaScreen> createState() => _SKLainnyaState();
}

class _SKLainnyaState extends State<SuratKeteranganLainnyaScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();

  // Data Pemohon
  final _nikCtrl       = TextEditingController();
  final _namaCtrl      = TextEditingController();
  final _tempatCtrl    = TextEditingController();
  final _tglCtrl       = TextEditingController();
  String? _jk;
  String? _agama;
  final _pekerjaanCtrl = TextEditingController();
  final _alamatCtrl    = TextEditingController();

  // Keterangan Surat
  final _keperluanCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [_nikCtrl, _namaCtrl, _tempatCtrl, _tglCtrl,
      _pekerjaanCtrl, _alamatCtrl, _keperluanCtrl]) { c.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async => {
    'nik'          : _nikCtrl.text,
    'nama_lengkap' : _namaCtrl.text,
    'tempat_lahir' : _tempatCtrl.text,
    'tanggal_lahir': ddmmyyyyToIso(_tglCtrl.text),
    'jenis_kelamin': _jk,
    'agama'        : _agama,
    'pekerjaan'    : _pekerjaanCtrl.text,
    'alamat'       : _alamatCtrl.text,
    'keperluan'    : _keperluanCtrl.text,
  };

  Widget _buildDataPemohon() => Form(
    key: _fk1,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data Pemohon'),
        const SizedBox(height: 16),
        fieldLabel('NIK', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _nikCtrl,
          keyboardType: TextInputType.number, inputFormatters: nikFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
          validator: validateNIK),
        const SizedBox(height: 14),
        fieldLabel('Nama Lengkap', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
          validator: (v) => validateRequired(v, 'Nama lengkap')),
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
        DropdownButtonFormField<String>(initialValue: _jk,
          decoration: dropdownDeco('Pilih jenis kelamin'),
          items: kJenisKelaminList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _jk = v),
          validator: (v) => v == null ? 'Jenis kelamin wajib dipilih' : null),
        const SizedBox(height: 14),
        fieldLabel('Agama', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _agama,
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
        fieldLabel('Alamat', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _alamatCtrl, maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan alamat'),
          validator: (v) => validateRequired(v, 'Alamat')),
      ]),
    ]),
  );

  Widget _buildKeteranganSurat() => Form(
    key: _fk2,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Keterangan Surat'),
        const SizedBox(height: 16),
        fieldLabel('Tujuan Surat', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _keperluanCtrl, maxLines: 4,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(
              hintText: 'Jelaskan keperluan pembuatan surat keterangan ini'),
          validator: (v) => validateRequired(v, 'Tujuan surat')),
      ]),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Surat Keterangan Lainnya',
    dataSteps: [
      SuratDataStep(title: 'Data Pemohon',    formKey: _fk1, content: _buildDataPemohon()),
      SuratDataStep(title: 'Keterangan Surat', formKey: _fk2, content: _buildKeteranganSurat()),
    ],
    jenisSurat: 'A08',
    onBuildPayload: _buildPayload,
  );
}
