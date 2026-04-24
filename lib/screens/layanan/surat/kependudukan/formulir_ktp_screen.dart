import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../form_surat_helpers.dart';

const _jenisKtpList = [
  'KTP Baru', 'Perpanjangan KTP', 'KTP Hilang', 'KTP Rusak', 'KTP Luar Domisili',
];

// ════════════════════════════════════════════════════════════════════════════
// B05 — Formulir Permohonan KTP (F-1.21)
// ════════════════════════════════════════════════════════════════════════════
class FormulirKtpScreen extends StatefulWidget {
  const FormulirKtpScreen({super.key});
  @override
  State<FormulirKtpScreen> createState() => _KtpState();
}

class _KtpState extends State<FormulirKtpScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();
  final _fk3 = GlobalKey<FormState>();

  // Wilayah
  final _provCtrl  = TextEditingController();
  final _kabCtrl   = TextEditingController();
  final _kecCtrl   = TextEditingController();
  final _desaCtrl  = TextEditingController();

  // Jenis KTP
  String? _jenisKtp;

  // Pemohon
  final _namaCtrl   = TextEditingController();
  final _nikCtrl    = TextEditingController();
  final _noKkCtrl   = TextEditingController();
  final _noTelpCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _rtCtrl     = TextEditingController();
  final _rwCtrl     = TextEditingController();
  final _kodeCtrl   = TextEditingController();

  @override
  void dispose() {
    for (final c in [_provCtrl, _kabCtrl, _kecCtrl, _desaCtrl, _namaCtrl,
      _nikCtrl, _noKkCtrl, _noTelpCtrl, _alamatCtrl, _rtCtrl, _rwCtrl,
      _kodeCtrl]) { c.dispose(); }
    super.dispose();
  }

  // mapping label → nilai backend untuk jenis_permohonan_ktp
  static const _jenisKtpMap = {
    'KTP Baru'         : 'baru',
    'Perpanjangan KTP' : 'perpanjangan',
    'KTP Hilang'       : 'penggantian',
    'KTP Rusak'        : 'penggantian',
    'KTP Luar Domisili': 'baru',
  };

  Future<Map<String, dynamic>> _buildPayload() async => {
    'nama_provinsi'       : _provCtrl.text,
    'nama_kabupaten_kota' : _kabCtrl.text,
    'nama_kecamatan'      : _kecCtrl.text,
    'nama_kelurahan_desa' : _desaCtrl.text,
    'jenis_permohonan_ktp': _jenisKtpMap[_jenisKtp] ?? 'baru',
    'nama_lengkap'        : _namaCtrl.text,
    'nik'                 : _nikCtrl.text,
    'nomor_kk'            : _noKkCtrl.text,
    'nomor_telepon'       : _noTelpCtrl.text,
    'alamat'              : _alamatCtrl.text,
    'rt'                  : _rtCtrl.text,
    'rw'                  : _rwCtrl.text,
    'kode_pos'            : _kodeCtrl.text,
  };

  Widget _buildDataWilayahStep() => Form(
    key: _fk1,
    child: Column(children: [
      buildDataWilayah(provinsi: _provCtrl, kabKota: _kabCtrl,
          kecamatan: _kecCtrl, desa: _desaCtrl),
    ]),
  );

  Widget _buildJenisKtp() => Form(
    key: _fk2,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Jenis Permohonan KTP'),
        const SizedBox(height: 16),
        fieldLabel('Permohonan KTP', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _jenisKtp,
          decoration: dropdownDeco('Pilih jenis permohonan KTP'),
          items: _jenisKtpList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _jenisKtp = v),
          validator: (v) => v == null ? 'Jenis permohonan wajib dipilih' : null),
      ]),
    ]),
  );

  Widget _buildDataPemohon() => Form(
    key: _fk3,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data Pemohon'),
        const SizedBox(height: 16),
        fieldLabel('Nama Lengkap', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaCtrl, style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
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
        fieldLabel('No. KK', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _noKkCtrl,
          keyboardType: TextInputType.number, inputFormatters: nikFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan 16 digit Nomor KK'),
          validator: (v) {
            if (v == null || v.isEmpty) return 'No. KK wajib diisi';
            if (v.length != 16) return 'No. KK harus 16 digit';
            return null;
          }),
        const SizedBox(height: 14),
        fieldLabel('No. Telepon', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _noTelpCtrl, keyboardType: TextInputType.phone,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 081234567890'),
          validator: validatePhone),
        const SizedBox(height: 14),
        fieldLabel('Alamat Pemohon', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _alamatCtrl, maxLines: 2,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan alamat pemohon'),
          validator: (v) => validateRequired(v, 'Alamat')),
        const SizedBox(height: 14),
        fieldLabel('RT', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _rtCtrl, keyboardType: TextInputType.number,
          inputFormatters: angkaFormatters, style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 001'),
          validator: (v) => validateRequired(v, 'RT')),
        const SizedBox(height: 14),
        fieldLabel('RW', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _rwCtrl, keyboardType: TextInputType.number,
          inputFormatters: angkaFormatters, style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 002'),
          validator: (v) => validateRequired(v, 'RW')),
        const SizedBox(height: 14),
        fieldLabel('Kode Pos', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _kodeCtrl, keyboardType: TextInputType.number,
          inputFormatters: kodePosFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 50271'),
          validator: (v) => validateRequired(v, 'Kode Pos')),
      ]),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Formulir Permohonan KTP',
    dataSteps: [
      SuratDataStep(title: 'Data Wilayah',    formKey: _fk1, content: _buildDataWilayahStep()),
      SuratDataStep(title: 'Jenis KTP',       formKey: _fk2, content: _buildJenisKtp()),
      SuratDataStep(title: 'Data Pemohon',    formKey: _fk3, content: _buildDataPemohon()),
    ],
    jenisSurat: 'B05',
    onBuildPayload: _buildPayload,
  );
}
