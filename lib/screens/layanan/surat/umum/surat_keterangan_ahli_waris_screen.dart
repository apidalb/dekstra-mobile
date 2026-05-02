import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class _AhliWaris {
  final namaCtrl   = TextEditingController();
  final nikCtrl    = TextEditingController();
  final tempatCtrl = TextEditingController();
  final tglCtrl    = TextEditingController();
  final alamatCtrl = TextEditingController();
  void dispose() {
    namaCtrl.dispose(); nikCtrl.dispose();
    tempatCtrl.dispose(); tglCtrl.dispose(); alamatCtrl.dispose();
  }
}

class SuratKeteranganAhliWarisScreen extends StatefulWidget {
  const SuratKeteranganAhliWarisScreen({super.key});
  @override
  State<SuratKeteranganAhliWarisScreen> createState() => _SKAhliWarisState();
}

class _SKAhliWarisState extends State<SuratKeteranganAhliWarisScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();

  // Step 1: Daftar Ahli Waris (array — sesuai web: array FIRST)
  final List<_AhliWaris> _daftarWaris = [_AhliWaris()];

  // Step 2: Data Pewaris
  final _namaPewarisCtrl  = TextEditingController();
  final _namaWarisanCtrl  = TextEditingController();

  @override
  void dispose() {
    _namaPewarisCtrl.dispose();
    _namaWarisanCtrl.dispose();
    for (final w in _daftarWaris) { w.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async => {
    'daftar_ahli_waris': _daftarWaris.map((w) => {
      'nama_lengkap' : w.namaCtrl.text,
      'nik'          : w.nikCtrl.text,
      'tempat_lahir' : w.tempatCtrl.text,
      'tanggal_lahir': ddmmyyyyToIso(w.tglCtrl.text),
      'alamat'       : w.alamatCtrl.text,
    }).toList(),
    'nama_pewaris' : _namaPewarisCtrl.text,
    'nama_warisan' : _namaWarisanCtrl.text,
  };

  Widget _buildDaftarAhliWaris() => Form(
    key: _fk1,
    child: Column(children: [
      ...List.generate(_daftarWaris.length, (i) {
        final w = _daftarWaris[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: sectionCard(children: [
            Row(children: [
              Expanded(child: Text('Ahli Waris ${i + 1}',
                  style: GoogleFonts.poppins(fontSize: 14,
                      fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
              if (_daftarWaris.length > 1)
                GestureDetector(
                  onTap: () { w.dispose(); setState(() => _daftarWaris.removeAt(i)); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('Hapus', style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500)),
                  ),
                ),
            ]),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppTheme.border),
            const SizedBox(height: 14),
            fieldLabel('Nama Lengkap', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: w.namaCtrl,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
              validator: (v) => validateRequired(v, 'Nama')),
            const SizedBox(height: 14),
            fieldLabel('NIK', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: w.nikCtrl,
              keyboardType: TextInputType.number, inputFormatters: nikFormatters,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
              validator: validateNIK),
            const SizedBox(height: 14),
            fieldLabel('Tempat Lahir', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: w.tempatCtrl,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
              validator: (v) => validateRequired(v, 'Tempat lahir')),
            const SizedBox(height: 14),
            fieldLabel('Tanggal Lahir', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: w.tglCtrl, readOnly: true,
              onTap: () => pickDate(context, w.tglCtrl),
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
                  suffixIcon: Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary)),
              validator: (v) => validateDate(v, 'Tanggal lahir')),
            const SizedBox(height: 14),
            fieldLabel('Alamat', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: w.alamatCtrl, maxLines: 2,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan alamat'),
              validator: (v) => validateRequired(v, 'Alamat')),
          ]),
        );
      }),
      if (_daftarWaris.length < 7)
        OutlinedButton.icon(
          onPressed: () => setState(() => _daftarWaris.add(_AhliWaris())),
          icon: const Icon(Icons.add, size: 18),
          label: Text('Tambah Ahli Waris (${_daftarWaris.length}/7)',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
    ]),
  );

  Widget _buildDataPewaris() => Form(
    key: _fk2,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data Pewaris'),
        const SizedBox(height: 16),
        fieldLabel('Nama Pewaris (Almarhum/ah)', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaPewarisCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama pewaris'),
          validator: (v) => validateRequired(v, 'Nama pewaris')),
        const SizedBox(height: 14),
        fieldLabel('Nama / Jenis Warisan', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaWarisanCtrl, maxLines: 2,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(
              hintText: 'Contoh: sebidang tanah di Desa ..., rumah di Jl. ...'),
          validator: (v) => validateRequired(v, 'Nama warisan')),
      ]),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Surat Ket. Ahli Waris',
    dataSteps: [
      SuratDataStep(title: 'Daftar Ahli Waris', formKey: _fk1, content: _buildDaftarAhliWaris()),
      SuratDataStep(title: 'Data Pewaris',       formKey: _fk2, content: _buildDataPewaris()),
    ],
    jenisSurat: 'A07',
    onBuildPayload: _buildPayload,
  );
}
