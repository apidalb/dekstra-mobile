import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

// pasangan: [label UI, backend key]
const _persyaratanF102 = [
  ['KK Lama / KK Rusak',                                         'lampiran_kk_lama'],
  ['Buku Nikah / Kutipan Akta Perkawinan',                       'lampiran_buku_nikah'],
  ['Kutipan Akta Perceraian',                                    'lampiran_akta_perceraian'],
  ['Surat Keterangan Pindah',                                    'lampiran_surat_pindah'],
  ['Surat Keterangan Pindah Luar Negeri',                        'lampiran_surat_pindah_luar_negeri'],
  ['KTP-el Rusak',                                               'lampiran_ktp_rusak'],
  ['Dokumen Perjalanan',                                         'lampiran_dokumen_perjalanan'],
  ['Surat Keterangan Hilang dari Kepolisian',                    'lampiran_surat_keterangan_hilang'],
  ['Surat Keterangan / Bukti Perubahan Peristiwa Kependudukan',  'lampiran_surat_keterangan_perubahan'],
  ['SPTJM Perkawinan / Perceraian Belum Tercatat',               'lampiran_sptjm'],
  ['Akta Kematian',                                              'lampiran_akta_kematian'],
  ['Surat Pernyataan Penyebab Terjadinya Hilang atau Rusak',     'lampiran_surat_pernyataan_hilang_rusak'],
  ['Surat Keterangan Pindah dari Perwakilan RI',                 'lampiran_surat_pindah_perwakilan_ri'],
  ['Surat Pernyataan Bersedia Menerima sebagai Anggota Keluarga','lampiran_surat_pernyataan_anggota'],
  ['Surat Kuasa Pengasuh Anak dari Orang Tua / Wali',            'lampiran_surat_kuasa_pengasuhan'],
  ['Kartu Izin Tinggal Tetap',                                   'lampiran_kartu_izin_tinggal_tetap'],
];

// mapping label kategori → {kategori_permohonan, jenis_*}
const _kategoriBackendMap = <String, Map<String, String>>{
  'KK Baru'                        : {'kategori_permohonan': 'kartu-keluarga', 'jenis_kk': 'kk-baru-membentuk-keluarga'},
  'Perubahan Data KK'              : {'kategori_permohonan': 'kartu-keluarga', 'jenis_kk': 'kk-ubah-elemen-data'},
  'KK Hilang / Rusak'              : {'kategori_permohonan': 'kartu-keluarga', 'jenis_kk': 'kk-hilang'},
  'KTP-el Baru'                    : {'kategori_permohonan': 'ktp-el',         'jenis_ktp': 'ktp-baru'},
  'KTP-el Pindah Datang'           : {'kategori_permohonan': 'ktp-el',         'jenis_ktp': 'ktp-pindah-datang'},
  'KTP-el Hilang / Rusak'          : {'kategori_permohonan': 'ktp-el',         'jenis_ktp': 'ktp-hilang'},
  'KTP-el Perpanjangan ITAP'       : {'kategori_permohonan': 'ktp-el',         'jenis_ktp': 'ktp-perpanjangan-itap'},
  'Kartu Identitas Anak (KIA) Baru': {'kategori_permohonan': 'kia',            'jenis_kia': 'kia-baru'},
  'KIA Hilang'                     : {'kategori_permohonan': 'kia',            'jenis_kia': 'kia-hilang'},
  'KIA Rusak'                      : {'kategori_permohonan': 'kia',            'jenis_kia': 'kia-rusak'},
  'Perubahan Data'                 : {'kategori_permohonan': 'perubahan-data', 'jenis_perubahan_data': 'ubah-kk'},
  'Lainnya'                        : {'kategori_permohonan': 'kartu-keluarga'},
};

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

  Future<Map<String, dynamic>> _buildPayload() async {
    final backendKategori = _kategoriBackendMap[_kategori] ?? {};
    final payload = <String, dynamic>{
      'nama_lengkap' : _namaCtrl.text,
      'nik'          : _nikCtrl.text,
      'nomor_kk'     : _noKkCtrl.text,
      'nomor_hp_wa'  : _noHpCtrl.text,
      ...backendKategori,
    };
    for (final pair in _persyaratanF102) {
      payload[pair[1]] = _checkedPersyaratan.contains(pair[0]);
    }
    return payload;
  }

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
      ..._persyaratanF102.map((pair) => CheckboxListTile(
        value: _checkedPersyaratan.contains(pair[0]),
        onChanged: (v) => setState(() {
          if (v == true) {
            _checkedPersyaratan.add(pair[0]);
          } else {
            _checkedPersyaratan.remove(pair[0]);
          }
        }),
        title: Text(pair[0],
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
