import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

const _persyaratanF102 = [
  'KK Lama / KK Rusak',
  'Buku Nikah / Kutipan Akta Perkawinan',
  'Kutipan Akta Perceraian',
  'Surat Keterangan Pindah',
  'Surat Keterangan Pindah Luar Negeri',
  'KTP-el Rusak',
  'Dokumen Perjalanan',
  'Surat Keterangan Hilang dari Kepolisian',
  'Surat Keterangan / Bukti Perubahan Peristiwa Kependudukan',
  'SPTJM Perkawinan / Perceraian Belum Tercatat',
  'Akta Kematian',
  'Surat Pernyataan Penyebab Terjadinya Hilang atau Rusak',
  'Surat Keterangan Pindah dari Perwakilan RI',
  'Surat Pernyataan Bersedia Menerima sebagai Anggota Keluarga',
  'Surat Kuasa Pengasuh Anak dari Orang Tua / Wali',
  'Kartu Izin Tinggal Tetap',
];

const _kategoriF102 = [
  'KK Baru', 'Perubahan Data KK', 'KK Hilang / Rusak',
  'KTP-el Baru', 'KTP-el Pindah Datang', 'KTP-el Hilang / Rusak',
  'KTP-el Perpanjangan ITAP', 'Kartu Identitas Anak (KIA) Baru',
  'KIA Hilang', 'KIA Rusak', 'Perubahan Data', 'Lainnya',
];

// ════════════════════════════════════════════════════════════════════════════
// B02 — Formulir Pendaftaran Peristiwa Kependudukan (F-1.02)
// ════════════════════════════════════════════════════════════════════════════
class FormulirPendaftaranPeristiwaScreen extends StatefulWidget {
  const FormulirPendaftaranPeristiwaScreen({super.key});
  @override
  State<FormulirPendaftaranPeristiwaScreen> createState() => _F102State();
}

class _F102State extends State<FormulirPendaftaranPeristiwaScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();

  final _namaCtrl  = TextEditingController();
  final _nikCtrl   = TextEditingController();
  final _noKkCtrl  = TextEditingController();
  final _noHpCtrl  = TextEditingController();
  String? _kategori;
  final Set<String> _checkedPersyaratan = {};

  @override
  void dispose() {
    for (final c in [_namaCtrl, _nikCtrl, _noKkCtrl, _noHpCtrl]) { c.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async => {
    'nama'     : _namaCtrl.text,
    'nik'      : _nikCtrl.text,
    'no_kk'    : _noKkCtrl.text,
    'no_hp'    : _noHpCtrl.text,
    'kategori' : _kategori,
  };

  Widget _buildDataPemohon() => Form(
    key: _fk1,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data Pemohon'),
        const SizedBox(height: 16),
        fieldLabel('Nama Lengkap', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaCtrl, style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama lengkap sesuai KTP'),
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
        fieldLabel('Nomor Kartu Keluarga', required: true),
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
        fieldLabel('Nomor HP dan WA', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _noHpCtrl, keyboardType: TextInputType.phone,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 08123456789'),
          validator: validatePhone),
      ]),
    ]),
  );

  Widget _buildJenisPermohonan() => Form(
    key: _fk2,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Jenis Permohonan'),
        const SizedBox(height: 16),
        fieldLabel('Kategori Permohonan', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _kategori,
          decoration: dropdownDeco('Pilih kategori permohonan'),
          items: _kategoriF102.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _kategori = v),
          validator: (v) => v == null ? 'Kategori wajib dipilih' : null),
      ]),
    ]),
  );

  Widget _buildPersyaratan() => Column(children: [
    sectionCard(children: [
      sectionHeader('Persyaratan yang Dilampirkan'),
      const SizedBox(height: 4),
      Text('Centang persyaratan yang akan dilampirkan',
          style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
      const SizedBox(height: 8),
      ..._persyaratanF102.map((item) => CheckboxListTile(
        value: _checkedPersyaratan.contains(item),
        onChanged: (v) => setState(() {
          if (v == true) {
            _checkedPersyaratan.add(item);
          } else {
            _checkedPersyaratan.remove(item);
          }
        }),
        title: Text(item,
            style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textPrimary)),
        activeColor: AppTheme.primary,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
      )),
    ]),
  ]);

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Pendaftaran Kependudukan',
    dataSteps: [
      SuratDataStep(title: 'Data Pemohon',      formKey: _fk1, content: _buildDataPemohon()),
      SuratDataStep(title: 'Jenis Permohonan',  formKey: _fk2, content: _buildJenisPermohonan()),
      SuratDataStep(title: 'Persyaratan',        content: _buildPersyaratan()),
    ],
    jenisSurat: 'B02',
    onBuildPayload: _buildPayload,
  );
}
