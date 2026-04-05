import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Formulir Perubahan KK WNI');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Formulir Perubahan KK'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            namaSuratCard('FORMULIR PERMOHONAN PERUBAHAN KK WNI (F-1.16)'),
            const SizedBox(height: 16),

            buildDataWilayah(provinsi: _provCtrl, kabKota: _kabCtrl,
                kecamatan: _kecCtrl, desa: _desaCtrl),
            const SizedBox(height: 16),

            // ── Data Pemohon ─────────────────────────────────────────
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
              TextFormField(controller: _noTelpCtrl, keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: 081234567890'),
                validator: validatePhone),
            ]),
            const SizedBox(height: 16),

            // ── Data KK yang Diikuti ─────────────────────────────────
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
            const SizedBox(height: 16),

            // ── Data KK Lama ─────────────────────────────────────────
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
            const SizedBox(height: 16),

            // ── Keterangan Permohonan ────────────────────────────────
            sectionCard(children: [
              sectionHeader('Keterangan Permohonan'),
              const SizedBox(height: 16),

              fieldLabel('Alasan Permohonan', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(value: _alasan,
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
            const SizedBox(height: 16),

            buildTabelAnggota(_anggota, setState),
            const SizedBox(height: 24),

            bottomButtons(onBack: () => Navigator.pop(context),
                onSubmit: _submit, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
