import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'surat/umum/surat_keterangan_usaha_screen.dart';
import 'surat/umum/surat_keterangan_tempat_usaha_screen.dart';
import 'surat/umum/surat_pengantar_barang_screen.dart';
import 'surat/umum/surat_keterangan_tidak_mampu_screen.dart';
import 'surat/umum/permohonan_izin_keramaian_screen.dart';
import 'surat/umum/surat_pengantar_skck_screen.dart';
import 'surat/umum/surat_keterangan_ahli_waris_screen.dart';
import 'surat/umum/surat_keterangan_lainnya_screen.dart';
import 'surat/kependudukan/formulir_kk_pengganti_screen.dart';
import 'surat/kependudukan/formulir_pendaftaran_peristiwa_screen.dart';
import 'surat/kependudukan/formulir_kk_baru_screen.dart';
import 'surat/kependudukan/formulir_perubahan_kk_screen.dart';
import 'surat/kependudukan/formulir_ktp_screen.dart';
import 'surat/kependudukan/surat_keterangan_domisili_screen.dart';
import 'surat/kependudukan/surat_keterangan_hilang_kk_screen.dart';
import 'surat/kependudukan/surat_keterangan_pindah_screen.dart';
import 'surat/kependudukan/formulir_perpindahan_penduduk_screen.dart';
import 'surat/kependudukan/surat_keterangan_kelahiran_screen.dart';
import 'surat/kependudukan/surat_keterangan_kematian_screen.dart';

// ── Data Model ────────────────────────────────────────────────────────────────
class _JenisSurat {
  final String nama;
  final String deskripsi;

  const _JenisSurat({required this.nama, required this.deskripsi});
}

// ── Data layanan surat ────────────────────────────────────────────────────────
const List<_JenisSurat> _layananUmum = [
  _JenisSurat(
    nama: 'Surat Keterangan Usaha',
    deskripsi: 'Surat yang menerangkan bahwa warga memiliki atau menjalankan suatu usaha di wilayah desa.',
  ),
  _JenisSurat(
    nama: 'Surat Keterangan Tempat Usaha',
    deskripsi: 'Surat yang menyatakan lokasi dan keberadaan tempat usaha warga secara resmi.',
  ),
  _JenisSurat(
    nama: 'Surat Keterangan Pengantar Barang',
    deskripsi: 'Surat pengantar untuk membawa atau mengirim barang dalam wilayah tertentu.',
  ),
  _JenisSurat(
    nama: 'Surat Keterangan Tidak Mampu (Sekolah)',
    deskripsi: 'Surat yang menyatakan warga kurang mampu secara ekonomi untuk keperluan pendidikan.',
  ),
  _JenisSurat(
    nama: 'Permohonan Izin Keramaian / Pesta',
    deskripsi: 'Surat permohonan izin untuk menyelenggarakan acara atau pesta di wilayah desa.',
  ),
  _JenisSurat(
    nama: 'Surat Pengantar SKCK',
    deskripsi: 'Surat pengantar dari desa sebagai syarat pembuatan Surat Keterangan Catatan Kepolisian (SKCK).',
  ),
  _JenisSurat(
    nama: 'Surat Keterangan Ahli Waris',
    deskripsi: 'Surat yang menetapkan seseorang atau beberapa orang sebagai ahli waris sah.',
  ),
  _JenisSurat(
    nama: 'Surat Keterangan Lainnya',
    deskripsi: 'Surat keterangan umum yang diterbitkan oleh desa untuk keperluan tertentu yang tidak termasuk dalam kategori surat yang telah tersedia.',
  ),
];

const List<_JenisSurat> _layananKependudukan = [
  _JenisSurat(
    nama: 'Formulir Kartu Keluarga (F-1.01)',
    deskripsi: 'Formulir pengganti Kartu Keluarga untuk pencatatan data seluruh anggota keluarga dalam satu rumah tangga.',
  ),
  _JenisSurat(
    nama: 'Formulir Pendaftaran Peristiwa Kependudukan (F-1.02)',
    deskripsi: 'Formulir untuk mendaftarkan peristiwa kependudukan seperti perubahan alamat atau status kependudukan.',
  ),
  _JenisSurat(
    nama: 'Formulir Permohonan KK Baru WNI (F-1.15)',
    deskripsi: 'Formulir permohonan pembuatan Kartu Keluarga baru bagi Warga Negara Indonesia.',
  ),
  _JenisSurat(
    nama: 'Formulir Permohonan Perubahan KK WNI (F-1.16)',
    deskripsi: 'Formulir permohonan perubahan data pada Kartu Keluarga bagi Warga Negara Indonesia.',
  ),
  _JenisSurat(
    nama: 'Formulir Permohonan KTP (F-1.21)',
    deskripsi: 'Formulir permohonan pembuatan atau perpanjangan Kartu Tanda Penduduk.',
  ),
  _JenisSurat(
    nama: 'Surat Keterangan Domisili',
    deskripsi: 'Surat yang menerangkan tempat tinggal atau domisili warga secara resmi di wilayah desa.',
  ),
  _JenisSurat(
    nama: 'Surat Keterangan Hilang Kartu Keluarga',
    deskripsi: 'Surat keterangan yang menyatakan bahwa Kartu Keluarga milik warga telah hilang.',
  ),
  _JenisSurat(
    nama: 'Surat Keterangan Pindah',
    deskripsi: 'Surat yang menerangkan bahwa warga berpindah tempat tinggal dari satu wilayah ke wilayah lain.',
  ),
  _JenisSurat(
    nama: 'Formulir Pendaftaran Perpindahan Penduduk (F-1.03)',
    deskripsi: 'Formulir resmi untuk mendaftarkan perpindahan penduduk antar wilayah administrasi.',
  ),
  _JenisSurat(
    nama: 'Surat Keterangan Kelahiran (F-2.01)',
    deskripsi: 'Surat keterangan resmi yang mencatat peristiwa kelahiran warga di wilayah desa.',
  ),
  _JenisSurat(
    nama: 'Surat Keterangan Kematian (F-2.29)',
    deskripsi: 'Surat keterangan resmi yang mencatat peristiwa kematian warga di wilayah desa.',
  ),
];

