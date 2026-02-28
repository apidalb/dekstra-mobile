import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'layanan_screen.dart';
import 'akun_screen.dart';

// ── Model ─────────────────────────────────────────────────────────────────────
class _Permohonan {
  final String nik;
  final String nama;
  final String jenisSurat;
  final String tanggal;
  final String status;
  const _Permohonan({
    required this.nik, required this.nama,
    required this.jenisSurat, required this.tanggal, required this.status,
  });
}

class _Notifikasi {
  final String judul;
  final String pesan;
  final String waktu;
  final bool dibaca;
  const _Notifikasi({
    required this.judul, required this.pesan,
    required this.waktu, this.dibaca = false,
  });
}

// ── Data dummy ────────────────────────────────────────────────────────────────
const List<_Permohonan> _daftarPermohonan = [
  _Permohonan(nik: '1111111111111111', nama: 'John Doe', jenisSurat: 'Surat Domisili',                                       tanggal: '12 Januari 2026',  status: 'Verifikasi RT'),
  _Permohonan(nik: '1111111111111111', nama: 'John Doe', jenisSurat: 'Surat Keterangan Usaha',                               tanggal: '10 Februari 2026', status: 'Verifikasi RT'),
  _Permohonan(nik: '1111111111111111', nama: 'John Doe', jenisSurat: 'Surat Keterangan Penghasilan Orang Tua',               tanggal: '10 Januari 2026',  status: 'Disetujui'),
  _Permohonan(nik: '1111111111111111', nama: 'John Doe', jenisSurat: 'Surat Pengantar SKCK',                                 tanggal: '10 Desember 2025', status: 'Ditolak'),
  _Permohonan(nik: '1111111111111111', nama: 'John Doe', jenisSurat: 'Surat Pernyataan Tidak Memiliki Dokumen Kependudukan', tanggal: '12 Februari 2026', status: 'Verifikasi RW'),
  _Permohonan(nik: '1111111111111111', nama: 'John Doe', jenisSurat: 'Surat Keterangan Tidak Mampu',                        tanggal: '1 Februari 2026',  status: 'Verifikasi RW'),
  _Permohonan(nik: '1111111111111111', nama: 'John Doe', jenisSurat: 'Surat Pengantar Pindah (F-1.33)',                     tanggal: '8 Februari 2026',  status: 'Disetujui'),
  _Permohonan(nik: '1111111111111111', nama: 'John Doe', jenisSurat: 'Formulir Pendaftaran KK Baru WNI (F-1.15)',           tanggal: '10 Februari 2026', status: 'Disetujui'),
  _Permohonan(nik: '1111111111111111', nama: 'John Doe', jenisSurat: 'Pengantar Nikah',                                     tanggal: '7 Februari 2026',  status: 'Ditolak'),
  _Permohonan(nik: '1111111111111111', nama: 'John Doe', jenisSurat: 'Surat Keterangan Pengantar Barang',                   tanggal: '12 Januari 2026',  status: 'Ditolak'),
];

const List<_Notifikasi> _daftarNotifikasi = [
  _Notifikasi(judul: 'Pengajuan Surat Berhasil',      pesan: 'Pengajuan Surat Keterangan Usaha Anda berhasil terkirim',                          waktu: '2 menit lalu'),
  _Notifikasi(judul: 'Pengajuan Surat Diteruskan',    pesan: 'Pengajuan Surat Anda telah diverifikasi oleh RT dan diteruskan ke RW',             waktu: '10 menit lalu'),
  _Notifikasi(judul: 'Pengajuan Surat Diperbarui',    pesan: 'Pengajuan Surat Anda telah diverifikasi oleh RW dan diteruskan ke Kepala Desa',    waktu: '1 jam lalu',   dibaca: true),
  _Notifikasi(judul: 'Pengajuan Surat Telah Selesai', pesan: 'Surat Anda telah selesai diproses dan siap diunduh',                              waktu: '2 jam lalu',   dibaca: true),
];

// ── Status helpers ────────────────────────────────────────────────────────────
Color _statusBg(String s) {
  switch (s) {
    case 'Verifikasi RT': return const Color(0xFFFEF3C7);
    case 'Verifikasi RW': return const Color(0xFFDBEAFE);
    case 'Disetujui':     return const Color(0xFFD1FAE5);
    case 'Ditolak':       return const Color(0xFFFFE4E6);
    default:              return AppTheme.primaryLight;
  }
}

Color _statusColor(String s) {
  switch (s) {
    case 'Verifikasi RT': return const Color(0xFFD97706);
    case 'Verifikasi RW': return const Color(0xFF2563EB);
    case 'Disetujui':     return const Color(0xFF059669);
    case 'Ditolak':       return const Color(0xFFE11D48);
    default:              return AppTheme.primary;
  }
}

