import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

// ── Data model dummy notifikasi ───────────────────────────────────────────────
class _Notif {
  final int id;
  final String judul;
  final String pesan;
  final String waktu;
  bool dibaca;

  _Notif({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.waktu,
    this.dibaca = false,
  });
}

final List<_Notif> _dummyNotifikasi = [
  _Notif(id: 1, judul: 'Pengajuan Surat Berhasil',
      pesan: 'Pengajuan Surat Keterangan Usaha berhasil dikirim dan sedang menunggu verifikasi.',
      waktu: '2 menit lalu', dibaca: false),
  _Notif(id: 2, judul: 'Surat Diverifikasi RT',
      pesan: 'Pengajuan Surat Keterangan Usaha telah diverifikasi oleh RT dan diteruskan ke RW.',
      waktu: '10 menit lalu', dibaca: false),
  _Notif(id: 3, judul: 'Surat Diverifikasi RW',
      pesan: 'Pengajuan Surat Keterangan Usaha telah diverifikasi oleh RW dan diteruskan ke Admin Desa.',
      waktu: '1 jam lalu', dibaca: true),
  _Notif(id: 4, judul: 'Pengajuan Disetujui',
      pesan: 'Selamat! Pengajuan Permohonan Izin Keramaian telah disetujui oleh Admin Desa.',
      waktu: '1 hari lalu', dibaca: true),
  _Notif(id: 5, judul: 'Pengajuan Ditolak',
      pesan: 'Pengajuan Surat Domisili ditolak. Silakan lampirkan KK asli dan ajukan kembali.',
      waktu: '2 hari lalu', dibaca: true),
];

// ════════════════════════════════════════════════════════════════════════════
// NotifikasiScreen
// ════════════════════════════════════════════════════════════════════════════
class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  late final List<_Notif> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(_dummyNotifikasi);
  }

  int get _unreadCount => _list.where((n) => !n.dibaca).length;

  void _bacaSemua() {
    setState(() {
      for (final n in _list) { n.dibaca = true; }
    });
  }

  IconData _icon(String judul) {
    if (judul.contains('Disetujui')) return Icons.check_circle_outline;
    if (judul.contains('Ditolak'))   return Icons.cancel_outlined;
    if (judul.contains('Verifikasi')) return Icons.assignment_turned_in_outlined;
    return Icons.notifications_outlined;
  }

  Color _iconColor(String judul, bool dibaca) {
    if (dibaca) return AppTheme.textSecondary;
    if (judul.contains('Disetujui'))  return const Color(0xFF059669);
    if (judul.contains('Ditolak'))    return const Color(0xFFE11D48);
    if (judul.contains('Verifikasi')) return AppTheme.primary;
    return AppTheme.primary;
  }

  Color _iconBg(String judul, bool dibaca) {
    if (dibaca) return const Color(0xFFF3F4F6);
    if (judul.contains('Disetujui'))  return const Color(0xFFD1FAE5);
    if (judul.contains('Ditolak'))    return const Color(0xFFFFE4E6);
    return AppTheme.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _bacaSemua,
              child: Text(
                'Baca Semua',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: _list.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_off_outlined,
                      size: 52, color: AppTheme.border),
                  const SizedBox(height: 12),
                  Text('Tidak ada notifikasi',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: AppTheme.textSecondary)),
                ],
              ),
            )
          : Column(
              children: [
                // ── Info jumlah belum dibaca ───────────────────────
                if (_unreadCount > 0)
                  Container(
                    width: double.infinity,
                    color: AppTheme.primaryLight,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Text(
                      '$_unreadCount notifikasi belum dibaca',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // ── List notifikasi ────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _list.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppTheme.border),
                    itemBuilder: (_, i) {
                      final notif = _list[i];
                      return _NotifTile(
                        notif: notif,
                        iconData:  _icon(notif.judul),
                        iconColor: _iconColor(notif.judul, notif.dibaca),
                        iconBg:    _iconBg(notif.judul, notif.dibaca),
                        onTap: () {
                          if (!notif.dibaca) {
                            setState(() => notif.dibaca = true);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Satu item notifikasi ──────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final IconData iconData;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _NotifTile({
    required this.notif,
    required this.iconData,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notif.dibaca ? Colors.transparent : AppTheme.primaryLight.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ikon ──────────────────────────────────────────────
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),

            // ── Konten ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.judul,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: notif.dibaca
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      // ── Dot belum dibaca ───────────────────────
                      if (!notif.dibaca)
                        Container(
                          width: 8, height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 2),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.pesan,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notif.waktu,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
