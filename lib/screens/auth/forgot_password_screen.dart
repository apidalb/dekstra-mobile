import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Step: 0 = Masukkan Email, 1 = Verifikasi OTP + Password Baru
  int _step = 0;

  final _emailFormKey    = GlobalKey<FormState>();
  final _otpFormKey      = GlobalKey<FormState>();

  final _emailController       = TextEditingController();
  final _otpController         = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController     = TextEditingController();

  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;

  String? _errorMessage;

  // Timer OTP (5 menit) dan cooldown kirim ulang (30 detik)
  Timer? _otpTimer;
  Timer? _resendTimer;
  int _otpSecondsLeft = 300;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _otpTimer?.cancel();
    _resendTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    _otpSecondsLeft = 300;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_otpSecondsLeft > 0) {
          _otpSecondsLeft--;
        } else {
          t.cancel();
        }
      });
    });
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    _resendCooldown = 30;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  // ── Validasi ──────────────────────────────────────────────────────────────
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validateOtp(String? v) {
    if (v == null || v.isEmpty) return 'Kode OTP tidak boleh kosong';
    if (v.replaceAll(RegExp(r'\D'), '').length != 6) {
      return 'Kode OTP harus 6 digit';
    }
    return null;
  }

  String? _validateNewPassword(String? v) {
    if (v == null || v.isEmpty) return 'Kata sandi tidak boleh kosong';
    if (v.length < 8) return 'Minimal 8 karakter';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Konfirmasi kata sandi tidak boleh kosong';
    if (v != _newPasswordController.text) return 'Kata sandi tidak cocok';
    return null;
  }

  // ── Step 1 — Request OTP ─────────────────────────────────────────────────
  void _requestOtp() async {
    setState(() => _errorMessage = null);
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.requestResetPasswordOtp(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _step         = 1;
        _errorMessage = null;
      });
      _startOtpTimer();
      _startResendCooldown();
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

  // ── Step 2 — Verifikasi OTP & Ganti Password ─────────────────────────────
  void _verifyAndReset() async {
    setState(() => _errorMessage = null);
    if (!_otpFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.verifyResetPasswordOtp(
        email      : _emailController.text.trim(),
        otp        : _otpController.text.trim(),
        newPassword: _newPasswordController.text,
      );
      if (!mounted) return;
      _otpTimer?.cancel();
      _resendTimer?.cancel();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kata sandi berhasil diperbarui. Silakan masuk kembali.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
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

  // ── Kembali ke Step 0 ─────────────────────────────────────────────────────
  void _backToEmail() {
    _otpTimer?.cancel();
    _resendTimer?.cancel();
    setState(() {
      _step           = 0;
      _errorMessage   = null;
      _otpSecondsLeft = 300;
      _resendCooldown = 0;
      _otpController.clear();
      _newPasswordController.clear();
      _confirmController.clear();
    });
  }

  // ── Kirim Ulang OTP ───────────────────────────────────────────────────────
  void _resendOtp() async {
    if (_resendCooldown > 0) return;
    setState(() {
      _errorMessage = null;
      _otpController.clear();
    });
    try {
      await ApiService.requestResetPasswordOtp(
        email: _emailController.text.trim(),
      );
    } catch (_) {}

    if (!mounted) return;
    _startOtpTimer();
    _startResendCooldown();
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

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lupa Kata Sandi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: _isLoading
              ? null
              : (_step == 1 ? _backToEmail : () => Navigator.pop(context)),
        ),
      ),
      body: Column(
        children: [
          _StepIndicatorFP(currentStep: _step),
          Expanded(
            child: _step == 0 ? _buildEmailForm() : _buildOtpForm(),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Step 0 Form — Email ───────────────────────────────────────────────────
  Widget _buildEmailForm() {
    return Form(
      key: _emailFormKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _errorBanner(),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.lock_reset_outlined,
                    color: AppTheme.primary, size: 36),
                const SizedBox(height: 12),
                Text(
                  'Atur Ulang Kata Sandi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Masukkan email yang terdaftar pada akun Anda. Kami akan mengirimkan kode OTP untuk memverifikasi identitas Anda.',
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

          _label('Email', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(fontSize: 14),
            onChanged: (_) {
              if (_errorMessage != null) setState(() => _errorMessage = null);
            },
            decoration: const InputDecoration(
              hintText: 'Masukkan email Anda',
            ),
            validator: _validateEmail,
          ),
        ],
      ),
    );
  }

  // ── Step 1 Form — OTP + Password Baru ────────────────────────────────────
  Widget _buildOtpForm() {
    return Form(
      key: _otpFormKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _errorBanner(),

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
                  'Kami mengirim kode verifikasi 6 digit ke ${_emailController.text.trim()}',
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
          const SizedBox(height: 16),

          // Countdown OTP
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined,
                  size: 14,
                  color: _otpSecondsLeft > 0
                      ? AppTheme.primary
                      : AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                _otpSecondsLeft > 0
                    ? 'Gunakan kode sebelum: '
                        '${(_otpSecondsLeft ~/ 60).toString().padLeft(2, '0')}:'
                        '${(_otpSecondsLeft % 60).toString().padLeft(2, '0')}'
                    : 'Kode OTP telah kedaluwarsa',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _otpSecondsLeft > 0
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Kirim ulang OTP
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Belum menerima kode OTP? ',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
              GestureDetector(
                onTap: (_isLoading || _resendCooldown > 0) ? null : _resendOtp,
                child: Text(
                  _resendCooldown > 0
                      ? 'Kirim Ulang (${_resendCooldown}s)'
                      : 'Kirim Ulang',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _resendCooldown > 0
                        ? AppTheme.textSecondary
                        : AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Divider(color: AppTheme.border),
          const SizedBox(height: 20),

          // Kata sandi baru
          _label('Kata Sandi Baru', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Minimal 8 karakter',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            validator: _validateNewPassword,
          ),
          const SizedBox(height: 16),

          // Konfirmasi kata sandi
          _label('Konfirmasi Kata Sandi', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Ulangi kata sandi baru',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: _validateConfirm,
          ),
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
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : (_step == 0 ? _requestOtp : _verifyAndReset),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(_step == 0 ? 'KIRIM OTP' : 'SIMPAN KATA SANDI'),
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

// ── Step Indicator ─────────────────────────────────────────────────────────────
class _StepIndicatorFP extends StatelessWidget {
  final int currentStep;

  static const _steps = ['Masukkan\nEmail', 'Verifikasi\nOTP'];

  const _StepIndicatorFP({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final done = (i ~/ 2) < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? AppTheme.primary : AppTheme.border,
              ),
            );
          }
          final idx      = i ~/ 2;
          final isActive = idx == currentStep;
          final isDone   = idx < currentStep;
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
                          '${idx + 1}',
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
                _steps[idx],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppTheme.primary : AppTheme.textSecondary,
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