// ── HomeScreen ────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _BerandaTab(userName: widget.userName),
      const LayananScreen(),
      AkunScreen(userName: widget.userName),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Layanan'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Akun'),
          ],
        ),
      ),
    );
  }
}

// ── Beranda Tab ───────────────────────────────────────────────────────────────
class _BerandaTab extends StatefulWidget {
  final String userName;
  const _BerandaTab({required this.userName});

  @override
  State<_BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<_BerandaTab> {
  final GlobalKey _notifKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _notifOpen = false;
  String _searchQuery = '';

  List<_Permohonan> get _filtered => _searchQuery.isEmpty
      ? _daftarPermohonan
      : _daftarPermohonan.where((p) =>
          p.jenisSurat.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.status.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

  void _toggleNotif() => _notifOpen ? _closeNotif() : _openNotif();

  void _openNotif() {
    final box = _notifKey.currentContext!.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
                onTap: _closeNotif, behavior: HitTestBehavior.translucent),
          ),
          Positioned(
            top: offset.dy + size.height + 8,
            right: 16,
            width: MediaQuery.of(context).size.width - 32,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(14),
              child: _NotifPanel(onClose: _closeNotif),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _notifOpen = true);
  }

  void _closeNotif() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _notifOpen = false);
  }

  @override
  void dispose() { _closeNotif(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final unread = _daftarNotifikasi.where((n) => !n.dibaca).length;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ────────────────────────────────────────────────
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('👩', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                // Greeting
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang!',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${widget.userName},',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bell notifikasi
                GestureDetector(
                  key: _notifKey,
                  onTap: _toggleNotif,
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _notifOpen
                              ? AppTheme.primaryLight
                              : AppTheme.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: _notifOpen
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          size: 22,
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 0, top: 0,
                          child: Container(
                            width: 16, height: 16,
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Center(
                              child: Text('$unread',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppTheme.border),

          // ── Search bar ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari data...',
                prefixIcon: const Icon(Icons.search,
                    size: 18, color: AppTheme.textSecondary),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                isDense: true,
              ),
            ),
          ),

          // ── Daftar permohonan ────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('Tidak ada data',
                        style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppTheme.border),
                    itemBuilder: (context, i) =>
                        _PermohonanCard(item: _filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}


// ── Kartu permohonan ──────────────────────────────────────────────────────────
class _PermohonanCard extends StatelessWidget {
  final _Permohonan item;
  const _PermohonanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon dokumen
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined,
                color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.jenisSurat,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  item.tanggal,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 6),
                // Badge status
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusBg(item.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(item.status),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tombol aksi ⋮ dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                size: 20, color: AppTheme.textSecondary),
            color: AppTheme.surface,
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.zero,
            onSelected: (_) {},
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'detail',
                height: 40,
                child: Row(
                  children: [
                    const Icon(Icons.visibility_outlined,
                        size: 16, color: AppTheme.textPrimary),
                    const SizedBox(width: 10),
                    Text('Lihat Detail',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'unduh',
                height: 40,
                child: Row(
                  children: [
                    const Icon(Icons.download_outlined,
                        size: 16, color: AppTheme.textPrimary),
                    const SizedBox(width: 10),
                    Text('Unduh Surat',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'hapus',
                height: 40,
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        size: 16, color: Colors.red),
                    const SizedBox(width: 10),
                    Text('Hapus',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

// ── Panel Notifikasi ──────────────────────────────────────────────────────────
class _NotifPanel extends StatelessWidget {
  final VoidCallback onClose;
  const _NotifPanel({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      constraints: const BoxConstraints(maxHeight: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Text('Notifikasi',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppTheme.textSecondary, size: 18),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          // List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _daftarNotifikasi.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppTheme.border),
              itemBuilder: (_, i) =>
                  _NotifItem(notif: _daftarNotifikasi[i]),
            ),
          ),
          // Lihat Semua
          const Divider(height: 1, color: AppTheme.border),
          InkWell(
            onTap: onClose,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text('Lihat Semua',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  final _Notifikasi notif;
  const _NotifItem({required this.notif});

  @override
  Widget build(BuildContext context) {
    // Belum dibaca: background hijau muda, ikon hijau terang
    // Sudah dibaca: background putih, ikon abu redup
    final bgColor    = notif.dibaca ? Colors.transparent : const Color(0xFFECF7F5);
    final iconBg     = notif.dibaca ? const Color(0xFFEEEEEE) : AppTheme.primaryLight;
    final iconColor  = notif.dibaca ? AppTheme.textSecondary : AppTheme.primary;
    final titleColor = AppTheme.textPrimary;
    final textColor  = AppTheme.textSecondary;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon amplop bulat
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(Icons.email_outlined, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.judul,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: titleColor),
                ),
                const SizedBox(height: 3),
                Text(
                  notif.pesan,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: textColor, height: 1.4),
                ),
                const SizedBox(height: 5),
                Text(
                  notif.waktu,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
