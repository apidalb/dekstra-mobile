import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

// ── Model anggota F-1.01 ──────────────────────────────────────────────────────
class _AnggotaF101 {
  final namaCtrl      = TextEditingController();
  String? jk;
  final alamatCtrl    = TextEditingController();
  final nikCtrl       = TextEditingController();
  final pasporCtrl    = TextEditingController();
  final tempatCtrl    = TextEditingController();
  final tglCtrl       = TextEditingController();
  String? agama;
  String? statusKawin;
  String? shdk;
  final pekerjaanCtrl = TextEditingController();
  final nikIbuCtrl    = TextEditingController();
  final namaIbuCtrl   = TextEditingController();
  final nikAyahCtrl   = TextEditingController();
  final namaAyahCtrl  = TextEditingController();

  void dispose() {
    for (final c in [namaCtrl, alamatCtrl, nikCtrl, pasporCtrl, tempatCtrl,
      tglCtrl, pekerjaanCtrl, nikIbuCtrl, namaIbuCtrl, nikAyahCtrl, namaAyahCtrl]) {
      c.dispose();
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// B01 — Formulir Kartu Keluarga Pengganti (F-1.01)
// ════════════════════════════════════════════════════════════════════════════
class FormulirKkPenggantiScreen extends StatefulWidget {
  const FormulirKkPenggantiScreen({super.key});
  @override
  State<FormulirKkPenggantiScreen> createState() => _KkPenggantiState();
}

class _KkPenggantiState extends State<FormulirKkPenggantiScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();
  final _fk3 = GlobalKey<FormState>();

  final _namaKepalaCtrl = TextEditingController();
  final _noTelpCtrl     = TextEditingController();
  final _alamatCtrl     = TextEditingController();
  final _rtCtrl         = TextEditingController();
  final _rwCtrl         = TextEditingController();
  final _kodePosCtrl    = TextEditingController();
  final _namaRtCtrl     = TextEditingController();
  final _namaRwCtrl     = TextEditingController();
  final List<_AnggotaF101> _anggota = [_AnggotaF101()];

  @override
  void dispose() {
    for (final c in [_namaKepalaCtrl, _noTelpCtrl, _alamatCtrl, _rtCtrl,
      _rwCtrl, _kodePosCtrl, _namaRtCtrl, _namaRwCtrl]) { c.dispose(); }
    for (final a in _anggota) { a.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async => {
    'nama_kepala_kk'   : _namaKepalaCtrl.text,
    'no_telepon'       : _noTelpCtrl.text,
    'alamat'           : _alamatCtrl.text,
    'rt'               : _rtCtrl.text,
    'rw'               : _rwCtrl.text,
    'kode_pos'         : _kodePosCtrl.text,
    'nama_rt'          : _namaRtCtrl.text,
    'nama_rw'          : _namaRwCtrl.text,
    'anggota_keluarga' : _anggota.map((a) => {
      'nama'           : a.namaCtrl.text,
      'nik'            : a.nikCtrl.text,
      'jenis_kelamin'  : a.jk,
      'alamat'         : a.alamatCtrl.text,
      'tempat_lahir'   : a.tempatCtrl.text,
      'tanggal_lahir'  : ddmmyyyyToIso(a.tglCtrl.text),
      'agama'          : a.agama,
      'status_kawin'   : a.statusKawin,
      'shdk'           : a.shdk,
      'pekerjaan'      : a.pekerjaanCtrl.text,
      'nik_ibu'        : a.nikIbuCtrl.text,
      'nama_ibu'       : a.namaIbuCtrl.text,
      'nik_ayah'       : a.nikAyahCtrl.text,
      'nama_ayah'      : a.namaAyahCtrl.text,
    }).toList(),
  };

  Widget _buildDataKepalaKK() => Form(
    key: _fk1,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Data Kepala Keluarga'),
        const SizedBox(height: 16),
        fieldLabel('Nama Kepala Keluarga', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaKepalaCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama kepala keluarga'),
          validator: (v) => validateRequired(v, 'Nama kepala keluarga')),
        const SizedBox(height: 14),
        fieldLabel('Nomor Telepon', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _noTelpCtrl, keyboardType: TextInputType.phone,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 081234567890'),
          validator: validatePhone),
        const SizedBox(height: 14),
        fieldLabel('Alamat', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _alamatCtrl, maxLines: 2,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan alamat'),
          validator: (v) => validateRequired(v, 'Alamat')),
        const SizedBox(height: 14),
        fieldLabel('RT', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _rtCtrl, keyboardType: TextInputType.number,
          inputFormatters: angkaFormatters, style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 001'),
          validator: (v) => validateRequired(v, 'RT')),
        const SizedBox(height: 14),
        fieldLabel('RW', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _rwCtrl, keyboardType: TextInputType.number,
          inputFormatters: angkaFormatters, style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 002'),
          validator: (v) => validateRequired(v, 'RW')),
        const SizedBox(height: 14),
        fieldLabel('Kode Pos', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _kodePosCtrl, keyboardType: TextInputType.number,
          inputFormatters: kodePosFormatters,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Contoh: 50271'),
          validator: (v) => validateRequired(v, 'Kode Pos')),
      ]),
    ]),
  );

