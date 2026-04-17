import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../layanan/layanan_screen.dart';
import '../akun/akun_screen.dart';
import 'riwayat_screen.dart';
import 'permohonan_detail_screen.dart';
import 'notifikasi_screen.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Model & Data (public — diakses juga oleh RiwayatScreen)
// ══════════════════════════════════════════════════════════════════════════════

class Permohonan {
  final int id;
  final String nomorPermohonan;
  final String jenisSurat;
  final DateTime tanggal;
  final String status;

  const Permohonan({
    required this.id,
    required this.nomorPermohonan,
    required this.jenisSurat,
    required this.tanggal,
    required this.status,
  });

  factory Permohonan.fromJson(Map<String, dynamic> json) {
    final statusInt = json['status'] as int;
    final statusStr = switch (statusInt) {
      1 => 'Menunggu Verifikasi',
      2 => 'Ditolak',
      3 => 'Disetujui',
      _ => 'Tidak Diketahui',
    };
    final diajukanAt = json['diajukan_at'];
    return Permohonan(
      id: json['id'] as int,
      nomorPermohonan: json['nomor_permohonan'] as String? ?? '',
      jenisSurat: (json['jenis_surat'] as Map<String, dynamic>)['nama'] as String,
      tanggal: diajukanAt != null ? DateTime.parse(diajukanAt as String) : DateTime.now(),
      status: statusStr,
    );
  }

  String get tanggalFormatted =>
      '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
}

const List<String> allStatuses = [
  'Menunggu Verifikasi',
  'Disetujui',
  'Ditolak',
];

// ── Status helpers ─────────────────────────────────────────────────────────────
Color statusBg(String s) {
  switch (s) {
    case 'Menunggu Verifikasi': return const Color(0xFFFEF3C7);
    case 'Disetujui':           return const Color(0xFFD1FAE5);
    case 'Ditolak':             return const Color(0xFFFFE4E6);
    default:                    return AppTheme.primaryLight;
  }
}

Color statusColor(String s) {
  switch (s) {
    case 'Menunggu Verifikasi': return const Color(0xFFD97706);
    case 'Disetujui':           return const Color(0xFF059669);
    case 'Ditolak':             return const Color(0xFFE11D48);
    default:                    return AppTheme.primary;
  }
}

// ── Notifikasi ─────────────────────────────────────────────────────────────────
class _Notifikasi {
  final String judul;
  final String pesan;
  final String waktu;
  final bool dibaca;
  const _Notifikasi({
    required this.judul,
    required this.pesan,
    required this.waktu,
    this.dibaca = false,
  });
}

const List<_Notifikasi> _daftarNotifikasi = [
  _Notifikasi(judul: 'Pengajuan Surat Berhasil',  pesan: 'Pengajuan Surat Keterangan Usaha berhasil dikirim',  waktu: '2 menit lalu'),
  _Notifikasi(judul: 'Surat Diverifikasi RT',     pesan: 'Pengajuan diteruskan ke RW',                        waktu: '10 menit lalu'),
  _Notifikasi(judul: 'Surat Diverifikasi RW',     pesan: 'Pengajuan diteruskan ke Kepala Desa',               waktu: '1 jam lalu',  dibaca: true),
];

// ══════════════════════════════════════════════════════════════════════════════
// HomeScreen
// ══════════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

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
      AkunScreen(userName: widget.userName, userEmail: widget.userEmail),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle:
              GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Layanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _BerandaTab
// ══════════════════════════════════════════════════════════════════════════════
class _BerandaTab extends StatefulWidget {
  final String userName;
  const _BerandaTab({required this.userName});

  @override
  State<_BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<_BerandaTab> {
  // ── Notif overlay ──────────────────────────────────────────────────────────
  final GlobalKey _notifKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _notifOpen = false;

  // ── Filter & Search state ──────────────────────────────────────────────────
  String _searchQuery   = '';
  String? _filterStatus;       // null = semua
  String? _filterJenis;        // null = semua
  DateTime? _filterTanggalDari;
  DateTime? _filterTanggalHingga;

  // ── List permohonan aktif (status Menunggu Verifikasi) ───────────────────
  List<Permohonan> _list = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadPermohonan();
  }

