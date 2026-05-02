import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class PermohonanIzinKeramaianScreen extends StatefulWidget {
  const PermohonanIzinKeramaianScreen({super.key});
  @override
  State<PermohonanIzinKeramaianScreen> createState() => _IzinKeramaianState();
}

class _IzinKeramaianState extends State<PermohonanIzinKeramaianScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();

  // Data Pemohon
  final _namaCtrl      = TextEditingController();
  final _umurCtrl      = TextEditingController();
  final _pekerjaanCtrl = TextEditingController();
  final _alamatCtrl    = TextEditingController();

  // Data Acara
  final _namaAcaraCtrl    = TextEditingController();
  final _jenisAcaraCtrl   = TextEditingController();
  String? _hari;
  final _tanggalAcaraCtrl = TextEditingController();
  final _tempatAcaraCtrl  = TextEditingController();
  final _keteranganCtrl   = TextEditingController();

  @override
  void dispose() {
    for (final c in [_namaCtrl, _umurCtrl, _pekerjaanCtrl, _alamatCtrl,
      _namaAcaraCtrl, _jenisAcaraCtrl, _tanggalAcaraCtrl, _tempatAcaraCtrl, _keteranganCtrl]) { c.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async => {
    'nama_lengkap' : _namaCtrl.text,
    'umur'         : _umurCtrl.text,
    'pekerjaan'    : _pekerjaanCtrl.text,
    'alamat'       : _alamatCtrl.text,
    'nama_acara'   : _namaAcaraCtrl.text,
    'jenis_acara'  : _jenisAcaraCtrl.text,
    'hari_acara'   : _hari,
    'tanggal_acara': ddmmyyyyToIso(_tanggalAcaraCtrl.text),
    'tempat_acara' : _tempatAcaraCtrl.text,
    'keterangan'   : _keteranganCtrl.text,
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
          validator: (v) => validateRequired(v, 'Nama')),
        const SizedBox(height: 14),
        fieldLabel('Umur', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _umurCtrl,
          keyboardType: TextInputType.number, inputFormatters: angkaFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan umur', suffixText: 'Tahun'),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Umur wajib diisi';
            final n = int.tryParse(v);
            if (n == null || n < 17) return 'Umur minimal 17 tahun';
            return null;
          }),
        const SizedBox(height: 14),
        fieldLabel('Pekerjaan', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _pekerjaanCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan pekerjaan'),
          validator: (v) => validateRequired(v, 'Pekerjaan')),
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

  Widget _buildDataAcara() => Form(
    key: _fk2,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data Acara'),
        const SizedBox(height: 16),
        fieldLabel('Nama Acara', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaAcaraCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: Pernikahan, Syukuran, Khitanan'),
          validator: (v) => validateRequired(v, 'Nama acara')),
        const SizedBox(height: 14),
        fieldLabel('Jenis Acara', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _jenisAcaraCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: Resepsi, Pengajian, Pesta'),
          validator: (v) => validateRequired(v, 'Jenis acara')),
        const SizedBox(height: 14),
        fieldLabel('Hari Acara', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _hari,
          decoration: dropdownDeco('Pilih hari'),
          items: kHariList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _hari = v),
          validator: (v) => v == null ? 'Hari wajib dipilih' : null),
        const SizedBox(height: 14),
        fieldLabel('Tanggal Acara', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tanggalAcaraCtrl, readOnly: true,
          onTap: () => pickFutureDate(context, _tanggalAcaraCtrl),
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
              suffixIcon: Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary)),
          validator: (v) => validateDate(v, 'Tanggal acara')),
        const SizedBox(height: 14),
        fieldLabel('Tempat Acara', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tempatAcaraCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: Balai Desa, Rumah Kediaman'),
          validator: (v) => validateRequired(v, 'Tempat acara')),
        const SizedBox(height: 14),
        fieldLabel('Keterangan'),
        const SizedBox(height: 6),
        TextFormField(controller: _keteranganCtrl, maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(
              hintText: 'Isi jika ada keterangan tambahan mengenai acara')),
      ]),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Izin Keramaian / Pesta',
    dataSteps: [
      SuratDataStep(title: 'Data Pemohon', formKey: _fk1, content: _buildDataPemohon()),
      SuratDataStep(title: 'Data Acara',   formKey: _fk2, content: _buildDataAcara()),
    ],
    jenisSurat: 'A05',
    onBuildPayload: _buildPayload,
  );
}
