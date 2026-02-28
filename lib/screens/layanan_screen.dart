import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LayananScreen extends StatelessWidget {
  const LayananScreen({super.key});

  static const List<Map<String, dynamic>> _layanan = [
    {
      'no': 1,
      'title': 'Pilih jenis surat yang dibuat',
      'desc': 'Tentukan jenis surat administrasi yang Anda butuhkan',
      'icon': Icons.list_alt_outlined,
    },
    {
      'no': 2,
      'title': 'Isi form surat yang akan dibuat',
      'desc': 'Lengkapi data diri dan informasi yang diperlukan',
      'icon': Icons.edit_note_outlined,
    },
    {
      'no': 3,
      'title': 'Surat yang diinginkan akan segera diproses',
      'desc': 'Tunggu konfirmasi dan unduh surat Anda',
      'icon': Icons.check_circle_outline,
    },
  ];

  static const List<Map<String, String>> _suratTypes = [
    {'name': 'Surat Keterangan Domisili', 'icon': '🏠'},
    {'name': 'Surat Keterangan Tidak Mampu', 'icon': '📋'},
    {'name': 'Surat Keterangan Usaha', 'icon': '💼'},
    {'name': 'Surat Pengantar KTP', 'icon': '🪪'},
    {'name': 'Surat Keterangan Kelahiran', 'icon': '👶'},
    {'name': 'Surat Keterangan Kematian', 'icon': '📄'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Layanan',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cara mudah membuat surat administrasi',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // Steps
          ...List.generate(
            _layanan.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _StepCard(
                number: _layanan[i]['no'],
                title: _layanan[i]['title'],
                desc: _layanan[i]['desc'],
                icon: _layanan[i]['icon'],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Pilih Jenis Surat
          Text(
            'Pilih Jenis Surat',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: _suratTypes
                .map((s) => _SuratCard(
                      name: s['name']!,
                      icon: s['icon']!,
                      onTap: () => _showSuratDialog(context, s['name']!),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showSuratDialog(BuildContext context, String suratName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SuratFormSheet(suratName: suratName),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final String desc;
  final IconData icon;

  const _StepCard({
    required this.number,
    required this.title,
    required this.desc,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: AppTheme.primary.withOpacity(0.5), size: 28),
        ],
      ),
    );
  }
}

class _SuratCard extends StatelessWidget {
  final String name;
  final String icon;
  final VoidCallback onTap;

  const _SuratCard({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuratFormSheet extends StatefulWidget {
  final String suratName;
  const _SuratFormSheet({required this.suratName});

  @override
  State<_SuratFormSheet> createState() => _SuratFormSheetState();
}

class _SuratFormSheetState extends State<_SuratFormSheet> {
  final _keperluan = TextEditingController();
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: _submitted
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle,
                    color: AppTheme.primary, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Permohonan Diajukan!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.suratName} Anda sedang diproses. Kami akan memberitahu Anda setelah surat siap.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Selesai'),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.suratName,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Keperluan',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _keperluan,
                  maxLines: 3,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: const InputDecoration(
                      hintText: 'Jelaskan keperluan surat ini'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => setState(() => _submitted = true),
                  child: const Text('Ajukan Surat'),
                ),
              ],
            ),
    );
  }
}
