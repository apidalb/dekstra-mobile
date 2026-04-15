import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'profil_screen.dart';

class AkunScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const AkunScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header (konsisten dengan dashboard) ──────────────────────
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                      initial,
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
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),

          // ── Menu items ───────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      _menuItem(
                        icon: Icons.person_outline,
                        title: 'Akun Saya',
                        subtitle: 'Lihat informasi akun Anda',
                        showDivider: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfilScreen(
                              userName: userName,
                              userEmail: userEmail,
                            ),
                          ),
                        ),
                      ),
                      _menuItem(
                        icon: Icons.logout,
                        title: 'Keluar',
                        subtitle: 'Keluar dari akun ini',
                        showDivider: false,
                        isDestructive: true,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : AppTheme.primary;
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withOpacity(0.1)
                  : AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDestructive ? Colors.red : AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(
                fontSize: 12, color: AppTheme.textSecondary),
          ),
          trailing: Icon(Icons.arrow_forward_ios,
              size: 14,
              color: isDestructive
                  ? Colors.red.withOpacity(0.5)
                  : AppTheme.textSecondary),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(height: 1, indent: 70, color: AppTheme.border),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur keluar belum tersedia.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: AppTheme.textSecondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
