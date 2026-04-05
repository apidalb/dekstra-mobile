import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../beranda/home_screen.dart';
import 'register_screen.dart';

// ── Dummy credentials ─────────────────────────────────────────────────────────
// Simulasi database akun terdaftar untuk keperluan prototype.
// Ganti dengan integrasi API saat memasuki fase production.
class _DummyAccount {
  final String identifier; // NIK atau email
  final String password;
  final String nama;
  final String email;

  const _DummyAccount({
    required this.identifier,
    required this.password,
    required this.nama,
    required this.email,
  });
}

const List<_DummyAccount> _dummyAccounts = [
  _DummyAccount(
    identifier: 'user@desktra.com',
    password: 'Password1',
    nama: 'John Doe',
    email: 'user@desktra.com',
  ),
  _DummyAccount(
    identifier: '3201234567890001', // NIK 16 digit
    password: 'Password1',
    nama: 'John Doe',
    email: 'user@desktra.com',
  ),
];

// ── LoginScreen ───────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey             = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController  = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading       = false;

  // Pesan error kredensial — ditampilkan sebagai banner di atas form
  String? _loginError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validasi identifier: NIK (16 digit) atau email ────────────────────────
  String? _validateIdentifier(String? v) {
    if (v == null || v.isEmpty) {
      return 'NIK / Email tidak boleh kosong';
    }
    final trimmed = v.trim();
    final isEmail = trimmed.contains('@');

    if (isEmail) {
      // Validasi format email
      if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(trimmed)) {
        return 'Format email tidak valid';
      }
    } else {
      // Validasi NIK: hanya digit, tepat 16 karakter
      final digits = trimmed.replaceAll(RegExp(r'\D'), '');
      if (digits.length != 16) {
        return 'NIK harus 16 digit';
      }
    }
    return null;
  }

  // ── Validasi password dengan minimum length ───────────────────────────────
  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Kata sandi tidak boleh kosong';
    if (v.length < 8) return 'Kata sandi minimal 8 karakter';
    return null;
  }

  // ── Proses login dengan dummy credential check ────────────────────────────
  void _masuk() async {
    setState(() => _loginError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final identifier = _identifierController.text.trim();
    final password   = _passwordController.text;

    _DummyAccount? matched;
    try {
      matched = _dummyAccounts.firstWhere(
        (acc) => acc.identifier == identifier && acc.password == password,
      );
    } catch (_) {
      matched = null;
    }

    setState(() => _isLoading = false);

    if (matched == null) {
      setState(() {
        _loginError =
            'NIK/email atau kata sandi salah. Periksa kembali dan coba lagi.';
      });
      return;
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          userName: matched!.nama,
          userEmail: matched.email,
        ),
      ),
      (route) => false,
    );
  }


  // ── Dialog Lupa Kata Sandi ────────────────────────────────────────────────
  void _showForgotPasswordDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur lupa kata sandi belum tersedia.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: AppTheme.textSecondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Masuk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Text(
              'Masuk ke Akun Anda',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),

          // ── Form ──────────────────────────────────────────────────
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [

                  // ── Banner error kredensial ────────────────────────
                  if (_loginError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFE11D48), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _loginError!,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFFE11D48),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── NIK / Email ────────────────────────────────────
                  _label('NIK / Email', required: true),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(fontSize: 14),
                    onChanged: (_) {
                      if (_loginError != null) {
                        setState(() => _loginError = null);
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Masukkan NIK atau email Anda',
                    ),
                    validator: _validateIdentifier,
                  ),
                  const SizedBox(height: 16),

                  // ── Kata Sandi ─────────────────────────────────────
                  _label('Kata Sandi', required: true),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.poppins(fontSize: 14),
                    onChanged: (_) {
                      if (_loginError != null) {
                        setState(() => _loginError = null);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Masukkan kata sandi Anda',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: _validatePassword,
                  ),

                  // ── Lupa Kata Sandi (nonaktif — belum diimplementasi)
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _showForgotPasswordDialog(context),
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: GoogleFonts.poppins(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // ── Hint akun demo (hanya untuk prototype) ─────────
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppTheme.primary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Akun Demo',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'NIK      : 3201234567890001\n'
                          'Email    : user@desktra.com\n'
                          'Password : Password1',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.primaryDark,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Buttons ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _masuk,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('MASUK'),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: Text(
                        'Daftar',
                        style: GoogleFonts.poppins(
                          color: AppTheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary),
        children: [
          TextSpan(text: text),
          if (required)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
