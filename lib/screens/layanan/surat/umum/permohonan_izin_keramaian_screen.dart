import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class PermohonanIzinKeramaianScreen extends StatefulWidget {
  const PermohonanIzinKeramaianScreen({super.key});

  @override
  State<PermohonanIzinKeramaianScreen> createState() =>
      _PermohonanIzinKeramaianScreenState();
}

class _PermohonanIzinKeramaianScreenState
    extends State<PermohonanIzinKeramaianScreen> {
  final _formKey  = GlobalKey<FormState>();
  bool _isLoading = false;

  // Data Pemohon
  final _namaCtrl      = TextEditingController();
  final _umurCtrl      = TextEditingController();
  final _pekerjaanCtrl = TextEditingController();
  final _alamatCtrl    = TextEditingController();

  // Data Acara
  final _namaAcaraCtrl   = TextEditingController();
  final _jenisAcaraCtrl  = TextEditingController();
  final _tanggalAcaraCtrl = TextEditingController();
  final _tempatAcaraCtrl = TextEditingController();
  final _keteranganCtrl  = TextEditingController();

  static const List<String> _hariList = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  String? _hari;

  @override
  void dispose() {
    for (final c in [
      _namaCtrl, _umurCtrl, _pekerjaanCtrl, _alamatCtrl,
      _namaAcaraCtrl, _jenisAcaraCtrl, _tanggalAcaraCtrl,
      _tempatAcaraCtrl, _keteranganCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    showSuccessDialog(context, 'Permohonan Izin Keramaian');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Izin Keramaian / Pesta'),
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
            namaSuratCard('PERMOHONAN IZIN KERAMAIAN'),
            const SizedBox(height: 16),

            // ── Data Pemohon ─────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Pemohon'),
              const SizedBox(height: 16),

              fieldLabel('Nama Pemohon', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan nama pemohon'),
                validator: (v) => validateRequired(v, 'Nama pemohon'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Umur', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _umurCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: angkaFormatters,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan umur'),
                validator: (v) => validateRequired(v, 'Umur'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Pekerjaan', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pekerjaanCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan pekerjaan'),
                validator: (v) => validateRequired(v, 'Pekerjaan'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Alamat', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _alamatCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan alamat'),
                validator: (v) => validateRequired(v, 'Alamat'),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Data Acara ───────────────────────────────────────────
            sectionCard(children: [
              sectionHeader('Data Acara'),
              const SizedBox(height: 16),

              fieldLabel('Nama Acara', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaAcaraCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Contoh: Pernikahan, Sunatan'),
                validator: (v) => validateRequired(v, 'Nama acara'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Jenis Acara', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _jenisAcaraCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Contoh: Resepsi, Hiburan, Keagamaan'),
                validator: (v) => validateRequired(v, 'Jenis acara'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Hari', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _hari,
                decoration: dropdownDeco('Pilih hari'),
                items: _hariList
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: GoogleFonts.poppins(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _hari = v),
                validator: (v) => v == null ? 'Hari wajib dipilih' : null,
              ),
              const SizedBox(height: 14),

              fieldLabel('Tanggal Acara', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tanggalAcaraCtrl,
                readOnly: true,
                onTap: () => pickFutureDate(context, _tanggalAcaraCtrl),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'dd/mm/yyyy',
                  suffixIcon: Icon(Icons.calendar_today,
                      size: 16, color: AppTheme.textSecondary),
                ),
                validator: (v) => validateDate(v, 'Tanggal acara'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Tempat Acara', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tempatAcaraCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(hintText: 'Masukkan tempat acara'),
                validator: (v) => validateRequired(v, 'Tempat acara'),
              ),
              const SizedBox(height: 14),

              fieldLabel('Keterangan Tambahan'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _keteranganCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Keterangan tambahan (opsional)'),
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
