import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../form_surat_helpers.dart';

class SuratKeteranganKematianScreen extends StatefulWidget {
  const SuratKeteranganKematianScreen({super.key});
  @override
  State<SuratKeteranganKematianScreen> createState() => _KematianState();
}

class _KematianState extends State<SuratKeteranganKematianScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();
  final _fk3 = GlobalKey<FormState>();

  // Data Almarhum/ah (Jenazah)
  final _namaCtrl          = TextEditingController();
  final _nikCtrl           = TextEditingController();
  final _tempatCtrl        = TextEditingController();
  final _tglLahirCtrl      = TextEditingController();
  String? _agama;
  final _pekerjaanCtrl     = TextEditingController();
  String? _kwrg;
  final _alamatCtrl        = TextEditingController();

  // Data Kematian
  final _tglMeninggalCtrl    = TextEditingController();
  final _tempatMeninggalCtrl = TextEditingController();

  // Data Pengaju
  String? _statusHub;
  final _namaPengajuCtrl      = TextEditingController();
  final _nikPengajuCtrl       = TextEditingController();
  final _tempatPengajuCtrl    = TextEditingController();
  final _tglPengajuCtrl       = TextEditingController();
  String? _agamaPengaju;
  final _pekerjaanPengajuCtrl = TextEditingController();
  String? _kwrgPengaju;
  final _alamatPengajuCtrl    = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _namaCtrl, _nikCtrl, _tempatCtrl, _tglLahirCtrl,
      _pekerjaanCtrl, _alamatCtrl, _tglMeninggalCtrl, _tempatMeninggalCtrl,
      _namaPengajuCtrl, _nikPengajuCtrl, _tempatPengajuCtrl,
      _tglPengajuCtrl, _pekerjaanPengajuCtrl, _alamatPengajuCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async => {
    'nama_lengkap'          : _namaCtrl.text,
    'nik'                   : _nikCtrl.text,
    'tempat_lahir'          : _tempatCtrl.text,
    'tanggal_lahir'         : ddmmyyyyToIso(_tglLahirCtrl.text),
    'agama'                 : _agama,
    'pekerjaan'             : _pekerjaanCtrl.text,
    'kewarganegaraan'       : _kwrg,
    'alamat'                : _alamatCtrl.text,
    'tanggal_meninggal'     : ddmmyyyyToIso(_tglMeninggalCtrl.text),
    'tempat_meninggal'      : _tempatMeninggalCtrl.text,
    'status_hubungan'       : _statusHub,
    'nama_pengaju'          : _namaPengajuCtrl.text,
    'nik_pengaju'           : _nikPengajuCtrl.text,
    'tempat_lahir_pengaju'  : _tempatPengajuCtrl.text,
    'tanggal_lahir_pengaju' : ddmmyyyyToIso(_tglPengajuCtrl.text),
    'agama_pengaju'         : _agamaPengaju,
    'pekerjaan_pengaju'     : _pekerjaanPengajuCtrl.text,
    'kewarganegaraan_pengaju': _kwrgPengaju,
    'alamat_pengaju'        : _alamatPengajuCtrl.text,
  };

  Widget _buildDataJenazah() => Form(
    key: _fk1,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data Almarhum / Almarhumah'),
        const SizedBox(height: 16),
        fieldLabel('Nama Lengkap', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama almarhum/ah'),
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
        fieldLabel('Tempat Lahir', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tempatCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
          validator: (v) => validateRequired(v, 'Tempat lahir')),
        const SizedBox(height: 14),
        fieldLabel('Tanggal Lahir', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tglLahirCtrl, readOnly: true,
          onTap: () => pickDate(context, _tglLahirCtrl),
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
              suffixIcon: Icon(Icons.calendar_today, size: 16)),
          validator: (v) => validateDate(v, 'Tanggal lahir')),
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
        fieldLabel('Kewarganegaraan', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _kwrg,
          decoration: dropdownDeco('Pilih kewarganegaraan'),
          items: kKewarganegaraanList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _kwrg = v),
          validator: (v) => v == null ? 'Kewarganegaraan wajib dipilih' : null),
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

  Widget _buildDataKematian() => Form(
    key: _fk2,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data Kematian'),
        const SizedBox(height: 16),
        fieldLabel('Tanggal Meninggal', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tglMeninggalCtrl, readOnly: true,
          onTap: () => pickDate(context, _tglMeninggalCtrl),
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
              suffixIcon: Icon(Icons.calendar_today, size: 16)),
          validator: (v) => validateDate(v, 'Tanggal meninggal')),
        const SizedBox(height: 14),
        fieldLabel('Tempat Meninggal', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tempatMeninggalCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: RS Umum, rumah'),
          validator: (v) => validateRequired(v, 'Tempat meninggal')),
      ]),
    ]),
  );

  Widget _buildDataPengaju() => Form(
    key: _fk3,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data Pengaju'),
        const SizedBox(height: 16),
        fieldLabel('Status Hubungan dengan Almarhum/ah', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _statusHub,
          decoration: dropdownDeco('Pilih status hubungan'),
          items: kStatusHubunganKematianList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _statusHub = v),
          validator: (v) => v == null ? 'Status hubungan wajib dipilih' : null),
        const SizedBox(height: 14),
        fieldLabel('Nama Lengkap', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaPengajuCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama pengaju'),
          validator: (v) => validateRequired(v, 'Nama pengaju')),
        const SizedBox(height: 14),
        fieldLabel('NIK', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _nikPengajuCtrl,
          keyboardType: TextInputType.number, inputFormatters: nikFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
          validator: validateNIK),
        const SizedBox(height: 14),
        fieldLabel('Tempat Lahir', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tempatPengajuCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
          validator: (v) => validateRequired(v, 'Tempat lahir')),
        const SizedBox(height: 14),
        fieldLabel('Tanggal Lahir', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tglPengajuCtrl, readOnly: true,
          onTap: () => pickDate(context, _tglPengajuCtrl),
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
              suffixIcon: Icon(Icons.calendar_today, size: 16)),
          validator: (v) => validateDate(v, 'Tanggal lahir')),
        const SizedBox(height: 14),
        fieldLabel('Agama', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _agamaPengaju,
          decoration: dropdownDeco('Pilih agama'),
          items: kAgamaList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _agamaPengaju = v),
          validator: (v) => v == null ? 'Agama wajib dipilih' : null),
        const SizedBox(height: 14),
        fieldLabel('Pekerjaan', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _pekerjaanPengajuCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan pekerjaan'),
          validator: (v) => validateRequired(v, 'Pekerjaan')),
        const SizedBox(height: 14),
        fieldLabel('Kewarganegaraan', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _kwrgPengaju,
          decoration: dropdownDeco('Pilih kewarganegaraan'),
          items: kKewarganegaraanList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _kwrgPengaju = v),
          validator: (v) => v == null ? 'Kewarganegaraan wajib dipilih' : null),
        const SizedBox(height: 14),
        fieldLabel('Alamat', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _alamatPengajuCtrl, maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan alamat pengaju'),
          validator: (v) => validateRequired(v, 'Alamat')),
      ]),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Surat Ket. Kematian',
    dataSteps: [
      SuratDataStep(title: 'Data Jenazah',   formKey: _fk1, content: _buildDataJenazah()),
      SuratDataStep(title: 'Data Kematian',  formKey: _fk2, content: _buildDataKematian()),
      SuratDataStep(title: 'Data Pengaju',   formKey: _fk3, content: _buildDataPengaju()),
    ],
    jenisSurat: 'B11',
    onBuildPayload: _buildPayload,
  );
}
