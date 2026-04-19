import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import 'home_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// Model timeline step
// ════════════════════════════════════════════════════════════════════════════
class _TimelineStep {
  final String title;
  final String? timestamp;
  final String description;
  final String? oleh;
  final Color iconBg;
  final IconData icon;
  final bool isActive;

  const _TimelineStep({
    required this.title,
    this.timestamp,
    required this.description,
    this.oleh,
    required this.iconBg,
    required this.icon,
    required this.isActive,
  });
}

// ════════════════════════════════════════════════════════════════════════════
// Helpers
// ════════════════════════════════════════════════════════════════════════════
const _grey   = Color(0xFF6B7280);
const _amber  = Color(0xFFF59E0B);
const _orange = Color(0xFFD97706);
const _blue   = Color(0xFF2563EB);
const _purple = Color(0xFF7C3AED);
const _red    = Color(0xFFE11D48);
const _cyan   = Color(0xFF0891B2);
const _muted  = Color(0xFFD1D5DB);

String _fmtDateTime(String isoStr) {
  final dt = DateTime.parse(isoStr).toLocal();
  return '${dt.day.toString().padLeft(2, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';
}

Color _actorColor(String actor) {
  switch (actor) {
    case 'RT':          return _orange;
    case 'RW':          return _blue;
    case 'ADMIN':       return _purple;
    case 'Kepala Desa': return _cyan;
    default:            return _grey;
  }
}

_TimelineStep _stepFromApi(Map<String, dynamic> r) {
  final aksi        = r['status'] as String;
  final actor       = r['actor']  as String;
  final description = r['description'] as String? ?? '-';
  final tsRaw       = r['timestamp'] as String?;
  final timestamp   = tsRaw != null ? _fmtDateTime(tsRaw) : null;

  switch (aksi) {
    case 'Ajukan':
      return _TimelineStep(
        title:       'Pengajuan Diajukan',
        timestamp:   timestamp,
        description: description == '-'
            ? 'Pengajuan sudah dikirim dan sedang menunggu verifikasi.'
            : description,
        iconBg:   _amber,
        icon:     Icons.send_outlined,
        isActive: true,
      );
    case 'Setuju':
      return _TimelineStep(
        title:       'Disetujui oleh $actor',
        timestamp:   timestamp,
        description: description == '-'
            ? 'Pengajuan telah diverifikasi oleh $actor.'
            : description,
        oleh:     actor,
        iconBg:   _actorColor(actor),
        icon:     Icons.assignment_turned_in_outlined,
        isActive: true,
      );
    case 'Tolak':
      return _TimelineStep(
        title:       'Ditolak oleh $actor',
        timestamp:   timestamp,
        description: description == '-'
            ? 'Pengajuan ditolak oleh $actor. Periksa catatan dan ajukan kembali.'
            : description,
        oleh:     actor,
        iconBg:   _red,
        icon:     Icons.cancel_outlined,
        isActive: true,
      );
    default:
      return _TimelineStep(
        title:       aksi,
        timestamp:   timestamp,
        description: description,
        oleh:        actor,
        iconBg:      _grey,
        icon:        Icons.info_outline,
        isActive:    true,
      );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PermohonanDetailScreen
// ════════════════════════════════════════════════════════════════════════════
class PermohonanDetailScreen extends StatefulWidget {
  final Permohonan permohonan;
  const PermohonanDetailScreen({super.key, required this.permohonan});

  @override
  State<PermohonanDetailScreen> createState() => _PermohonanDetailScreenState();
}

class _PermohonanDetailScreenState extends State<PermohonanDetailScreen> {
  List<_TimelineStep>? _steps;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final nomor = widget.permohonan.nomorPermohonan;
    if (nomor.isEmpty) {
      if (mounted) setState(() { _steps = []; _isLoading = false; });
      return;
    }
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final data    = await ApiService.getRiwayatPengajuanDetail(nomor);
      final riwayat = data['riwayat'] as List<dynamic>;
      if (mounted) {
        setState(() {
          _steps = riwayat
              .map((r) => _stepFromApi(r as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _errorMsg = e.message; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _errorMsg = 'Gagal memuat riwayat'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p         = widget.permohonan;
    final statusBg  = _statusBgColor(p.status);
    final statusFg  = _statusFgColor(p.status);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Detail Permohonan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDetail,
        color: AppTheme.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [

            // ── Header card ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.jenisSurat,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.nomorPermohonan.isNotEmpty
                        ? '#${p.nomorPermohonan}'
                        : '#${p.id}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppTheme.border),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Status',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        p.status,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusFg,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppTheme.border),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Tanggal Pengajuan: ${p.tanggalFormatted}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Timeline card ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Status',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppTheme.border),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_errorMsg != null)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_outlined,
                              size: 40, color: AppTheme.border),
                          const SizedBox(height: 8),
                          Text(_errorMsg!,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _loadDetail,
                            icon: const Icon(Icons.refresh, size: 14),
                            label: Text('Coba lagi',
                                style: GoogleFonts.poppins(fontSize: 12)),
                          ),
                        ],
                      ),
                    )
                  else if (_steps == null || _steps!.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Belum ada riwayat tersedia',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppTheme.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_steps!.length, (i) {
                      return _buildTimelineItem(
                        step: _steps![i],
                        isLast: i == _steps!.length - 1,
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Single timeline item ────────────────────────────────────────────────
  Widget _buildTimelineItem({
    required _TimelineStep step,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: step.isActive
                      ? step.iconBg.withValues(alpha: 0.15)
                      : step.iconBg.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step.icon,
                  size: 20,
                  color: step.isActive ? step.iconBg : _muted,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 56,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      step.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: step.isActive
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                    if (step.timestamp != null)
                      Text(
                        step.timestamp!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: step.isActive
                        ? AppTheme.textSecondary
                        : const Color(0xFFD1D5DB),
                    height: 1.4,
                  ),
                ),
                if (step.oleh != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'oleh ${step.oleh}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Status color helpers ────────────────────────────────────────────────
  Color _statusBgColor(String s) {
    switch (s) {
      case 'Menunggu Verifikasi': return const Color(0xFFFEF3C7);
      case 'Disetujui':           return const Color(0xFFD1FAE5);
      case 'Ditolak':             return const Color(0xFFFFE4E6);
      default:                    return AppTheme.primaryLight;
    }
  }

  Color _statusFgColor(String s) {
    switch (s) {
      case 'Menunggu Verifikasi': return const Color(0xFFD97706);
      case 'Disetujui':           return const Color(0xFF059669);
      case 'Ditolak':             return const Color(0xFFE11D48);
      default:                    return AppTheme.primary;
    }
  }
}
