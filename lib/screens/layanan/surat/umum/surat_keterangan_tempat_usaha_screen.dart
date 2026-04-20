import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../form_surat_helpers.dart';

class SuratKeteranganTempatUsahaScreen extends StatefulWidget {
  const SuratKeteranganTempatUsahaScreen({super.key});
  @override
  State<SuratKeteranganTempatUsahaScreen> createState() => _SKTempatUsahaState();
}

class _SKTempatUsahaState extends State<SuratKeteranganTempatUsahaScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();

  // Data Pemohon
  final _namaCtrl   = TextEditingController();
  final _nibCtrl    = TextEditingController();
  final _npwpCtrl   = TextEditingController();
  final _alamatCtrl = TextEditingController();

  // Data Usaha
  final _namaUsahaCtrl   = TextEditingController();
  final _jenisUsahaCtrl  = TextEditingController();
  final _alamatUsahaCtrl = TextEditingController();
  final _tujuanCtrl      = TextEditingController();

  @override
  void dispose() {
    for (final c in [_namaCtrl, _nibCtrl, _npwpCtrl, _alamatCtrl,
      _namaUsahaCtrl, _jenisUsahaCtrl, _alamatUsahaCtrl, _tujuanCtrl]) { c.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async => {
    'nama_lengkap'     : _namaCtrl.text,
    'nib'              : _nibCtrl.text,
    'npwp'             : _npwpCtrl.text,
    'alamat'           : _alamatCtrl.text,
    'nama_usaha'       : _namaUsahaCtrl.text,
    'jenis_usaha'      : _jenisUsahaCtrl.text,
    'alamat_usaha'     : _alamatUsahaCtrl.text,
    'tujuan_pengajuan' : _tujuanCtrl.text,
  };

  Widget _buildDataPemohon() => Form(
    key: _fk1,
    child: Column(children: [
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
        fieldLabel('NIB (Nomor Induk Berusaha)', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _nibCtrl,
          keyboardType: TextInputType.number,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan NIB'),
          validator: (v) => validateRequired(v, 'NIB')),
        const SizedBox(height: 14),
        fieldLabel('NPWP', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _npwpCtrl,
          keyboardType: TextInputType.number,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan NPWP'),
          validator: (v) => validateRequired(v, 'NPWP')),
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

  Widget _buildDataUsaha() => Form(
    key: _fk2,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data Usaha'),
        const SizedBox(height: 16),
        fieldLabel('Nama Usaha', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaUsahaCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama usaha'),
          validator: (v) => validateRequired(v, 'Nama usaha')),
        const SizedBox(height: 14),
        fieldLabel('Jenis Usaha', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _jenisUsahaCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: Perdagangan, Jasa, Industri'),
          validator: (v) => validateRequired(v, 'Jenis usaha')),
        const SizedBox(height: 14),
        fieldLabel('Alamat Usaha', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _alamatUsahaCtrl, maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan alamat usaha'),
          validator: (v) => validateRequired(v, 'Alamat usaha')),
        const SizedBox(height: 14),
        fieldLabel('Tujuan Pengajuan', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tujuanCtrl, maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan tujuan pengajuan'),
          validator: (v) => validateRequired(v, 'Tujuan pengajuan')),
      ]),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Surat Ket. Tempat Usaha',
    dataSteps: [
      SuratDataStep(title: 'Data Pemohon', formKey: _fk1, content: _buildDataPemohon()),
      SuratDataStep(title: 'Data Usaha',   formKey: _fk2, content: _buildDataUsaha()),
    ],
    jenisSurat: 'A02',
    onBuildPayload: _buildPayload,
  );
}
