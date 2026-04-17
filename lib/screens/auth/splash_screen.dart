import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../beranda/home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // true = cek selesai & tidak ada sesi → tampilkan tombol landing
  bool _showLanding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Biarkan animasi selesai minimal sebelum navigasi / tampilkan tombol
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final token = await getAccessToken();
    if (token == null) {
      if (mounted) setState(() => _showLanding = true);
      return;
    }

    // Coba ambil profil dengan token yang ada
    try {
      final profil = await ApiService.getProfil();
      if (!mounted) return;
      _navigateToHome(profil);
      return;
    } on ApiException catch (e) {
      if (e.statusCode != 401) {
        if (mounted) setState(() => _showLanding = true);
        return;
      }
    } catch (_) {
      if (mounted) setState(() => _showLanding = true);
      return;
    }

    // Access token expired (401) — coba refresh
    final refreshed = await ApiService.refreshAccessToken();
    if (!refreshed) {
      if (mounted) setState(() => _showLanding = true);
      return;
    }

    // Retry dengan token baru
    try {
      final profil = await ApiService.getProfil();
      if (!mounted) return;
      _navigateToHome(profil);
    } catch (_) {
      if (mounted) setState(() => _showLanding = true);
    }
  }

  void _navigateToHome(Map<String, dynamic> profil) {
    final nama  = profil['nama_lengkap'] as String? ?? '';
    final email = profil['email']        as String? ?? '';
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(userName: nama, userEmail: email),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // ── Logo ─────────────────────────────────────────
                      Image.asset('assets/images/Logo.png', width: 240, height: 240),
                      const SizedBox(height: 0),
                      Text(
                        'DEKSTRA',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        "Ayo Mulai!",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Layanan surat desa digital yang mudah, cepat, dan terpercaya.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              FadeTransition(
                opacity: _fadeAnimation,
                child: _showLanding
                    ? Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen())),
                            child: const Text('MASUK'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const RegisterScreen())),
                            child: const Text('DAFTAR'),
                          ),
                        ],
                      )
                    : const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.primary,
                        ),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}


