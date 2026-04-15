import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

const _klarifikasiList = [
  'Dalam satu Desa/Kelurahan',
  'Antar Desa/Kelurahan dalam satu Kecamatan',
  'Antar Kecamatan dalam satu Kabupaten/Kota',
  'Antar Kabupaten/Kota dalam satu Provinsi',
  'Antar Provinsi',
];

const _alasanPindahList = [
  'Pekerjaan', 'Pendidikan', 'Keamanan', 'Kesehatan',
  'Perumahan', 'Keluarga', 'Lainnya',
];

class _AnggotaF103 {
  final nikCtrl  = TextEditingController();
  final namaCtrl = TextEditingController();
  String? shdk;
  void dispose() { nikCtrl.dispose(); namaCtrl.dispose(); }
}

// ════════════════════════════════════════════════════════════════════════════
// B09 — Formulir Pendaftaran Perpindahan Penduduk (F-1.03)
// ════════════════════════════════════════════════════════════════════════════
class FormulirPerpindahanPendudukScreen extends StatefulWidget {
  const FormulirPerpindahanPendudukScreen({super.key});
  @override
  State<FormulirPerpindahanPendudukScreen> createState() => _F103State();
}

class _F103State extends State<FormulirPerpindahanPendudukScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _noKkCtrl    = TextEditingController();
  final _namaCtrl    = TextEditingController();
  final _nikCtrl     = TextEditingController();
  final _noHpCtrl    = TextEditingController();

  // Alamat Asal
  final _alamatAsalCtrl = TextEditingController();
  final _rtAsalCtrl     = TextEditingController();
  final _rwAsalCtrl     = TextEditingController();
  final _desaAsalCtrl   = TextEditingController();
  final _kecAsalCtrl    = TextEditingController();
  final _kabAsalCtrl    = TextEditingController();
  final _provAsalCtrl   = TextEditingController();
  final _kodeAsalCtrl   = TextEditingController();

  // Alamat Tujuan
  String? _klarifikasi;
  final _alamatTujCtrl = TextEditingController();
  final _rtTujCtrl     = TextEditingController();
  final _rwTujCtrl     = TextEditingController();
  final _desaTujCtrl   = TextEditingController();
  final _kecTujCtrl    = TextEditingController();
  final _kabTujCtrl    = TextEditingController();
  final _provTujCtrl   = TextEditingController();
  final _kodeTujCtrl   = TextEditingController();
  String? _alasan;

  final List<_AnggotaF103> _anggota = [_AnggotaF103()];

  @override
  void dispose() {
    for (final c in [_noKkCtrl, _namaCtrl, _nikCtrl, _noHpCtrl,
      _alamatAsalCtrl, _rtAsalCtrl, _rwAsalCtrl, _desaAsalCtrl,
      _kecAsalCtrl, _kabAsalCtrl, _provAsalCtrl, _kodeAsalCtrl,
      _alamatTujCtrl, _rtTujCtrl, _rwTujCtrl, _desaTujCtrl,
      _kecTujCtrl, _kabTujCtrl, _provTujCtrl, _kodeTujCtrl]) { c.dispose(); }
    for (final a in _anggota) { a.dispose(); }
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Formulir Pendaftaran Perpindahan Penduduk');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Formulir Perpindahan'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            namaSuratCard('FORMULIR PENDAFTARAN PERPINDAHAN PENDUDUK (F-1.03)'),
            const SizedBox(height: 16),

            // ── Data Pemohon ─────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Pemohon'),
              const SizedBox(height: 16),

              fieldLabel('Nomor KK', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _noKkCtrl,
                keyboardType: TextInputType.number, inputFormatters: nikFormatters,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan 16 digit No. KK'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'No. KK wajib diisi';
                  if (v.length != 16) return 'No. KK harus 16 digit';
                  return null;
                }),
              const SizedBox(height: 14),

              fieldLabel('Nama Lengkap Pemohon', required: true),
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

              fieldLabel('No. HP / WhatsApp', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _noHpCtrl, keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: 081234567890'),
                validator: validatePhone),
            ]),
            const SizedBox(height: 16),

            // ── Alamat Asal ──────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Alamat Asal'),
              const SizedBox(height: 16),
              ...buildAlamatBlock(
                alamat: _alamatAsalCtrl, rt: _rtAsalCtrl, rw: _rwAsalCtrl,
                desa: _desaAsalCtrl, kec: _kecAsalCtrl, kab: _kabAsalCtrl,
                prov: _provAsalCtrl, kodePos: _kodeAsalCtrl),
            ]),
            const SizedBox(height: 16),

            // ── Alamat Tujuan ────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Alamat Tujuan'),
              const SizedBox(height: 16),

              fieldLabel('Klarifikasi Kepindahan', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(initialValue: _klarifikasi,
                decoration: dropdownDeco('Pilih klarifikasi kepindahan'),
                items: _klarifikasiList.map((e) => DropdownMenuItem(value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 12)))).toList(),
                onChanged: (v) => setState(() => _klarifikasi = v),
                validator: (v) => v == null ? 'Wajib dipilih' : null),
              const SizedBox(height: 14),

              ...buildAlamatBlock(
                alamat: _alamatTujCtrl, rt: _rtTujCtrl, rw: _rwTujCtrl,
                desa: _desaTujCtrl, kec: _kecTujCtrl, kab: _kabTujCtrl,
                prov: _provTujCtrl, kodePos: _kodeTujCtrl),
              const SizedBox(height: 14),

              fieldLabel('Alasan Pindah', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(initialValue: _alasan,
                decoration: dropdownDeco('Pilih alasan pindah'),
                items: _alasanPindahList.map((e) => DropdownMenuItem(value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _alasan = v),
                validator: (v) => v == null ? 'Wajib dipilih' : null),
            ]),
            const SizedBox(height: 16),

            // ── Anggota Keluarga yang Pindah ─────────────────────────
            sectionCard(children: [
              sectionHeader('Daftar Anggota Keluarga yang Pindah'),
              const SizedBox(height: 12),

              ...List.generate(_anggota.length, (i) {
                final a = _anggota[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('Anggota ${i + 1}',
                          style: GoogleFonts.poppins(fontSize: 13,
                              fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      const Spacer(),
                      if (_anggota.length > 1)
                        GestureDetector(
                          onTap: () { a.dispose(); setState(() => _anggota.removeAt(i)); },
                          child: Text('Hapus', style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500)),
                        ),
                    ]),
                    const SizedBox(height: 8),

                    fieldLabel('NIK', required: true),
                    const SizedBox(height: 6),
                    TextFormField(controller: a.nikCtrl,
                      keyboardType: TextInputType.number, inputFormatters: nikFormatters,
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
                      validator: validateNIK),
                    const SizedBox(height: 10),

                    fieldLabel('Nama Lengkap', required: true),
                    const SizedBox(height: 6),
                    TextFormField(controller: a.namaCtrl, style: GoogleFonts.poppins(fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
                      validator: (v) => validateRequired(v, 'Nama')),
                    const SizedBox(height: 10),

                    fieldLabel('SHDK', required: true),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(initialValue: a.shdk,
                      decoration: dropdownDeco('Pilih status hubungan'),
                      items: kShdkList.map((e) => DropdownMenuItem(value: e,
                          child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() => a.shdk = v),
                      validator: (v) => v == null ? 'SHDK wajib dipilih' : null),

                    if (i < _anggota.length - 1)
                      const Padding(
                        padding: EdgeInsets.only(top: 14),
                        child: Divider(height: 1, color: AppTheme.border),
                      ),
                  ]),
                );
              }),

              TextButton.icon(
                onPressed: () => setState(() => _anggota.add(_AnggotaF103())),
                icon: const Icon(Icons.add, size: 16),
                label: Text('Tambah Anggota',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
              ),
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
