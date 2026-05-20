import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../form_surat_helpers.dart';

// ════════════════════════════════════════════════════════════════════════════
// B04 — Formulir Permohonan Perubahan KK WNI (F-1.16)
// ════════════════════════════════════════════════════════════════════════════
class FormulirPerubahanKkScreen extends StatefulWidget {
  const FormulirPerubahanKkScreen({super.key});
  @override
  State<FormulirPerubahanKkScreen> createState() => _PerubahanKkState();
}

class _PerubahanKkState extends State<FormulirPerubahanKkScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();
  final _fk3 = GlobalKey<FormState>();
  final _fk4 = GlobalKey<FormState>();
  final _fk5 = GlobalKey<FormState>();

  // Wilayah
  final _provCtrl = TextEditingController();
  final _kabCtrl  = TextEditingController();
  final _kecCtrl  = TextEditingController();
  final _desaCtrl = TextEditingController();

  // Pemohon
  final _namaPemCtrl  = TextEditingController();
  final _nikPemCtrl   = TextEditingController();
  final _noTelpCtrl   = TextEditingController();

  // KK Diikuti
  final _namaKepDCtrl = TextEditingController();
  final _noKkDCtrl    = TextEditingController();
  final _alamatDCtrl  = TextEditingController();
  final _rtDCtrl      = TextEditingController();
  final _rwDCtrl      = TextEditingController();
  final _desaDCtrl    = TextEditingController();
  final _kecDCtrl     = TextEditingController();
  final _kabDCtrl     = TextEditingController();
  final _provDCtrl    = TextEditingController();
  final _kodeDCtrl    = TextEditingController();

  // KK Lama
  final _namaKepLCtrl = TextEditingController();
  final _noKkLCtrl    = TextEditingController();
  final _alamatLCtrl  = TextEditingController();
  final _rtLCtrl      = TextEditingController();
  final _rwLCtrl      = TextEditingController();
  final _desaLCtrl    = TextEditingController();
  final _kecLCtrl     = TextEditingController();
  final _kabLCtrl     = TextEditingController();
  final _provLCtrl    = TextEditingController();
  final _kodeLCtrl    = TextEditingController();

  // Keterangan
  String? _alasan;
  final _jumlahCtrl = TextEditingController();

  // Anggota
  final List<AnggotaKK> _anggota = [AnggotaKK()];

  @override
  void dispose() {
    for (final c in [_provCtrl, _kabCtrl, _kecCtrl, _desaCtrl,
      _namaPemCtrl, _nikPemCtrl, _noTelpCtrl,
      _namaKepDCtrl, _noKkDCtrl, _alamatDCtrl, _rtDCtrl, _rwDCtrl,
      _desaDCtrl, _kecDCtrl, _kabDCtrl, _provDCtrl, _kodeDCtrl,
      _namaKepLCtrl, _noKkLCtrl, _alamatLCtrl, _rtLCtrl, _rwLCtrl,
      _desaLCtrl, _kecLCtrl, _kabLCtrl, _provLCtrl, _kodeLCtrl,
      _jumlahCtrl]) { c.dispose(); }
    for (final a in _anggota) { a.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async => {
    'nama_provinsi'           : _provCtrl.text,
    'nama_kabupaten_kota'     : _kabCtrl.text,
    'nama_kecamatan'          : _kecCtrl.text,
    'nama_kelurahan_desa'     : _desaCtrl.text,
    'nama_lengkap'            : _namaPemCtrl.text,
    'nik'                     : _nikPemCtrl.text,
    'nomor_telepon'           : _noTelpCtrl.text,
    'nama_kepala_keluarga'    : _namaKepDCtrl.text,
    'nomor_kk'                : _noKkDCtrl.text,
    'alamat'                  : _alamatDCtrl.text,
    'rt'                      : _rtDCtrl.text,
    'rw'                      : _rwDCtrl.text,
    'desa_kelurahan'          : _desaDCtrl.text,
    'kecamatan'               : _kecDCtrl.text,
    'kabupaten_kota'          : _kabDCtrl.text,
    'provinsi'                : _provDCtrl.text,
    'kode_pos'                : _kodeDCtrl.text,
    'nama_kepala_keluarga_lama': _namaKepLCtrl.text,
    'nomor_kk_lama'           : _noKkLCtrl.text,
    'alamat_lama'             : _alamatLCtrl.text,
    'rt_lama'                 : _rtLCtrl.text,
    'rw_lama'                 : _rwLCtrl.text,
    'desa_kelurahan_lama'     : _desaLCtrl.text,
    'kecamatan_lama'          : _kecLCtrl.text,
    'kabupaten_kota_lama'     : _kabLCtrl.text,
    'provinsi_lama'           : _provLCtrl.text,
    'kode_pos_lama'           : _kodeLCtrl.text,
    'alasan_permohonan'       : _alasan,
    'jumlah_anggota_keluarga' : _jumlahCtrl.text,
    'anggota_keluraga'        : _anggota.map((a) => {
      'anggota_nik'                    : a.nikCtrl.text,
      'anggota_nama_lengkap'           : a.namaCtrl.text,
      'anggota_status_hubungan_keluarga': a.shdk,
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
        fieldLabel('Nama Lengkap Pemohon', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaPemCtrl, style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama lengkap sesuai KTP'),
          validator: (v) => validateRequired(v, 'Nama')),
        const SizedBox(height: 14),
        fieldLabel('NIK Pemohon', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _nikPemCtrl,
          keyboardType: TextInputType.number, inputFormatters: nikFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
          validator: validateNIK),
        const SizedBox(height: 14),
        fieldLabel('Nomor Telepon', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _noTelpCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: angkaFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 081234567890'),
          validator: validatePhone),
      ]),
    ]),
  );

  Widget _buildKkDiikuti() => Form(
    key: _fk3,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data KK yang Diikuti'),
        const SizedBox(height: 16),
        fieldLabel('Nama Kepala Keluarga'),
        const SizedBox(height: 6),
        TextFormField(controller: _namaKepDCtrl, style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(
              hintText: 'Nama kepala keluarga yang diikuti')),
        const SizedBox(height: 14),
        fieldLabel('Nomor KK', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _noKkDCtrl,
          keyboardType: TextInputType.number, inputFormatters: nikFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Nomor KK yang diikuti'),
          validator: (v) {
            if (v == null || v.isEmpty) return 'No. KK wajib diisi';
            if (v.length != 16) return 'No. KK harus 16 digit';
            return null;
          }),
        const SizedBox(height: 14),
        ...buildAlamatBlock(
          alamat: _alamatDCtrl, rt: _rtDCtrl, rw: _rwDCtrl,
          desa: _desaDCtrl, kec: _kecDCtrl, kab: _kabDCtrl,
          prov: _provDCtrl, kodePos: _kodeDCtrl),
      ]),
    ]),
  );

  Widget _buildKkLama() => Form(
    key: _fk4,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data KK Lama'),
        const SizedBox(height: 16),
        fieldLabel('Nama Kepala Keluarga Lama'),
        const SizedBox(height: 6),
        TextFormField(controller: _namaKepLCtrl, style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(
              hintText: 'Nama kepala keluarga yang lama')),
        const SizedBox(height: 14),
        fieldLabel('Nomor KK Lama', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _noKkLCtrl,
          keyboardType: TextInputType.number, inputFormatters: nikFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Nomor KK yang lama'),
          validator: (v) {
            if (v == null || v.isEmpty) return 'No. KK lama wajib diisi';
            if (v.length != 16) return 'No. KK harus 16 digit';
            return null;
          }),
        const SizedBox(height: 14),
        ...buildAlamatBlock(
          alamat: _alamatLCtrl, rt: _rtLCtrl, rw: _rwLCtrl,
          desa: _desaLCtrl, kec: _kecLCtrl, kab: _kabLCtrl,
          prov: _provLCtrl, kodePos: _kodeLCtrl),
      ]),
    ]),
  );

  Widget _buildKeteranganAnggota() => Form(
    key: _fk5,
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
          validator: (v) => validateNonZeroInt(v, 'Jumlah anggota')),
      ]),
      const SizedBox(height: 16),
      buildTabelAnggota(_anggota, setState),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Formulir Perubahan KK',
    dataSteps: [
      SuratDataStep(title: 'Data Wilayah',   formKey: _fk1, content: _buildDataWilayahStep()),
      SuratDataStep(title: 'Data Pemohon',   formKey: _fk2, content: _buildDataPemohon()),
      SuratDataStep(title: 'KK Diikuti',     formKey: _fk3, content: _buildKkDiikuti()),
      SuratDataStep(title: 'KK Lama',        formKey: _fk4, content: _buildKkLama()),
      SuratDataStep(title: 'Keterangan',     formKey: _fk5, content: _buildKeteranganAnggota()),
    ],
    jenisSurat: 'B04',
    onBuildPayload: _buildPayload,
  );
}
