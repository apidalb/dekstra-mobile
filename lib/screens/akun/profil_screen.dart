import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Map<String, dynamic>? _profil;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final data = await ApiService.getProfil();
      setState(() { _profil = data; _isLoading = false; });
    } on ApiException catch (e) {
      setState(() { _errorMsg = e.message; _isLoading = false; });
    } catch (_) {
      setState(() { _errorMsg = 'Gagal terhubung ke server'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_outlined,
                          size: 48, color: AppTheme.border),
                      const SizedBox(height: 12),
                      Text(_errorMsg!,
                          style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary, fontSize: 13),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _loadProfil,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: Text('Coba lagi',
                            style: GoogleFonts.poppins(fontSize: 13)),
                      ),
                    ],
                  ),
                )
              : _buildContent(_profil!),
    );
  }

  Widget _buildContent(Map<String, dynamic> p) {
    final nama  = p['nama_lengkap'] as String? ?? '';
    final email = p['email'] as String? ?? '';

    final parts  = nama.trim().split(' ');
    final avatar = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (nama.isNotEmpty ? nama[0].toUpperCase() : 'U');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [

        // ── Avatar + nama + email ────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDeco(),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(avatar,
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 3),
                    Text(email,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppTheme.textSecondary),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        p['peran'] as String? ?? 'Warga',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Informasi Pribadi ────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDeco(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informasi Pribadi',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 14),
              const Divider(color: AppTheme.border, height: 1),
              const SizedBox(height: 14),
              _infoField('Nomor KK', p['nomor_kk']),
              _infoField('NIK', p['nik']),
              _infoField('Nama Lengkap', p['nama_lengkap']),
              _infoField('Jenis Kelamin', p['jenis_kelamin']),
              _infoField('Tempat Lahir', p['tempat_lahir']),
              _infoField('Tanggal Lahir', p['tanggal_lahir']),
              _infoField('Alamat', p['alamat'], isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Informasi Akun ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDeco(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informasi Akun',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 14),
              const Divider(color: AppTheme.border, height: 1),
              const SizedBox(height: 14),
              _infoField('Email', p['email']),
              _infoField('Nomor Telepon', p['nomor_telepon']),
              _infoField('RT', p['rt']),
              _infoField('RW', p['rw'], isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      );

  Widget _infoField(String label, dynamic value, {bool isLast = false}) {
    final text = (value != null && value.toString().isNotEmpty)
        ? value.toString()
        : '-';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 148,
                child: Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ),
              Expanded(
                child: Text(text,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppTheme.border),
      ],
    );
  }
}
