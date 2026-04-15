import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../beranda/home_screen.dart';
import 'register_screen.dart';

// ── LoginScreen ───────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Step: 0 = Masukkan Kredensial, 1 = Verifikasi OTP
  int _step = 0;

  final _credFormKey = GlobalKey<FormState>();
  final _otpFormKey  = GlobalKey<FormState>();

  final _identifierController = TextEditingController();
  final _passwordController   = TextEditingController();
  final _otpController        = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading       = false;

  // Pesan error — ditampilkan sebagai banner merah
  String? _errorMessage;

  // OTP yang dikembalikan dari backend (sementara ditampilkan di dev hint)
  String? _receivedOtp;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ── Validasi identifier: NIK (16 digit) atau email ────────────────────────
  String? _validateIdentifier(String? v) {
    if (v == null || v.isEmpty) return 'NIK / Email tidak boleh kosong';
    final trimmed = v.trim();
    if (trimmed.contains('@')) {
      if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(trimmed)) {
        return 'Format email tidak valid';
      }
    } else {
      final digits = trimmed.replaceAll(RegExp(r'\D'), '');
      if (digits.length != 16) return 'NIK harus 16 digit';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Kata sandi tidak boleh kosong';
    return null;
  }

  String? _validateOtp(String? v) {
    if (v == null || v.isEmpty) return 'Kode OTP tidak boleh kosong';
    if (v.replaceAll(RegExp(r'\D'), '').length != 6) {
      return 'Kode OTP harus 6 digit';
    }
    return null;
  }

  // ── Step 1 — Request OTP ─────────────────────────────────────────────────
  void _requestOtp() async {
    setState(() => _errorMessage = null);
    if (!_credFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final identifier = _identifierController.text.trim();
      final password   = _passwordController.text;

      final res = await ApiService.requestLoginOtp(
        identifier: identifier,
        password  : password,
      );

      if (!mounted) return;
      setState(() {
        // Backend mengembalikan OTP di response body (dev mode)
        _receivedOtp  = res['otp']?.toString();
        _step         = 1;
        _errorMessage = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage =
          'Gagal terhubung ke server. Periksa koneksi internet Anda.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Step 2 — Verifikasi OTP & Login ──────────────────────────────────────
  void _verifyOtpAndLogin() async {
    setState(() => _errorMessage = null);
    if (!_otpFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = await ApiService.login(
        identifier: _identifierController.text.trim(),
        password  : _passwordController.text,
        otp       : _otpController.text.trim(),
      );

      if (!mounted) return;
      // Token & user info sudah disimpan di ApiService.login()
      final email = data['email'] as String? ?? '';
      final nik   = data['nik']   as String? ?? '';

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userName : email.isNotEmpty ? email : nik,
            userEmail: email,
          ),
        ),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage =
          'Gagal terhubung ke server. Periksa koneksi internet Anda.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Kembali ke Step 1 ─────────────────────────────────────────────────────
  void _backToCredentials() {
    setState(() {
      _step         = 0;
      _errorMessage = null;
      _otpController.clear();
    });
  }

  // ── Kirim ulang OTP ───────────────────────────────────────────────────────
  void _resendOtp() async {
    setState(() {
      _errorMessage = null;
      _otpController.clear();
    });

    try {
      final res = await ApiService.requestLoginOtp(
        identifier: _identifierController.text.trim(),
        password  : _passwordController.text,
      );
      if (mounted) setState(() => _receivedOtp = res['otp']?.toString());
    } catch (_) {}

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Kode OTP baru telah dikirim ke email Anda.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Lupa Kata Sandi ───────────────────────────────────────────────────────
  void _onForgotPassword() {
    // TODO: Navigasi ke ForgotPasswordScreen (2-step: email → OTP → password baru)
    // POST /auth/otp/request/reset-password/  →  POST /auth/otp/verify/reset-password/
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

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Masuk'),
        leading: _step == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: _isLoading ? null : _backToCredentials,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Column(
        children: [
          // ── Step Indicator ─────────────────────────────────────────
          _StepIndicator(currentStep: _step),

          // ── Form ───────────────────────────────────────────────────
          Expanded(
            child: _step == 0
                ? _buildCredentialsForm()
                : _buildOtpForm(),
          ),

          // ── Bottom Buttons ─────────────────────────────────────────
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Step 1 Form ───────────────────────────────────────────────────────────
  Widget _buildCredentialsForm() {
    return Form(
      key: _credFormKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _errorBanner(),

          // NIK / Email
          _label('NIK / Email', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _identifierController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(fontSize: 14),
            onChanged: (_) {
              if (_errorMessage != null) setState(() => _errorMessage = null);
            },
            decoration: const InputDecoration(
              hintText: 'Masukkan NIK atau email Anda',
            ),
            validator: _validateIdentifier,
          ),
          const SizedBox(height: 16),

          // Kata Sandi
          _label('Kata Sandi', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.poppins(fontSize: 14),
            onChanged: (_) {
              if (_errorMessage != null) setState(() => _errorMessage = null);
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
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: _validatePassword,
          ),

          // Lupa Kata Sandi
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _onForgotPassword,
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

        ],
      ),
    );
  }

  // ── Step 2 Form ───────────────────────────────────────────────────────────
  Widget _buildOtpForm() {
    return Form(
      key: _otpFormKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _errorBanner(),

          // Penjelasan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.mark_email_read_outlined,
                    color: AppTheme.primary, size: 36),
                const SizedBox(height: 12),
                Text(
                  'Kode OTP Telah Dikirim',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kami mengirim kode verifikasi 6 digit ke email yang terdaftar pada akun Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Input OTP
          _label('Kode OTP', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 8,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              if (_errorMessage != null) setState(() => _errorMessage = null);
            },
            decoration: InputDecoration(
              hintText: '------',
              hintStyle: GoogleFonts.poppins(
                fontSize: 22,
                letterSpacing: 8,
                color: AppTheme.textSecondary.withValues(alpha: 0.4),
              ),
              counterText: '',
            ),
            validator: _validateOtp,
          ),
          const SizedBox(height: 12),

          // Kirim ulang OTP
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tidak menerima kode? ',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
              GestureDetector(
                onTap: _isLoading ? null : _resendOtp,
                child: Text(
                  'Kirim Ulang',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Dev hint: tampilkan OTP yang diterima dari backend (hanya saat development)
          if (_receivedOtp != null) ...[
            const SizedBox(height: 20),
            _demoHint(
              children: [
                Text(
                  'OTP (Development) : $_receivedOtp',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.primaryDark,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : (_step == 0 ? _requestOtp : _verifyOtpAndLogin),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(_step == 0 ? 'KIRIM OTP' : 'MASUK'),
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
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _errorBanner() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Column(
      children: [
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
                  _errorMessage!,
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
    );
  }

  Widget _demoHint({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
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
          ...children,
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
            const TextSpan(
                text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}

// ── Step Indicator ─────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;

  static const _steps = ['Masukkan\nKredensial', 'Verifikasi\nOTP'];

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIndex = i ~/ 2;
            final done = stepIndex < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? AppTheme.primary : AppTheme.border,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isActive = stepIndex == currentStep;
          final isDone   = stepIndex < currentStep;
          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isActive || isDone)
                      ? AppTheme.primary
                      : AppTheme.border,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '${stepIndex + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _steps[stepIndex],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
