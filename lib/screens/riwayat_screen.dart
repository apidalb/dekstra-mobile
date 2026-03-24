import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

// RiwayatScreen — menampilkan permohonan dengan status Disetujui atau Ditolak
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  // Riwayat = hanya status final (Disetujui / Ditolak)
  static const _riwayatStatuses = {'Disetujui', 'Ditolak'};

  String _searchQuery        = '';
  String? _filterStatus;       // null = semua (dalam scope riwayat)
  String? _filterJenis;
  DateTime? _filterTanggalDari;
  DateTime? _filterTanggalHingga;

  late List<Permohonan> _baseList;

  @override
  void initState() {
    super.initState();
    // Ambil hanya data yang berstatus final dari daftar global
    _baseList = daftarPermohonan
        .where((p) => _riwayatStatuses.contains(p.status))
        .toList();
  }

  bool get _hasActiveFilter =>
      _filterStatus != null ||
      _filterJenis != null ||
      _filterTanggalDari != null ||
      _filterTanggalHingga != null;

  List<Permohonan> get _filtered {
    return _baseList.where((p) {
      if (_searchQuery.isNotEmpty &&
          !p.jenisSurat.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !p.status.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_filterStatus != null && p.status != _filterStatus) return false;
      if (_filterJenis  != null && p.jenisSurat != _filterJenis) return false;
      if (_filterTanggalDari != null &&
          p.tanggal.isBefore(_filterTanggalDari!)) {
        return false;
      }
      if (_filterTanggalHingga != null &&
          p.tanggal
              .isAfter(_filterTanggalHingga!.add(const Duration(days: 1)))) {
        return false;
      }
      return true;
    }).toList();
  }

  List<String> get _jenisSuratRiwayat {
    final seen = <String>{};
    return _baseList
        .map((p) => p.jenisSurat)
        .where((j) => seen.add(j))
        .toList()
      ..sort();
  }

  // ── Filter dialog popup ──────────────────────────────────────────────────
  void _showFilter() {
    String? tmpStatus   = _filterStatus;
    String? tmpJenis    = _filterJenis;
    DateTime? tmpDari   = _filterTanggalDari;
    DateTime? tmpHingga = _filterTanggalHingga;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          Future<void> pickDate({required bool isDari}) async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate:
                  (isDari ? tmpDari : tmpHingga) ?? DateTime(2026, 1, 1),
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
              builder: (c, child) => Theme(
                data: Theme.of(c).copyWith(
                  colorScheme:
                      const ColorScheme.light(primary: AppTheme.primary),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setModal(() {
                if (isDari) {
                  tmpDari = picked;
                } else {
                  tmpHingga = picked;
                }
              });
            }
          }

          String fmtDate(DateTime? d) => d == null
              ? 'Pilih Tanggal'
              : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppTheme.surface,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Filter Data',
                          style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close,
                            size: 20, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text('Berdasarkan Status Surat',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  _filterDropdown(
                    value: tmpStatus,
                    hint: 'Semua',
                    items: _riwayatStatuses.toList(),
                    onChanged: (v) => setModal(() => tmpStatus = v),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 16),

                  Text('Berdasarkan Jenis Surat',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  _filterDropdown(
                    value: tmpJenis,
                    hint: 'Semua',
                    items: _jenisSuratRiwayat,
                    onChanged: (v) => setModal(() => tmpJenis = v),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 16),

                  Text('Berdasarkan Tanggal Pengajuan',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _datePickerButton(
                          label: fmtDate(tmpDari),
                          onTap: () => pickDate(isDari: true),
                          hasValue: tmpDari != null,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('–',
                            style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary,
                                fontSize: 16)),
                      ),
                      Expanded(
                        child: _datePickerButton(
                          label: fmtDate(tmpHingga),
                          onTap: () => pickDate(isDari: false),
                          hasValue: tmpHingga != null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setModal(() {
                            tmpStatus  = null;
                            tmpJenis   = null;
                            tmpDari    = null;
                            tmpHingga  = null;
                          }),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset Filter'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _filterStatus        = tmpStatus;
                              _filterJenis         = tmpJenis;
                              _filterTanggalDari   = tmpDari;
                              _filterTanggalHingga = tmpHingga;
                            });
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Apply Filter'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text('Semua',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppTheme.textSecondary)),
          style: GoogleFonts.poppins(
              fontSize: 13, color: AppTheme.textPrimary),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppTheme.textSecondary),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('Semua',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppTheme.textSecondary)),
            ),
            ...items.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: AppTheme.textPrimary)),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _datePickerButton({
    required String label,
    required VoidCallback onTap,
    required bool hasValue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasValue ? AppTheme.primary : AppTheme.border,
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: 14,
                color:
                    hasValue ? AppTheme.primary : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: hasValue
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Riwayat Permohonan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Search + Filter ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Cari data...',
                      prefixIcon: Icon(Icons.search,
                          size: 18, color: AppTheme.textSecondary),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showFilter,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _hasActiveFilter
                          ? AppTheme.primary
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _hasActiveFilter
                            ? AppTheme.primary
                            : AppTheme.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_list,
                            size: 16,
                            color: _hasActiveFilter
                                ? Colors.white
                                : AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text('Filter',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _hasActiveFilter
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Info jumlah data ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                filtered.isEmpty
                    ? 'Tidak ada data'
                    : 'Menampilkan ${filtered.length} dari ${_baseList.length} data',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ),
          ),

          // ── List riwayat ─────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history, size: 48, color: AppTheme.border),
                        const SizedBox(height: 12),
                        Text('Belum ada riwayat permohonan',
                            style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppTheme.border),
                    itemBuilder: (_, i) => PermohonanCard(
                      item: filtered[i],
                      // Hapus tidak tersedia di riwayat
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
