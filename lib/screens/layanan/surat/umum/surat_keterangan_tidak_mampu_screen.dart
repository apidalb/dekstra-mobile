import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class SuratKeteranganTidakMampuScreen extends StatefulWidget {
  const SuratKeteranganTidakMampuScreen({super.key});
  @override
  State<SuratKeteranganTidakMampuScreen> createState() => _SKTMState();
}

class _SKTMState extends State<SuratKeteranganTidakMampuScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();

  // Data Orang Tua (step 1 — sesuai web)
  final _namaOrtuCtrl    = TextEditingController();
  final _tempatOrtuCtrl  = TextEditingController();
  final _tglOrtuCtrl     = TextEditingController();
  final _kwrgCtrl        = TextEditingController(text: 'WNI');
  String? _agama;
  final _pekerjaanCtrl   = TextEditingController();
  final _penghasilanCtrl = TextEditingController();
  final _keperluanCtrl   = TextEditingController();

  // Data Anak (step 2)
  final _namaAnakCtrl  = TextEditingController();
  final _tempatAnakCtrl = TextEditingController();
  final _tglAnakCtrl   = TextEditingController();
  final _sekolahCtrl   = TextEditingController();
  final _kelasCtrl     = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _namaOrtuCtrl, _tempatOrtuCtrl, _tglOrtuCtrl, _kwrgCtrl,
      _pekerjaanCtrl, _penghasilanCtrl, _keperluanCtrl,
      _namaAnakCtrl, _tempatAnakCtrl, _tglAnakCtrl, _sekolahCtrl, _kelasCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async => {
    'nama_orang_tua'     : _namaOrtuCtrl.text,
    'tempat_lahir_ortu'  : _tempatOrtuCtrl.text,
    'tanggal_lahir_ortu' : ddmmyyyyToIso(_tglOrtuCtrl.text),
    'kewarganegaraan'    : _kwrgCtrl.text,
    'agama'              : _agama,
    'pekerjaan'          : _pekerjaanCtrl.text,
    'penghasilan'        : _penghasilanCtrl.text,
    'keperluan'          : _keperluanCtrl.text,
    'nama_anak'          : _namaAnakCtrl.text,
    'tempat_lahir_anak'  : _tempatAnakCtrl.text,
    'tanggal_lahir_anak' : ddmmyyyyToIso(_tglAnakCtrl.text),
    'asal_sekolah'       : _sekolahCtrl.text,
    'kelas'              : _kelasCtrl.text,
  };

  Widget _buildDataOrtu() => Form(
    key: _fk1,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data Orang Tua / Wali'),
        const SizedBox(height: 16),
        fieldLabel('Nama Orang Tua / Wali', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaOrtuCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama orang tua'),
          validator: (v) => validateRequired(v, 'Nama orang tua')),
        const SizedBox(height: 14),
        fieldLabel('Tempat Lahir', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tempatOrtuCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
          validator: (v) => validateRequired(v, 'Tempat lahir')),
        const SizedBox(height: 14),
        fieldLabel('Tanggal Lahir', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tglOrtuCtrl, readOnly: true,
          onTap: () => pickDate(context, _tglOrtuCtrl),
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
              suffixIcon: Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary)),
          validator: (v) => validateDate(v, 'Tanggal lahir')),
        const SizedBox(height: 14),
        fieldLabel('Kewarganegaraan', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _kwrgCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: WNI'),
          validator: (v) => validateRequired(v, 'Kewarganegaraan')),
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
        fieldLabel('Penghasilan per Bulan', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _penghasilanCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 1500000',
              prefixText: 'Rp ', prefixStyle: TextStyle(color: AppTheme.textPrimary)),
          validator: (v) => validateRequired(v, 'Penghasilan')),
        const SizedBox(height: 14),
        fieldLabel('Keperluan', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _keperluanCtrl, maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: Mengajukan beasiswa, pembebasan SPP'),
          validator: (v) => validateRequired(v, 'Keperluan')),
      ]),
    ]),
  );

  Widget _buildDataAnak() => Form(
    key: _fk2,
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
        fieldLabel('Tempat Lahir', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tempatAnakCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
          validator: (v) => validateRequired(v, 'Tempat lahir')),
        const SizedBox(height: 14),
        fieldLabel('Tanggal Lahir', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tglAnakCtrl, readOnly: true,
          onTap: () => pickDate(context, _tglAnakCtrl),
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
              suffixIcon: Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary)),
          validator: (v) => validateDate(v, 'Tanggal lahir')),
        const SizedBox(height: 14),
        fieldLabel('Asal Sekolah', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _sekolahCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: SDN 1 Gantiwarno'),
          validator: (v) => validateRequired(v, 'Asal sekolah')),
        const SizedBox(height: 14),
        fieldLabel('Kelas', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _kelasCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 5, VII, X IPA'),
          validator: (v) => validateRequired(v, 'Kelas')),
      ]),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'SKTM (Sekolah)',
    dataSteps: [
      SuratDataStep(title: 'Data Orang Tua', formKey: _fk1, content: _buildDataOrtu()),
      SuratDataStep(title: 'Data Anak',      formKey: _fk2, content: _buildDataAnak()),
    ],
    jenisSurat: 'A04',
    onBuildPayload: _buildPayload,
  );
}
