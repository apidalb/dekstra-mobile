import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class SuratPengantarBarangScreen extends StatefulWidget {
  const SuratPengantarBarangScreen({super.key});

  @override
  State<SuratPengantarBarangScreen> createState() =>
      _SuratPengantarBarangScreenState();
}

class _SuratPengantarBarangScreenState
    extends State<SuratPengantarBarangScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Pemilik Barang
  final _pemilikNamaCtrl   = TextEditingController();
  final _pemilikNikCtrl    = TextEditingController();
  final _pemilikTempatCtrl = TextEditingController();
  final _pemilikTglCtrl    = TextEditingController();
  String? _pemilikJK;
  final _pemilikPekerjaanCtrl = TextEditingController();
  final _pemilikAlamatCtrl    = TextEditingController();

  // Pengantar Barang
  final _pengantarNamaCtrl   = TextEditingController();
  final _pengantarNikCtrl    = TextEditingController();
  final _pengantarTempatCtrl = TextEditingController();
  final _pengantarTglCtrl    = TextEditingController();
  String? _pengantarJK;
  final _pengantarPekerjaanCtrl = TextEditingController();
  final _pengantarAlamatCtrl    = TextEditingController();

  // Data Barang
  final _jenisBarangCtrl   = TextEditingController();
  final _jumlahBarangCtrl  = TextEditingController();
  final _jenisKendaraanCtrl = TextEditingController();
  final _nopolCtrl         = TextEditingController();
  final _supirCtrl         = TextEditingController();
  final _asalBarangCtrl    = TextEditingController();
  final _tujuanBarangCtrl  = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _pemilikNamaCtrl, _pemilikNikCtrl, _pemilikTempatCtrl,
      _pemilikTglCtrl, _pemilikPekerjaanCtrl, _pemilikAlamatCtrl,
      _pengantarNamaCtrl, _pengantarNikCtrl, _pengantarTempatCtrl,
      _pengantarTglCtrl, _pengantarPekerjaanCtrl, _pengantarAlamatCtrl,
      _jenisBarangCtrl, _jumlahBarangCtrl, _jenisKendaraanCtrl,
      _nopolCtrl, _supirCtrl, _asalBarangCtrl, _tujuanBarangCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Surat Keterangan Pengantar Barang');
  }

  Widget _personSection(
    String title, {
    required TextEditingController nama,
    required TextEditingController nik,
    required TextEditingController tempat,
    required TextEditingController tgl,
    required String? jk,
    required ValueChanged<String?> onJKChanged,
    required TextEditingController pekerjaan,
    required TextEditingController alamat,
  }) {
    return sectionCard(children: [
      sectionHeader(title),
      const SizedBox(height: 16),

      fieldLabel('Nama Lengkap', required: true),
      const SizedBox(height: 6),
      TextFormField(
        controller: nama,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
        validator: (v) => validateRequired(v, 'Nama lengkap'),
      ),
      const SizedBox(height: 14),

      fieldLabel('NIK', required: true),
      const SizedBox(height: 6),
      TextFormField(
        controller: nik,
        keyboardType: TextInputType.number,
        inputFormatters: nikFormatters,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
        validator: validateNIK,
      ),
      const SizedBox(height: 14),

      fieldLabel('Tempat Lahir', required: true),
      const SizedBox(height: 6),
      TextFormField(
        controller: tempat,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
        validator: (v) => validateRequired(v, 'Tempat lahir'),
      ),
      const SizedBox(height: 14),

      fieldLabel('Tanggal Lahir', required: true),
      const SizedBox(height: 6),
      TextFormField(
        controller: tgl,
        readOnly: true,
        onTap: () => pickDate(context, tgl),
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: const InputDecoration(
          hintText: 'dd/mm/yyyy',
          suffixIcon: Icon(Icons.calendar_today,
              size: 16, color: AppTheme.textSecondary),
        ),
        validator: (v) => v!.isEmpty ? 'Tanggal lahir wajib diisi' : null,
      ),
      const SizedBox(height: 14),

      fieldLabel('Jenis Kelamin', required: true),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: jk,
        decoration: dropdownDeco('Pilih jenis kelamin'),
        items: kJenisKelaminList
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.poppins(fontSize: 13)),
                ))
            .toList(),
        onChanged: onJKChanged,
        validator: (v) => v == null ? 'Jenis kelamin wajib dipilih' : null,
      ),
      const SizedBox(height: 14),

      fieldLabel('Pekerjaan', required: true),
      const SizedBox(height: 6),
      TextFormField(
        controller: pekerjaan,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: const InputDecoration(hintText: 'Masukkan pekerjaan'),
        validator: (v) => validateRequired(v, 'Pekerjaan'),
      ),
      const SizedBox(height: 14),

      fieldLabel('Alamat', required: true),
      const SizedBox(height: 6),
      TextFormField(
        controller: alamat,
        maxLines: 3,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: const InputDecoration(hintText: 'Masukkan alamat'),
        validator: (v) => validateRequired(v, 'Alamat'),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Surat Pengantar Barang'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            namaSuratCard('SURAT KETERANGAN PENGANTAR BARANG'),
            const SizedBox(height: 16),

            _personSection(
              'Pemilik Barang',
              nama: _pemilikNamaCtrl, nik: _pemilikNikCtrl,
              tempat: _pemilikTempatCtrl, tgl: _pemilikTglCtrl,
              jk: _pemilikJK,
              onJKChanged: (v) => setState(() => _pemilikJK = v),
              pekerjaan: _pemilikPekerjaanCtrl, alamat: _pemilikAlamatCtrl,
            ),
            const SizedBox(height: 16),

            _personSection(
              'Pengantar Barang',
              nama: _pengantarNamaCtrl, nik: _pengantarNikCtrl,
              tempat: _pengantarTempatCtrl, tgl: _pengantarTglCtrl,
              jk: _pengantarJK,
              onJKChanged: (v) => setState(() => _pengantarJK = v),
              pekerjaan: _pengantarPekerjaanCtrl, alamat: _pengantarAlamatCtrl,
            ),
            const SizedBox(height: 16),

            // ── Data Barang ──────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Barang & Kendaraan'),
              const SizedBox(height: 16),

              fieldLabel('Jenis Barang', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _jenisBarangCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan jenis barang'),
                validator: (v) => validateRequired(v, 'Jenis barang'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Jumlah Barang', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _jumlahBarangCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: angkaFormatters,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan jumlah barang'),
                validator: (v) => validateRequired(v, 'Jumlah barang'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Asal Barang', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _asalBarangCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan asal barang'),
                validator: (v) => validateRequired(v, 'Asal barang'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Tujuan Barang', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tujuanBarangCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan tujuan barang'),
                validator: (v) => validateRequired(v, 'Tujuan barang'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Jenis Kendaraan', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _jenisKendaraanCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Contoh: Truk, Pickup, Motor'),
                validator: (v) => validateRequired(v, 'Jenis kendaraan'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Nomor Polisi', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nopolCtrl,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: AB 1234 CD'),
                validator: (v) => validateRequired(v, 'Nomor polisi'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Nama Supir', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _supirCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama supir'),
                validator: (v) => validateRequired(v, 'Nama supir'),
              ),
            ]),
            const SizedBox(height: 24),

            bottomButtons(
              onBack: () => Navigator.pop(context),
              onSubmit: _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