  Future<void> _loadPermohonan() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final data = await ApiService.getPermohonan();
      final all  = data.map((j) => Permohonan.fromJson(j)).toList();
      setState(() {
        _list = all.where((p) => p.status == 'Menunggu Verifikasi').toList();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() { _errorMsg = e.message; _isLoading = false; });
    } catch (_) {
      setState(() { _errorMsg = 'Gagal terhubung ke server'; _isLoading = false; });
    }
  }

  List<String> get _jenisSuratList {
    final seen = <String>{};
    return _list.map((p) => p.jenisSurat).where((j) => seen.add(j)).toList()..sort();
  }

  String _avatarInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }

  bool get _hasActiveFilter =>
      _filterStatus != null ||
      _filterJenis != null ||
      _filterTanggalDari != null ||
      _filterTanggalHingga != null;

  List<Permohonan> get _filtered {
    return _list.where((p) {
      if (_searchQuery.isNotEmpty &&
          !p.jenisSurat.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !p.status.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_filterStatus != null && p.status != _filterStatus) return false;
      if (_filterJenis != null && p.jenisSurat != _filterJenis) return false;
      if (_filterTanggalDari != null &&
          p.tanggal.isBefore(_filterTanggalDari!)) {
        return false;
      }
      if (_filterTanggalHingga != null &&
          p.tanggal.isAfter(
              _filterTanggalHingga!.add(const Duration(days: 1)))) {
        return false;
      }
      return true;
    }).toList();
  }

  // ── Notif overlay ──────────────────────────────────────────────────────────
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
              onTap: _closeNotif,
              behavior: HitTestBehavior.translucent,
            ),
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

  // ── Filter dialog popup ────────────────────────────────────────────────────
  void _showFilter() {
    String? tmpStatus   = _filterStatus;
    String? tmpJenis    = _filterJenis;
    DateTime? tmpDari   = _filterTanggalDari;
    DateTime? tmpHingga = _filterTanggalHingga;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          Future<void> pickDate({required bool isDari}) async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate:
                  (isDari ? tmpDari : tmpHingga) ?? DateTime(2026, 1, 1),
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
              builder: (c, child) => Theme(
                data: Theme.of(c).copyWith(
                  colorScheme:
                      const ColorScheme.light(primary: AppTheme.primary),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setModal(() {
                if (isDari) {
                  tmpDari = picked;
                } else {
                  tmpHingga = picked;
                }
              });
            }
          }

          String fmtDate(DateTime? d) => d == null
              ? 'Pilih Tanggal'
              : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppTheme.surface,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text('Filter Data',
                          style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close,
                            size: 20, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status
                  Text('Berdasarkan Status Surat',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  _filterDropdown(
                    value: tmpStatus,
                    hint: 'Semua',
                    items: allStatuses,
                    onChanged: (v) => setModal(() => tmpStatus = v),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 16),

                  // Jenis Surat
                  Text('Berdasarkan Jenis Surat',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  _filterDropdown(
                    value: tmpJenis,
                    hint: 'Semua',
                    items: _jenisSuratList,
                    onChanged: (v) => setModal(() => tmpJenis = v),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 16),

                  // Tanggal
                  Text('Berdasarkan Tanggal Pengajuan',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _datePickerButton(
                          label: fmtDate(tmpDari),
                          onTap: () => pickDate(isDari: true),
                          hasValue: tmpDari != null,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('–',
                            style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary,
                                fontSize: 16)),
                      ),
                      Expanded(
                        child: _datePickerButton(
                          label: fmtDate(tmpHingga),
                          onTap: () => pickDate(isDari: false),
                          hasValue: tmpHingga != null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setModal(() {
                            tmpStatus  = null;
                            tmpJenis   = null;
                            tmpDari    = null;
                            tmpHingga  = null;
                          }),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _filterStatus        = tmpStatus;
                              _filterJenis         = tmpJenis;
                              _filterTanggalDari   = tmpDari;
                              _filterTanggalHingga = tmpHingga;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text('Semua',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppTheme.textSecondary)),
          style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textPrimary),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppTheme.textSecondary),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('Semua',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppTheme.textSecondary)),
            ),
            ...items.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: AppTheme.textPrimary)),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _datePickerButton({
    required String label,
    required VoidCallback onTap,
    required bool hasValue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasValue ? AppTheme.primary : AppTheme.border,
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: 14,
                color: hasValue ? AppTheme.primary : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: hasValue ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _closeNotif();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread  = _daftarNotifikasi.where((n) => !n.dibaca).length;
    final filtered = _filtered;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────────────────────────────────────
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _avatarInitials(widget.userName),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Selamat Datang, ${widget.userName}!',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('👋', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      Text(
                        'Silakan buat pengajuan surat Anda',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
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
                        width: 40, height: 40,
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

          // ── Tombol aksi ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final homeState = context
                          .findAncestorStateOfType<_HomeScreenState>();
                      homeState?.setState(() => homeState._selectedIndex = 1);
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Buat Surat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RiwayatScreen()),
                    ),
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text(
                      'Riwayat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Search + Filter ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Cari data...',
                      prefixIcon: Icon(Icons.search,
                          size: 18, color: AppTheme.textSecondary),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Filter dengan indikator aktif
                GestureDetector(
                  onTap: _showFilter,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _hasActiveFilter
                          ? AppTheme.primary
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _hasActiveFilter
                            ? AppTheme.primary
                            : AppTheme.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: _hasActiveFilter
                              ? Colors.white
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Filter',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _hasActiveFilter
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Daftar permohonan (info teks masuk dalam list) ──────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMsg != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_outlined,
                                size: 48, color: AppTheme.border),
                            const SizedBox(height: 12),
                            Text(_errorMsg!,
                                style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary, fontSize: 13),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _loadPermohonan,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: Text('Coba lagi',
                                  style: GoogleFonts.poppins(fontSize: 13)),
                            ),
                          ],
                        ),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.inbox_outlined,
                                    size: 48, color: AppTheme.border),
                                const SizedBox(height: 12),
                                Text('Tidak ada permohonan aktif',
                                    style: GoogleFonts.poppins(
                                        color: AppTheme.textSecondary,
                                        fontSize: 14)),
                              ],
                            ),
                          )
                        : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: filtered.length + 1,
                    separatorBuilder: (_, i) => i < filtered.length - 1
                        ? const Divider(height: 1, color: AppTheme.border)
                        : const SizedBox.shrink(),
                    itemBuilder: (context, i) {
                      if (i < filtered.length) {
                        return PermohonanCard(item: filtered[i]);
                      }
                      // ── Item terakhir: info jumlah data ────────────
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                        child: Text(
                          'Menampilkan ${filtered.length} dari ${_list.length} data',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PermohonanCard (public — dipakai juga di RiwayatScreen)
// ══════════════════════════════════════════════════════════════════════════════
class PermohonanCard extends StatelessWidget {
  final Permohonan item;

  const PermohonanCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row atas: ikon + nama surat ──────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.description_outlined,
                        color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.jenisSurat,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.tanggalFormatted,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppTheme.border),
              const SizedBox(height: 10),

              // ── Row bawah: status + tombol lihat detail ───────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg(item.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.status,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor(item.status),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PermohonanDetailScreen(permohonan: item),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.visibility_outlined,
                            size: 14, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Lihat Detail',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Panel Notifikasi
// ══════════════════════════════════════════════════════════════════════════════
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
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _daftarNotifikasi.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppTheme.border),
              itemBuilder: (_, i) => _NotifItem(notif: _daftarNotifikasi[i]),
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          InkWell(
            onTap: () {
              onClose();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotifikasiScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text('Lihat Semua',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primary)),
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
    final bgColor   = notif.dibaca ? Colors.transparent : const Color(0xFFECF7F5);
    final iconBg    = notif.dibaca ? const Color(0xFFEEEEEE) : AppTheme.primaryLight;
    final iconColor = notif.dibaca ? AppTheme.textSecondary : AppTheme.primary;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Text(notif.judul,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text(notif.pesan,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.4)),
                const SizedBox(height: 5),
                Text(notif.waktu,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
