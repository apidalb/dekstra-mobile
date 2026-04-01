import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Formulir Pendaftaran Peristiwa Kependudukan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Pendaftaran Kependudukan'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            namaSuratCard('FORMULIR PENDAFTARAN PERISTIWA KEPENDUDUKAN (F-1.02)'),
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),

            sectionCard(children: [
              sectionHeader('Jenis Permohonan'),
              const SizedBox(height: 16),

              fieldLabel('Kategori Permohonan', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(value: _kategori,
                decoration: dropdownDeco('Pilih kategori permohonan'),
                items: _kategoriF102.map((e) => DropdownMenuItem(value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _kategori = v),
                validator: (v) => v == null ? 'Kategori wajib dipilih' : null),
            ]),
            const SizedBox(height: 16),

            sectionCard(children: [
              sectionHeader('Persyaratan yang Dilampirkan'),
              const SizedBox(height: 4),
              Text('Centang persyaratan yang akan dilampirkan',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              ..._persyaratanF102.map((item) => CheckboxListTile(
                value: _checkedPersyaratan.contains(item),
                onChanged: (v) => setState(() {
                  if (v == true) _checkedPersyaratan.add(item);
                  else _checkedPersyaratan.remove(item);
                }),
                title: Text(item,
                    style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textPrimary)),
                activeColor: AppTheme.primary,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              )),
            ]),
            const SizedBox(height: 24),

            bottomButtons(onBack: () => Navigator.pop(context),
                onSubmit: _submit, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
