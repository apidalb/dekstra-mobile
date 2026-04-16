import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
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
  final bool isActive; // completed or current

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
const _green  = Color(0xFF059669);
const _red    = Color(0xFFE11D48);
const _muted  = Color(0xFFD1D5DB);

int _statusIndex(String status) {
  switch (status) {
    case 'Menunggu Verifikasi': return 2;
    case 'Disetujui':
    case 'Ditolak':             return 5;
    default:                    return 2;
  }
}

String _fmtTs(DateTime d, {int addDays = 0, int h = 8, int m = 0}) {
  final t = d.add(Duration(days: addDays));
  return '${t.day.toString().padLeft(2,'0')}-'
         '${t.month.toString().padLeft(2,'0')}-'
         '${t.year} '
         '${h.toString().padLeft(2,'0')}:'
         '${m.toString().padLeft(2,'0')}:00';
}

List<_TimelineStep> _buildTimeline(Permohonan p) {
  final idx  = _statusIndex(p.status);
  final d    = p.tanggal;
  final isDitolak = p.status == 'Ditolak';

  bool done(int step)   => idx > step;
  bool active(int step) => idx >= step;

  Color clr(int step, Color c) => active(step) ? c : _muted;

  return [
    // ── 0: Pengajuan Belum Dikirim ───────────────────────────────────────
    _TimelineStep(
      title: 'Pengajuan Belum Dikirim',
      timestamp: _fmtTs(d, h: 8, m: 0),
      description: 'Pengajuan belum dikirim oleh pemohon.',
      iconBg: _grey,
      icon: Icons.schedule_outlined,
      isActive: true,
    ),

    // ── 1: Pengajuan Dikirim ─────────────────────────────────────────────
    _TimelineStep(
      title: 'Pengajuan Dikirim',
      timestamp: _fmtTs(d, h: 9, m: 30),
      description: 'Pengajuan sudah dikirim dan sedang menunggu verifikasi.',
      iconBg: _amber,
      icon: Icons.send_outlined,
      isActive: true,
    ),

    // ── 2: Verifikasi RT ──────────────────────────────────────────────────
    _TimelineStep(
      title: done(2) ? 'Diverifikasi RT' : 'Menunggu Verifikasi RT',
      timestamp: done(2) ? _fmtTs(d, addDays: 1, h: 7, m: 15) : null,
      description: done(2)
          ? 'Pengajuan telah diverifikasi oleh RT.'
          : 'Menunggu proses verifikasi oleh RT.',
      oleh: done(2) ? 'RT' : null,
      iconBg: clr(2, _orange),
      icon: Icons.assignment_turned_in_outlined,
      isActive: active(2),
    ),

    // ── 3: Verifikasi RW ──────────────────────────────────────────────────
    _TimelineStep(
      title: done(3) ? 'Diverifikasi RW' : 'Menunggu Verifikasi RW',
      timestamp: done(3) ? _fmtTs(d, addDays: 1, h: 8, m: 0) : null,
      description: done(3)
          ? 'Pengajuan telah diverifikasi oleh RW.'
          : 'Menunggu proses verifikasi oleh RW.',
      oleh: done(3) ? 'RW' : null,
      iconBg: clr(3, _blue),
      icon: Icons.assignment_turned_in_outlined,
      isActive: active(3),
    ),

    // ── 4: Verifikasi Admin ───────────────────────────────────────────────
    _TimelineStep(
      title: done(4) ? 'Diverifikasi Admin' : 'Menunggu Verifikasi Admin',
      timestamp: done(4) ? _fmtTs(d, addDays: 1, h: 8, m: 30) : null,
      description: done(4)
          ? 'Pengajuan telah diverifikasi oleh Admin Desa.'
          : 'Menunggu proses verifikasi oleh Admin Desa.',
      oleh: done(4) ? 'Admin' : null,
      iconBg: clr(4, _purple),
      icon: Icons.assignment_turned_in_outlined,
      isActive: active(4),
    ),

    // ── 5: Final ──────────────────────────────────────────────────────────
    _TimelineStep(
      title: !active(5)
          ? 'Menunggu Keputusan'
          : (isDitolak ? 'Pengajuan Ditolak' : 'Pengajuan Disetujui'),
      timestamp: active(5)
          ? _fmtTs(d, addDays: 1, h: isDitolak ? 8 : 9, m: isDitolak ? 49 : 0)
          : null,
      description: !active(5)
          ? 'Menunggu keputusan akhir dari Admin Desa.'
          : (isDitolak
              ? 'Pengajuan ditolak. Silakan periksa persyaratan dan ajukan kembali.'
              : 'Selamat! Pengajuan Anda telah disetujui.'),
      iconBg: !active(5) ? _muted : (isDitolak ? _red : _green),
      icon: !active(5)
          ? Icons.hourglass_empty_outlined
          : (isDitolak ? Icons.cancel_outlined : Icons.check_circle_outline),
      isActive: active(5),
    ),
  ];
}

// ════════════════════════════════════════════════════════════════════════════
// PermohonanDetailScreen
// ════════════════════════════════════════════════════════════════════════════
class PermohonanDetailScreen extends StatelessWidget {
  final Permohonan permohonan;
  const PermohonanDetailScreen({super.key, required this.permohonan});

  @override
  Widget build(BuildContext context) {
    final steps    = _buildTimeline(permohonan);
    final statusBg = _statusBgColor(permohonan.status);
    final statusFg = _statusFgColor(permohonan.status);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Detail Permohonan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [

          // ── Header card ────────────────────────────────────────────
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
                // Judul
                Text(
                  permohonan.jenisSurat,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                // ID
                Text(
                  permohonan.nomorPermohonan.isNotEmpty
                      ? '#${permohonan.nomorPermohonan}'
                      : '#${permohonan.id}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppTheme.border),
                const SizedBox(height: 14),

                // Status
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
                      permohonan.status,
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

                // Tanggal
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Tanggal Pengajuan: ${permohonan.tanggalFormatted}',
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

                // Timeline items
                ...List.generate(steps.length, (i) {
                  return _buildTimelineItem(
                    step: steps[i],
                    isLast: i == steps.length - 1,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Single timeline item ─────────────────────────────────────────────────
  Widget _buildTimelineItem({
    required _TimelineStep step,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Left: icon + connecting line ─────────────────────────────
        SizedBox(
          width: 44,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: step.iconBg.withOpacity(step.isActive ? 0.15 : 0.08),
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

        // ── Right: content ────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + timestamp on same row
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

                // Description
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

                // Oleh [role]
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

  // ── Status color helpers (mirrored from home_screen) ─────────────────────
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
