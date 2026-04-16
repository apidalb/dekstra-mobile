import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class SuratPengantarBarangScreen extends StatefulWidget {
  const SuratPengantarBarangScreen({super.key});
  @override
  State<SuratPengantarBarangScreen> createState() => _SPBarangState();
}

class _SPBarangState extends State<SuratPengantarBarangScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();
  final _fk3 = GlobalKey<FormState>();

  // Pemilik Barang
  final _pNamaCtrl   = TextEditingController();
  final _pNikCtrl    = TextEditingController();
  final _pTempatCtrl = TextEditingController();
  final _pTglCtrl    = TextEditingController();
  String? _pJk;
  final _pPekCtrl    = TextEditingController();
  final _pAlamatCtrl = TextEditingController();

  // Pengantar Barang
  final _gNamaCtrl   = TextEditingController();
  final _gNikCtrl    = TextEditingController();
  final _gTempatCtrl = TextEditingController();
  final _gTglCtrl    = TextEditingController();
  String? _gJk;
  final _gPekCtrl    = TextEditingController();
  final _gAlamatCtrl = TextEditingController();

  // Data Barang & Kendaraan
  final _jenisBarangCtrl    = TextEditingController();
  final _jumlahBarangCtrl   = TextEditingController();
  final _jenisKendaraanCtrl = TextEditingController();
  final _nopolCtrl          = TextEditingController();
  final _supirCtrl          = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _pNamaCtrl, _pNikCtrl, _pTempatCtrl, _pTglCtrl, _pPekCtrl, _pAlamatCtrl,
      _gNamaCtrl, _gNikCtrl, _gTempatCtrl, _gTglCtrl, _gPekCtrl, _gAlamatCtrl,
      _jenisBarangCtrl, _jumlahBarangCtrl, _jenisKendaraanCtrl, _nopolCtrl, _supirCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async => {
    'pengirim_nama'          : _pNamaCtrl.text,
    'pengirim_nik'           : _pNikCtrl.text,
    'pengirim_tempat_lahir'  : _pTempatCtrl.text,
    'pengirim_tanggal_lahir' : ddmmyyyyToIso(_pTglCtrl.text),
    'pengirim_jenis_kelamin' : _pJk,
    'pengirim_pekerjaan'     : _pPekCtrl.text,
    'pengirim_alamat'        : _pAlamatCtrl.text,
    'penerima_nama'          : _gNamaCtrl.text,
    'penerima_nik'           : _gNikCtrl.text,
    'penerima_tempat_lahir'  : _gTempatCtrl.text,
    'penerima_tanggal_lahir' : ddmmyyyyToIso(_gTglCtrl.text),
    'penerima_jenis_kelamin' : _gJk,
    'penerima_pekerjaan'     : _gPekCtrl.text,
    'penerima_alamat'        : _gAlamatCtrl.text,
    'jenis_barang'           : _jenisBarangCtrl.text,
    'jumlah_barang'          : _jumlahBarangCtrl.text,
    'jenis_kendaraan'        : _jenisKendaraanCtrl.text,
    'nopol'                  : _nopolCtrl.text,
    'nama_supir'             : _supirCtrl.text,
  };

  Widget _buildPersonSection(String title,
      {required GlobalKey<FormState> fk,
      required TextEditingController nama,
      required TextEditingController nik,
      required TextEditingController tempat,
      required TextEditingController tgl,
      required String? jk,
      required ValueChanged<String?> onJKChanged,
      required TextEditingController pekerjaan,
      required TextEditingController alamat}) =>
      Form(
        key: fk,
        child: Column(children: [
          sectionCard(children: [
            sectionHeader(title),
            const SizedBox(height: 16),
            fieldLabel('Nama Lengkap', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: nama,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
              validator: (v) => validateRequired(v, 'Nama lengkap')),
            const SizedBox(height: 14),
            fieldLabel('NIK', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: nik,
              keyboardType: TextInputType.number, inputFormatters: nikFormatters,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
              validator: validateNIK),
            const SizedBox(height: 14),
            fieldLabel('Tempat Lahir', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: tempat,
              style: GoogleFonts.poppins(fontSize: 13),
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
            fieldLabel('Jenis Kelamin', required: true),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(initialValue: jk,
              decoration: dropdownDeco('Pilih jenis kelamin'),
              items: kJenisKelaminList.map((e) => DropdownMenuItem(value: e,
                  child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
              onChanged: onJKChanged,
              validator: (v) => v == null ? 'Jenis kelamin wajib dipilih' : null),
            const SizedBox(height: 14),
            fieldLabel('Pekerjaan', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: pekerjaan,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan pekerjaan'),
              validator: (v) => validateRequired(v, 'Pekerjaan')),
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

  Widget _buildDataBarang() => Form(
    key: _fk3,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data Barang & Kendaraan'),
        const SizedBox(height: 16),
        fieldLabel('Jenis Barang', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _jenisBarangCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan jenis barang'),
          validator: (v) => validateRequired(v, 'Jenis barang')),
        const SizedBox(height: 14),
        fieldLabel('Jumlah Barang', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _jumlahBarangCtrl,
          keyboardType: TextInputType.number, inputFormatters: angkaFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan jumlah barang'),
          validator: (v) => validateRequired(v, 'Jumlah barang')),
        const SizedBox(height: 14),
        fieldLabel('Jenis Kendaraan', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _jenisKendaraanCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: Truk, Pickup, Motor'),
          validator: (v) => validateRequired(v, 'Jenis kendaraan')),
        const SizedBox(height: 14),
        fieldLabel('Nomor Polisi', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _nopolCtrl,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: AB 1234 CD'),
          validator: (v) => validateRequired(v, 'Nomor polisi')),
        const SizedBox(height: 14),
        fieldLabel('Nama Supir', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _supirCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama supir'),
          validator: (v) => validateRequired(v, 'Nama supir')),
      ]),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Surat Pengantar Barang',
    dataSteps: [
      SuratDataStep(
        title: 'Pemilik Barang',
        formKey: _fk1,
        content: _buildPersonSection('Data Pemilik Barang',
          fk: _fk1,
          nama: _pNamaCtrl, nik: _pNikCtrl,
          tempat: _pTempatCtrl, tgl: _pTglCtrl,
          jk: _pJk, onJKChanged: (v) => setState(() => _pJk = v),
          pekerjaan: _pPekCtrl, alamat: _pAlamatCtrl),
      ),
      SuratDataStep(
        title: 'Pengantar Barang',
        formKey: _fk2,
        content: _buildPersonSection('Data Pengantar Barang',
          fk: _fk2,
          nama: _gNamaCtrl, nik: _gNikCtrl,
          tempat: _gTempatCtrl, tgl: _gTglCtrl,
          jk: _gJk, onJKChanged: (v) => setState(() => _gJk = v),
          pekerjaan: _gPekCtrl, alamat: _gAlamatCtrl),
      ),
      SuratDataStep(title: 'Data Barang', formKey: _fk3, content: _buildDataBarang()),
    ],
    jenisSurat: 'A03',
    onBuildPayload: _buildPayload,
  );
}