// ── LayananScreen ─────────────────────────────────────────────────────────────
class LayananScreen extends StatefulWidget {
  const LayananScreen({super.key});

  @override
  State<LayananScreen> createState() => _LayananScreenState();
}

class _LayananScreenState extends State<LayananScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_JenisSurat> get _currentList {
    final list = _tabController.index == 0 ? _layananUmum : _layananKependudukan;
    if (_searchQuery.isEmpty) return list;
    return list
        .where((s) => s.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            color: AppTheme.surface,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'Pilih Jenis Surat',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Tab bar ────────────────────────────────────────────
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primary,
                  indicatorWeight: 2.5,
                  labelStyle: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle:
                      GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400),
                  tabs: const [
                    Tab(text: 'Layanan Umum'),
                    Tab(text: 'Layanan Kependudukan'),
                  ],
                ),
              ],
            ),
          ),

          // ── Search bar ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Cari Surat...',
                prefixIcon: Icon(Icons.search,
                    size: 18, color: AppTheme.textSecondary),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                isDense: true,
              ),
            ),
          ),

          // ── Grid surat ───────────────────────────────────────────────
          Expanded(
            child: _currentList.isEmpty
                ? Center(
                    child: Text('Tidak ada surat ditemukan',
                        style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary, fontSize: 14)),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _currentList.length,
                    itemBuilder: (_, i) => _SuratCard(
                      surat: _currentList[i],
                      onTap: () => _navigateToForm(context, _currentList[i].nama),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context, String namaSurat) {
    Widget? screen;
    switch (namaSurat) {
      case 'Surat Keterangan Usaha':
        screen = const SuratKeteranganUsahaScreen();
        break;
      case 'Surat Keterangan Tempat Usaha':
        screen = const SuratKeteranganTempatUsahaScreen();
        break;
      case 'Surat Keterangan Pengantar Barang':
        screen = const SuratPengantarBarangScreen();
        break;
      case 'Surat Keterangan Tidak Mampu (Sekolah)':
        screen = const SuratKeteranganTidakMampuScreen();
        break;
      case 'Permohonan Izin Keramaian / Pesta':
        screen = const PermohonanIzinKeramaianScreen();
        break;
      case 'Surat Pengantar SKCK':
        screen = const SuratPengantarSkckScreen();
        break;
      case 'Surat Keterangan Ahli Waris':
        screen = const SuratKeteranganAhliWarisScreen();
        break;
      case 'Surat Keterangan Lainnya':
        screen = const SuratKeteranganLainnyaScreen();
        break;
      case 'Formulir Kartu Keluarga (F-1.01)':
        screen = const FormulirKkPenggantiScreen();
        break;
      case 'Formulir Pendaftaran Peristiwa Kependudukan (F-1.02)':
        screen = const FormulirPendaftaranPeristiwaScreen();
        break;
      case 'Formulir Permohonan KK Baru WNI (F-1.15)':
        screen = const FormulirKkBaruScreen();
        break;
      case 'Formulir Permohonan Perubahan KK WNI (F-1.16)':
        screen = const FormulirPerubahanKkScreen();
        break;
      case 'Formulir Permohonan KTP (F-1.21)':
        screen = const FormulirKtpScreen();
        break;
      case 'Surat Keterangan Domisili':
        screen = const SuratKeteranganDomisiliScreen();
        break;
      case 'Surat Keterangan Hilang Kartu Keluarga':
        screen = const SuratKeteranganHilangKkScreen();
        break;
      case 'Surat Keterangan Pindah':
        screen = const SuratKeteranganPindahScreen();
        break;
      case 'Formulir Pendaftaran Perpindahan Penduduk (F-1.03)':
        screen = const FormulirPerpindahanPendudukScreen();
        break;
      case 'Surat Keterangan Kelahiran (F-2.01)':
        screen = const SuratKeteranganKelahiranScreen();
        break;
      case 'Surat Keterangan Kematian (F-2.29)':
        screen = const SuratKeteranganKematianScreen();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Form "$namaSurat" belum tersedia',
              style: GoogleFonts.poppins()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.textSecondary,
        ));
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
  }

}
class _SuratCard extends StatelessWidget {
  final _JenisSurat surat;
  final VoidCallback onTap;

  const _SuratCard({required this.surat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon area
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_outlined,
                  color: AppTheme.primary, size: 20),
            ),
          ),

          const Divider(height: 1, indent: 12, endIndent: 12),

          // Nama surat
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
            child: Text(
              surat.nama,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Deskripsi — Flexible agar tidak overflow
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Text(
                surat.deskripsi,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Tombol Pilih Surat
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 34),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  textStyle: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('PILIH SURAT'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

