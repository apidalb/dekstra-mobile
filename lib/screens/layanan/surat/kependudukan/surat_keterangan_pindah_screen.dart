import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../form_surat_helpers.dart';

class _AnggotaPindah {
  final nikCtrl  = TextEditingController();
  final namaCtrl = TextEditingController();
  String? jk;
  String? shdk;
  void dispose() { nikCtrl.dispose(); namaCtrl.dispose(); }
}

class SuratKeteranganPindahScreen extends StatefulWidget {
  const SuratKeteranganPindahScreen({super.key});
  @override
  State<SuratKeteranganPindahScreen> createState() => _PindahState();
}

class _PindahState extends State<SuratKeteranganPindahScreen> {
  final _fk1 = GlobalKey<FormState>();
  final _fk2 = GlobalKey<FormState>();

  final _namaCtrl          = TextEditingController();
  final _nikCtrl           = TextEditingController();
  final _noKkCtrl          = TextEditingController();
  final _tempatCtrl        = TextEditingController();
  final _tglCtrl           = TextEditingController();
  String? _jk;
  String? _agama;
  final _pekerjaanCtrl     = TextEditingController();
  String? _status;
  String? _kwrg;
  final _alamatCtrl        = TextEditingController();
  final _alamatTujuanCtrl  = TextEditingController();
  String? _alasan;

  final List<_AnggotaPindah> _anggota = [_AnggotaPindah()];

  @override
  void dispose() {
    for (final c in [_namaCtrl, _nikCtrl, _noKkCtrl, _tempatCtrl, _tglCtrl,
      _pekerjaanCtrl, _alamatCtrl, _alamatTujuanCtrl]) { c.dispose(); }
    for (final a in _anggota) { a.dispose(); }
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildPayload() async {
    final payload = <String, dynamic>{
      'nama_lengkap'  : _namaCtrl.text,
      'nik'           : _nikCtrl.text,
      'no_kk'         : _noKkCtrl.text,
      'tempat_lahir'  : _tempatCtrl.text,
      'tanggal_lahir' : ddmmyyyyToIso(_tglCtrl.text),
      'jenis_kelamin' : _jk,
      'agama'         : _agama,
      'pekerjaan'     : _pekerjaanCtrl.text,
      'status'        : _status,
      'kewarganegaraan': _kwrg,
      'alamat'        : _alamatCtrl.text,
      'alasan'        : _alasan,
      'jumlah_pindah' : _anggota.length.toString(),
    };
    for (var i = 0; i < 6; i++) {
      final slot = i + 1;
      final a = i < _anggota.length ? _anggota[i] : null;
      payload['nik_$slot']          = a?.nikCtrl.text ?? '';
      payload['nama_lengkap_$slot'] = a?.namaCtrl.text ?? '';
      payload['jenis_kelamin_$slot'] = a?.jk ?? '';
      payload['shdk_$slot']         = a?.shdk ?? '';
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
        TextFormField(controller: _namaCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
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
        fieldLabel('Tempat Lahir', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tempatCtrl,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan tempat lahir'),
          validator: (v) => validateRequired(v, 'Tempat lahir')),
        const SizedBox(height: 14),
        fieldLabel('Tanggal Lahir', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _tglCtrl, readOnly: true,
          onTap: () => pickDate(context, _tglCtrl),
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'dd/mm/yyyy',
              suffixIcon: Icon(Icons.calendar_today, size: 16)),
          validator: (v) => validateDate(v, 'Tanggal lahir')),
        const SizedBox(height: 14),
        fieldLabel('Jenis Kelamin', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _jk,
          decoration: dropdownDeco('Pilih jenis kelamin'),
          items: kJenisKelaminList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _jk = v),
          validator: (v) => v == null ? 'Wajib dipilih' : null),
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
        fieldLabel('Status Pernikahan', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _status,
          decoration: dropdownDeco('Pilih status'),
          items: kStatusPernikahanList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _status = v),
          validator: (v) => v == null ? 'Wajib dipilih' : null),
        const SizedBox(height: 14),
        fieldLabel('Kewarganegaraan', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _kwrg,
          decoration: dropdownDeco('Pilih kewarganegaraan'),
          items: kKewarganegaraanList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _kwrg = v),
          validator: (v) => v == null ? 'Kewarganegaraan wajib dipilih' : null),
        const SizedBox(height: 14),
        fieldLabel('Alamat Asal', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _alamatCtrl, maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan alamat asal'),
          validator: (v) => validateRequired(v, 'Alamat')),
        const SizedBox(height: 14),
        fieldLabel('Alamat Tujuan', required: true),
        const SizedBox(height: 6),
        TextFormField(controller: _alamatTujuanCtrl, maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: const InputDecoration(hintText: 'Masukkan alamat tujuan pindah'),
          validator: (v) => validateRequired(v, 'Alamat tujuan')),
        const SizedBox(height: 14),
        fieldLabel('Alasan Pindah', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(initialValue: _alasan,
          decoration: dropdownDeco('Pilih alasan pindah'),
          items: kAlasanPindahList.map((e) => DropdownMenuItem(value: e,
              child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _alasan = v),
          validator: (v) => v == null ? 'Alasan pindah wajib dipilih' : null),
      ]),
    ]),
  );

  Widget _buildAnggotaPindah() => Form(
    key: _fk2,
    child: Column(children: [
      ...List.generate(_anggota.length, (i) {
        final a = _anggota[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: sectionCard(children: [
            Row(children: [
              Expanded(child: Text('Anggota Pindah ${i + 1}',
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
            fieldLabel('NIK', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: a.nikCtrl,
              keyboardType: TextInputType.number, inputFormatters: nikFormatters,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan 16 digit NIK'),
              validator: validateNIK),
            const SizedBox(height: 12),
            fieldLabel('Nama Lengkap', required: true),
            const SizedBox(height: 6),
            TextFormField(controller: a.namaCtrl,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Masukkan nama lengkap'),
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
            fieldLabel('SHDK (Status Hubungan Dalam Keluarga)', required: true),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(initialValue: a.shdk,
              decoration: dropdownDeco('Pilih SHDK'),
              items: kShdkList.map((e) => DropdownMenuItem(value: e,
                  child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => a.shdk = v),
              validator: (v) => v == null ? 'SHDK wajib dipilih' : null),
          ]),
        );
      }),
      if (_anggota.length < 6)
        OutlinedButton.icon(
          onPressed: () => setState(() => _anggota.add(_AnggotaPindah())),
          icon: const Icon(Icons.add, size: 18),
          label: Text('Tambah Anggota (${_anggota.length}/6)',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
    ]),
  );

  @override
  Widget build(BuildContext context) => SuratStepperPage(
    appBarTitle: 'Surat Ket. Pindah',
    dataSteps: [
      SuratDataStep(title: 'Data Pemohon',  formKey: _fk1, content: _buildDataPemohon()),
      SuratDataStep(title: 'Anggota Pindah', formKey: _fk2, content: _buildAnggotaPindah()),
    ],
    jenisSurat: 'B08',
    onBuildPayload: _buildPayload,
  );
}
