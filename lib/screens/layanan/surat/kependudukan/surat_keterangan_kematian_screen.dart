import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class SuratKeteranganKematianScreen extends StatefulWidget {
  const SuratKeteranganKematianScreen({super.key});
  @override
  State<SuratKeteranganKematianScreen> createState() => _KematianState();
}

class _KematianState extends State<SuratKeteranganKematianScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Data Almarhum/ah
  final _namaCtrl          = TextEditingController();
  final _nikCtrl           = TextEditingController();
  final _tempatCtrl        = TextEditingController();
  final _tglLahirCtrl      = TextEditingController();
  String? _agama;
  final _pekerjaanCtrl     = TextEditingController();
  final _kwrgCtrl          = TextEditingController(text: 'WNI');
  final _alamatCtrl        = TextEditingController();
  final _tglMeninggalCtrl  = TextEditingController();
  final _tempatMeninggalCtrl = TextEditingController();

  // Data Pengaju
  final _statusHubCtrl     = TextEditingController();
  final _namaPengajuCtrl   = TextEditingController();
  final _nikPengajuCtrl    = TextEditingController();
  final _tempatPengajuCtrl = TextEditingController();
  final _tglPengajuCtrl    = TextEditingController();
  String? _agamaPengaju;
  final _pekerjaanPengajuCtrl = TextEditingController();
  final _kwrgPengajuCtrl   = TextEditingController(text: 'WNI');
  final _alamatPengajuCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _namaCtrl, _nikCtrl, _tempatCtrl, _tglLahirCtrl,
      _pekerjaanCtrl, _kwrgCtrl, _alamatCtrl, _tglMeninggalCtrl, _tempatMeninggalCtrl,
      _statusHubCtrl, _namaPengajuCtrl, _nikPengajuCtrl, _tempatPengajuCtrl,
      _tglPengajuCtrl, _pekerjaanPengajuCtrl, _kwrgPengajuCtrl, _alamatPengajuCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Surat Keterangan Kematian');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Surat Ket. Kematian'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            namaSuratCard('SURAT KETERANGAN KEMATIAN'),
            const SizedBox(height: 16),

            // ── Data Almarhum/ah ─────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Almarhum / Almarhumah'),
              const SizedBox(height: 16),

              fieldLabel('Nama Lengkap', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _namaCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama almarhum/ah'),
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

              fieldLabel('Tempat Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _tempatCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
                validator: (v) => validateRequired(v, 'Tempat lahir')),
              const SizedBox(height: 14),

              fieldLabel('Tanggal Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _tglLahirCtrl, readOnly: true,
                onTap: () => pickDate(context, _tglLahirCtrl),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
                    suffixIcon: Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary)),
                validator: (v) => validateDate(v, 'Tanggal lahir')),
              const SizedBox(height: 14),

              fieldLabel('Agama', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(initialValue: _agama,
                decoration: dropdownDeco('Pilih agama'),
                items: kAgamaList.map((e) => DropdownMenuItem(value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _agama = v),
                validator: (v) => v == null ? 'Agama wajib dipilih' : null),
              const SizedBox(height: 14),

              fieldLabel('Pekerjaan', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _pekerjaanCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan pekerjaan'),
                validator: (v) => validateRequired(v, 'Pekerjaan')),
              const SizedBox(height: 14),

              fieldLabel('Kewarganegaraan', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _kwrgCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: WNI'),
                validator: (v) => validateRequired(v, 'Kewarganegaraan')),
              const SizedBox(height: 14),

              fieldLabel('Alamat', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _alamatCtrl, maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan alamat'),
                validator: (v) => validateRequired(v, 'Alamat')),
              const SizedBox(height: 14),

              fieldLabel('Tanggal Meninggal', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _tglMeninggalCtrl, readOnly: true,
                onTap: () => pickDate(context, _tglMeninggalCtrl),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
                    suffixIcon: Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary)),
                validator: (v) => validateDate(v, 'Tanggal meninggal')),
              const SizedBox(height: 14),

              fieldLabel('Tempat Meninggal', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _tempatMeninggalCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: RS Umum, rumah'),
                validator: (v) => validateRequired(v, 'Tempat meninggal')),
            ]),
            const SizedBox(height: 16),

            // ── Data Pengaju ─────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Pengaju'),
              const SizedBox(height: 16),

              fieldLabel('Status Hubungan dengan Almarhum/ah', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _statusHubCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: Anak, Suami, Istri, Orang Tua'),
                validator: (v) => validateRequired(v, 'Status hubungan')),
              const SizedBox(height: 14),

              fieldLabel('Nama Lengkap', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _namaPengajuCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama pengaju'),
                validator: (v) => validateRequired(v, 'Nama pengaju')),
              const SizedBox(height: 14),

              fieldLabel('NIK', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _nikPengajuCtrl,
                keyboardType: TextInputType.number, inputFormatters: nikFormatters,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
                validator: validateNIK),
              const SizedBox(height: 14),

              fieldLabel('Tempat Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _tempatPengajuCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
                validator: (v) => validateRequired(v, 'Tempat lahir')),
              const SizedBox(height: 14),

              fieldLabel('Tanggal Lahir', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _tglPengajuCtrl, readOnly: true,
                onTap: () => pickDate(context, _tglPengajuCtrl),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
                    suffixIcon: Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary)),
                validator: (v) => validateDate(v, 'Tanggal lahir')),
              const SizedBox(height: 14),

              fieldLabel('Agama', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(initialValue: _agamaPengaju,
                decoration: dropdownDeco('Pilih agama'),
                items: kAgamaList.map((e) => DropdownMenuItem(value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _agamaPengaju = v),
                validator: (v) => v == null ? 'Agama wajib dipilih' : null),
              const SizedBox(height: 14),

              fieldLabel('Pekerjaan', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _pekerjaanPengajuCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan pekerjaan'),
                validator: (v) => validateRequired(v, 'Pekerjaan')),
              const SizedBox(height: 14),

              fieldLabel('Kewarganegaraan', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _kwrgPengajuCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: WNI'),
                validator: (v) => validateRequired(v, 'Kewarganegaraan')),
              const SizedBox(height: 14),

              fieldLabel('Alamat', required: true),
              const SizedBox(height: 6),
              TextFormField(controller: _alamatPengajuCtrl, maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan alamat pengaju'),
                validator: (v) => validateRequired(v, 'Alamat')),
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