  Widget _buildAnggotaKeluarga() => Form(
    key: _fk2,
    child: Column(children: [
      ...List.generate(_anggota.length, (i) {
        final a = _anggota[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: sectionCard(children: [
            Row(children: [
              Expanded(child: Text('Anggota Keluarga #${i + 1}',
                  style: GoogleFonts.poppins(fontSize: 14,
                      fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
              if (_anggota.length > 1)
                GestureDetector(
                  onTap: () { a.dispose(); setState(() => _anggota.removeAt(i)); },
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
            TextFormField(controller: a.namaCtrl, style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Nama lengkap sesuai KTP'),
              validator: (v) => validateRequired(v, 'Nama')),
            const SizedBox(height: 12),
            fieldLabel('Jenis Kelamin', required: true),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(initialValue: a.jk,
              decoration: dropdownDeco('Pilih jenis kelamin'),
              items: kJenisKelaminList.map((e) => DropdownMenuItem(value: e,
                  child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => a.jk = v),
              validator: (v) => v == null ? 'Wajib dipilih' : null),
            const SizedBox(height: 12),
            fieldLabel('Alamat Sebelumnya'),
            const SizedBox(height: 6),
            TextFormField(controller: a.alamatCtrl, style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(
                  hintText: 'Isi jika pernah tinggal di alamat lain')),
            const SizedBox(height: 12),
            fieldLabel('Nomor KTP', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: a.nikCtrl,
              keyboardType: TextInputType.number, inputFormatters: nikFormatters,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
              validator: validateNIK),
            const SizedBox(height: 12),
            fieldLabel('Nomor Paspor'),
            const SizedBox(height: 6),
            TextFormField(controller: a.pasporCtrl, style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Isi jika memiliki paspor')),
            const SizedBox(height: 12),
            fieldLabel('Tempat Lahir', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: a.tempatCtrl, style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
              validator: (v) => validateRequired(v, 'Tempat lahir')),
            const SizedBox(height: 12),
            fieldLabel('Tanggal Lahir', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: a.tglCtrl, readOnly: true,
              onTap: () => pickDate(context, a.tglCtrl),
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
                  suffixIcon: Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary)),
              validator: (v) => validateDate(v, 'Tanggal lahir')),
            const SizedBox(height: 12),
            fieldLabel('Agama', required: true),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(initialValue: a.agama,
              decoration: dropdownDeco('Pilih agama'),
              items: kAgamaList.map((e) => DropdownMenuItem(value: e,
                  child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => a.agama = v),
              validator: (v) => v == null ? 'Wajib dipilih' : null),
            const SizedBox(height: 12),
            fieldLabel('Status Perkawinan', required: true),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(initialValue: a.statusKawin,
              decoration: dropdownDeco('Pilih status'),
              items: kStatusPernikahanList.map((e) => DropdownMenuItem(value: e,
                  child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => a.statusKawin = v),
              validator: (v) => v == null ? 'Wajib dipilih' : null),
            const SizedBox(height: 12),
            fieldLabel('Hubungan dalam Keluarga', required: true),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(initialValue: a.shdk,
              decoration: dropdownDeco('Pilih hubungan'),
              items: kShdkList.map((e) => DropdownMenuItem(value: e,
                  child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => a.shdk = v),
              validator: (v) => v == null ? 'Wajib dipilih' : null),
            const SizedBox(height: 12),
            fieldLabel('Pekerjaan', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: a.pekerjaanCtrl, style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan pekerjaan'),
              validator: (v) => validateRequired(v, 'Pekerjaan')),
            const SizedBox(height: 12),
            fieldLabel('NIK Ibu'),
            const SizedBox(height: 6),
            TextFormField(controller: a.nikIbuCtrl,
              keyboardType: TextInputType.number, inputFormatters: nikFormatters,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK Ibu')),
            const SizedBox(height: 12),
            fieldLabel('Nama Lengkap Ibu'),
            const SizedBox(height: 6),
            TextFormField(controller: a.namaIbuCtrl, style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan nama ibu')),
            const SizedBox(height: 12),
            fieldLabel('NIK Ayah'),
            const SizedBox(height: 6),
            TextFormField(controller: a.nikAyahCtrl,
              keyboardType: TextInputType.number, inputFormatters: nikFormatters,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK Ayah')),
            const SizedBox(height: 12),
            fieldLabel('Nama Lengkap Ayah'),
            const SizedBox(height: 6),
            TextFormField(controller: a.namaAyahCtrl, style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan nama ayah')),
          ]),
        );
      }),
      OutlinedButton.icon(
        onPressed: () => setState(() => _anggota.add(_AnggotaF101())),
        icon: const Icon(Icons.add, size: 18),
        label: Text('Tambah Anggota',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    ]),
  );

  Widget _buildInformasiLain() => Form(
    key: _fk3,
    child: Column(children: [
      sectionCard(children: [
        sectionHeader('Informasi Lain'),
        const SizedBox(height: 16),
        fieldLabel('Nama Ketua RT', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaRtCtrl, style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama ketua RT'),
          validator: (v) => validateRequired(v, 'Nama Ketua RT')),
        const SizedBox(height: 14),
        fieldLabel('Nama Ketua RW', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _namaRwCtrl, style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan nama ketua RW'),
          validator: (v) => validateRequired(v, 'Nama Ketua RW')),
      ]),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Formulir KK Pengganti',
    dataSteps: [
      SuratDataStep(title: 'Data Kepala KK',    formKey: _fk1, content: _buildDataKepalaKK()),
      SuratDataStep(title: 'Anggota Keluarga',  formKey: _fk2, content: _buildAnggotaKeluarga()),
      SuratDataStep(title: 'Informasi Lain',    formKey: _fk3, content: _buildInformasiLain()),
    ],
    jenisSurat: 'B01',
    onBuildPayload: _buildPayload,
  );
}
