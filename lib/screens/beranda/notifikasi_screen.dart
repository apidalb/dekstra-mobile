import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

// ── Model ─────────────────────────────────────────────────────────────────────
class NotifikasiModel {
  final int id;
  final int tipe;
  final String judul;
  final String pesan;
  bool sudahDibaca;
  final DateTime createdAt;
  final int? permohonanId;

  NotifikasiModel({
    required this.id,
    required this.tipe,
    required this.judul,
    required this.pesan,
    required this.sudahDibaca,
    required this.createdAt,
    this.permohonanId,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id:           json['id'] as int,
      tipe:         json['tipe'] as int,
      judul:        json['judul'] as String,
      pesan:        json['pesan'] as String,
      sudahDibaca:  json['sudah_dibaca'] as bool,
      createdAt:    DateTime.parse(json['created_at'] as String).toLocal(),
      permohonanId: json['permohonan'] as int?,
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
String relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari lalu';
  return '${(diff.inDays / 7).floor()} minggu lalu';
}

IconData notifIcon(int tipe) {
  switch (tipe) {
    case 6: return Icons.cancel_outlined;
    case 7: return Icons.check_circle_outline;
    default: return Icons.assignment_turned_in_outlined;
  }
}

Color notifIconColor(int tipe, bool dibaca) {
  if (dibaca) return AppTheme.textSecondary;
  switch (tipe) {
    case 6: return const Color(0xFFE11D48);
    case 7: return const Color(0xFF059669);
    default: return AppTheme.primary;
  }
}

Color notifIconBg(int tipe, bool dibaca) {
  if (dibaca) return const Color(0xFFF3F4F6);
  switch (tipe) {
    case 6: return const Color(0xFFFFE4E6);
    case 7: return const Color(0xFFD1FAE5);
    default: return AppTheme.primaryLight;
  }
}

// ════════════════════════════════════════════════════════════════════════════
// NotifikasiScreen
// ════════════════════════════════════════════════════════════════════════════
class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  List<NotifikasiModel> _list = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final data = await ApiService.getNotifikasi();
      if (mounted) {
        setState(() {
          _list = data.map((j) => NotifikasiModel.fromJson(j)).toList();
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _errorMsg = e.message; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _errorMsg = 'Gagal terhubung ke server'; _isLoading = false; });
    }
  }

  int get _unreadCount => _list.where((n) => !n.sudahDibaca).length;

  Future<void> _markRead(NotifikasiModel notif) async {
    if (notif.sudahDibaca) return;
    try {
      await ApiService.markNotifikasiRead(notif.id);
      if (mounted) setState(() => notif.sudahDibaca = true);
    } catch (_) {}
  }

  Future<void> _bacaSemua() async {
    final unread = _list.where((n) => !n.sudahDibaca).toList();
    for (final n in unread) {
      try {
        await ApiService.markNotifikasiRead(n.id);
        if (mounted) setState(() => n.sudahDibaca = true);
      } catch (_) {}
    }
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
          if (!_isLoading && _unreadCount > 0)
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
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMsg != null
                ? LayoutBuilder(
                    builder: (_, c) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: c.maxHeight,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off_outlined,
                                  size: 48, color: AppTheme.border),
                              const SizedBox(height: 12),
                              Text(_errorMsg!,
                                  style: GoogleFonts.poppins(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: _load,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: Text('Coba lagi',
                                    style: GoogleFonts.poppins(fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : _list.isEmpty
                    ? LayoutBuilder(
                        builder: (_, c) => SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: c.maxHeight,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.notifications_off_outlined,
                                      size: 52, color: AppTheme.border),
                                  const SizedBox(height: 12),
                                  Text('Tidak ada notifikasi',
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: [
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
                          Expanded(
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: _list.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1, color: AppTheme.border),
                              itemBuilder: (_, i) {
                                final notif = _list[i];
                                return _NotifTile(
                                  notif: notif,
                                  onTap: () => _markRead(notif),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}

// ── Satu item notifikasi ──────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final NotifikasiModel notif;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconData  = notifIcon(notif.tipe);
    final iconColor = notifIconColor(notif.tipe, notif.sudahDibaca);
    final iconBg    = notifIconBg(notif.tipe, notif.sudahDibaca);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notif.sudahDibaca
            ? Colors.transparent
            : AppTheme.primaryLight.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
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
                            fontWeight: notif.sudahDibaca
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!notif.sudahDibaca)
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
                    relativeTime(notif.createdAt),
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
