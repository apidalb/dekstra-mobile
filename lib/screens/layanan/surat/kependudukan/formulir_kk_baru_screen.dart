import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../form_surat_helpers.dart';

// ════════════════════════════════════════════════════════════════════════════
// B03 — Formulir Permohonan KK Baru WNI (F-1.15)
// ════════════════════════════════════════════════════════════════════════════
class FormulirKkBaruScreen extends StatefulWidget {
  const FormulirKkBaruScreen({super.key});
  @override
  State<FormulirKkBaruScreen> createState() => _KkBaruState();
}

class _KkBaruState extends State<FormulirKkBaruScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();
  final _fk3 = GlobalKey<FormState>();
  final _fk4 = GlobalKey<FormState>();

  // Wilayah
  final _provCtrl    = TextEditingController();
  final _kabCtrl     = TextEditingController();
  final _kecCtrl     = TextEditingController();
  final _desaCtrl    = TextEditingController();

  // Pemohon
  final _namaCtrl    = TextEditingController();
  final _nikCtrl     = TextEditingController();
  final _noKkSemCtrl = TextEditingController();
  final _noTelpCtrl  = TextEditingController();
  final _alamatCtrl  = TextEditingController();
  final _rtCtrl      = TextEditingController();
  final _rwCtrl      = TextEditingController();
  final _desaPemCtrl = TextEditingController();
  final _kecPemCtrl  = TextEditingController();
  final _kabPemCtrl  = TextEditingController();
  final _provPemCtrl = TextEditingController();
  final _kodeCtrl    = TextEditingController();

  // Keterangan
  String? _alasan;
  final _jumlahCtrl  = TextEditingController();

  // Anggota
  final List<AnggotaKK> _anggota = [AnggotaKK()];

  @override
  void dispose() {
    for (final c in [_provCtrl, _kabCtrl, _kecCtrl, _desaCtrl, _namaCtrl,
      _nikCtrl, _noKkSemCtrl, _noTelpCtrl, _alamatCtrl, _rtCtrl, _rwCtrl,
      _desaPemCtrl, _kecPemCtrl, _kabPemCtrl, _provPemCtrl, _kodeCtrl,
      _jumlahCtrl]) { c.dispose(); }
    for (final a in _anggota) { a.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async => {
    'nama_provinsi'        : _provCtrl.text,
    'nama_kabupaten_kota'  : _kabCtrl.text,
    'nama_kecamatan'       : _kecCtrl.text,
    'nama_kelurahan_desa'  : _desaCtrl.text,
    'nama_lengkap'         : _namaCtrl.text,
    'nik'                  : _nikCtrl.text,
    'nomor_kk_semula'      : _noKkSemCtrl.text,
    'nomor_telepon'        : _noTelpCtrl.text,
    'alamat'               : _alamatCtrl.text,
    'rt'                   : _rtCtrl.text,
    'rw'                   : _rwCtrl.text,
    'desa_kelurahan'       : _desaPemCtrl.text,
    'kecamatan'            : _kecPemCtrl.text,
    'kabupaten_kota'       : _kabPemCtrl.text,
    'provinsi'             : _provPemCtrl.text,
    'kode_pos'             : _kodeCtrl.text,
    'alasan_permohonan'    : _alasan,
    'jumlah_anggota_keluarga': _jumlahCtrl.text,
    'anggota_keluarga'     : _anggota.map((a) => {
      'nik'   : a.nikCtrl.text,
      'nama'  : a.namaCtrl.text,
      'status': a.shdk,
    }).toList(),
  };

  Widget _buildDataWilayahStep() => Form(
    key: _fk1,
    child: Column(children: [
      buildDataWilayah(provinsi: _provCtrl, kabKota: _kabCtrl,
          kecamatan: _kecCtrl, desa: _desaCtrl),
    ]),
  );

  Widget _buildDataPemohon() => Form(
    key: _fk2,
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
        fieldLabel('No. KK Semula'),
        const SizedBox(height: 6),
        TextFormField(controller: _noKkSemCtrl,
          keyboardType: TextInputType.number, inputFormatters: nikFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(
              hintText: 'Isi jika sebelumnya sudah memiliki KK')),
        const SizedBox(height: 14),
        fieldLabel('No. Telepon', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _noTelpCtrl, keyboardType: TextInputType.phone,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 081234567890'),
          validator: validatePhone),
        const SizedBox(height: 14),
        ...buildAlamatBlock(
          alamat: _alamatCtrl, rt: _rtCtrl, rw: _rwCtrl,
          desa: _desaPemCtrl, kec: _kecPemCtrl, kab: _kabPemCtrl,
          prov: _provPemCtrl, kodePos: _kodeCtrl),
      ]),
    ]),
  );

  Widget _buildKeterangan() => Form(
    key: _fk3,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Keterangan Permohonan'),
        const SizedBox(height: 16),
        fieldLabel('Alasan Permohonan', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _alasan,
          decoration: dropdownDeco('Pilih alasan permohonan'),
          items: kAlasanKkList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _alasan = v),
          validator: (v) => v == null ? 'Wajib dipilih' : null),
        const SizedBox(height: 14),
        fieldLabel('Jumlah Anggota Keluarga', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _jumlahCtrl,
          keyboardType: TextInputType.number, inputFormatters: angkaFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(
              hintText: 'Masukkan jumlah anggota keluarga', suffixText: 'Orang'),
          validator: (v) => validateRequired(v, 'Jumlah anggota')),
      ]),
    ]),
  );

  Widget _buildAnggotaKeluarga() => Form(
    key: _fk4,
    child: Column(children: [
      buildTabelAnggota(_anggota, setState),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Formulir KK Baru WNI',
    dataSteps: [
      SuratDataStep(title: 'Data Wilayah',    formKey: _fk1, content: _buildDataWilayahStep()),
      SuratDataStep(title: 'Data Pemohon',    formKey: _fk2, content: _buildDataPemohon()),
      SuratDataStep(title: 'Keterangan',      formKey: _fk3, content: _buildKeterangan()),
      SuratDataStep(title: 'Anggota Keluarga', formKey: _fk4, content: _buildAnggotaKeluarga()),
    ],
    jenisSurat: 'B03',
    onBuildPayload: _buildPayload,
  );
}
