import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/data/models/verification_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/screens/admin/admin_dashboard_screen.dart';

class PendingVerificationsScreen extends StatelessWidget {
  const PendingVerificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final pendingList = appState.pendingVerifications;
    final allList = appState.verifications;

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      showMenu: false,
      showNotification: true,
      onBack: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        }
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title matching Mockup 3 Screen 2 & 3
          Center(
            child: Text(
              'Pending Verifications',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '${pendingList.length} Permintaan Verifikasi Menunggu Keputusan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AgriColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: allList.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada antrean verifikasi.',
                      style: GoogleFonts.plusJakartaSans(color: AgriColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: allList.length,
                    itemBuilder: (context, index) {
                      final item = allList[index];
                      final isPending = item.status == VerificationStatus.pending;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AgriColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPending
                                ? AgriColors.inputBorder.withOpacity(0.8)
                                : (item.status == VerificationStatus.verified
                                    ? AgriColors.primaryGreen.withOpacity(0.6)
                                    : AgriColors.rejectedRed.withOpacity(0.5)),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Details matching mockup
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nama Pengguna',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AgriColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    '${item.userName} - ${item.roleDetail}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AgriColors.textMain,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tipe di Registrasi',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: AgriColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    '${item.registrationType} • ${item.location}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AgriColors.darkOliveBtn,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () {
                                      _showDocumentDialog(context, item);
                                    },
                                    child: Text(
                                      '📄 Lihat Dokumen: ${item.documentName}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: AgriColors.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Right Action Buttons matching mockup
                            Expanded(
                              flex: 2,
                              child: isPending
                                  ? Column(
                                      children: [
                                        // "✓ VERIFIKASI" Button
                                        AgriPillButton(
                                          text: '✓ VERIFIKASI',
                                          type: AgriButtonType.darkOlive,
                                          height: 34,
                                          onPressed: () {
                                            appState.approveVerification(item.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('${item.userName} berhasil diverifikasi!'),
                                                backgroundColor: AgriColors.primaryGreen,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 8),

                                        // "✕ TOLAK" Button
                                        AgriPillButton(
                                          text: '✕ TOLAK',
                                          type: AgriButtonType.darkOlive,
                                          height: 34,
                                          onPressed: () {
                                            _showRejectDialog(context, appState, item);
                                          },
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: item.status == VerificationStatus.verified
                                                ? AgriColors.badgeGreenBg
                                                : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            item.status == VerificationStatus.verified ? 'TERVERIFIKASI' : 'DITOLAK',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: item.status == VerificationStatus.verified
                                                  ? AgriColors.darkOliveBtn
                                                  : AgriColors.rejectedRed,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        InkWell(
                                          onTap: () {
                                            appState.reopenVerification(item.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Berkas ${item.userName} dibuka kembali untuk verifikasi ulang.'),
                                                backgroundColor: AgriColors.primaryGreen,
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Verifikasi Ulang',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AgriColors.primaryGreen,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        InkWell(
                                          onTap: () async {
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                title: Row(
                                                  children: [
                                                    Icon(Icons.delete_forever_rounded, color: Colors.red.shade700),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Hapus Akun Pengguna',
                                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                                content: Text(
                                                  'Apakah Anda yakin ingin menghapus akun ${item.userName}?\n\n'
                                                  '⚠️ Semua produk panen yang pernah didaftarkan oleh akun ini akan langsung dihapus permanen dari Cloud Firestore dan database sistem.',
                                                  style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.4),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(ctx).pop(false),
                                                    child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade700)),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red.shade700,
                                                      foregroundColor: Colors.white,
                                                    ),
                                                    onPressed: () => Navigator.of(ctx).pop(true),
                                                    child: const Text('Hapus Permanen'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirmed == true && context.mounted) {
                                              await appState.deleteUserAccountCascade(item.userId);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Akun ${item.userName} dan seluruh produknya berhasil dihapus.'),
                                                    backgroundColor: AgriColors.primaryGreen,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: Text(
                                            'Hapus Akun & Produk',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: AgriColors.rejectedRed,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AppState appState, VerificationItem item) {
    String selectedReason = 'Dokumen buram / tidak terbaca jelas';
    final customNotesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final reasons = [
              'Dokumen buram / tidak terbaca jelas',
              'Data identitas KTP/NIB tidak cocok',
              'Masa berlaku dokumen telah kadaluarsa',
              'Dokumen belum lengkap / terpotong',
              'Lainnya (Tulis catatan khusus)',
            ];

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.cancel_outlined, color: AgriColors.rejectedRed, size: 26),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tolak Verifikasi Berkas',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih alasan penolakan untuk ${item.userName}:',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AgriColors.textMain, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...reasons.map((r) {
                      final isSel = selectedReason == r;
                      return InkWell(
                        onTap: () => setState(() => selectedReason = r),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                                size: 18,
                                color: isSel ? AgriColors.rejectedRed : AgriColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  r,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.normal,
                                    color: isSel ? AgriColors.textMain : AgriColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (selectedReason == 'Lainnya (Tulis catatan khusus)') ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: customNotesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Tuliskan alasan penolakan lebih rinci...',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AgriColors.textMuted),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(10),
                        ),
                        style: GoogleFonts.plusJakartaSans(fontSize: 12.5),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgriColors.rejectedRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final finalReason = selectedReason == 'Lainnya (Tulis catatan khusus)' &&
                            customNotesController.text.trim().isNotEmpty
                        ? customNotesController.text.trim()
                        : selectedReason;

                    Navigator.pop(ctx);
                    appState.rejectVerification(item.id, finalReason);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verifikasi ${item.userName} ditolak dengan alasan: "$finalReason"'),
                        backgroundColor: AgriColors.rejectedRed,
                      ),
                    );
                  },
                  child: Text(
                    'Konfirmasi Tolak',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDocumentDialog(BuildContext context, VerificationItem item) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isPending = item.status == VerificationStatus.pending;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pratinjau Berkas Registrasi',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AgriColors.textMain),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.status == VerificationStatus.verified
                            ? AgriColors.badgeGreenBg
                            : (item.status == VerificationStatus.pending ? Colors.orange.shade50 : Colors.red.shade50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.status == VerificationStatus.verified
                            ? 'TERVERIFIKASI'
                            : (item.status == VerificationStatus.pending ? 'MENUNGGU' : 'DITOLAK'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: item.status == VerificationStatus.verified
                              ? AgriColors.darkOliveBtn
                              : (item.status == VerificationStatus.pending ? Colors.orange.shade800 : AgriColors.rejectedRed),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Card Document Preview
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AgriColors.lightSageBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AgriColors.cardBorder),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description_rounded, color: AgriColors.darkOliveBtn, size: 48),
                        const SizedBox(height: 6),
                        Text(
                          item.documentName,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AgriColors.textMain),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Format: Dokumen Resmi Terunggah',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AgriColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Detail Information
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Pendaftar', item.userName),
                      const SizedBox(height: 4),
                      _buildInfoRow('Peran', item.roleDetail),
                      const SizedBox(height: 4),
                      _buildInfoRow('Lokasi', item.location),
                      const SizedBox(height: 4),
                      _buildInfoRow('Tipe Registrasi', item.registrationType),
                      if (item.rejectionReason != null && item.rejectionReason!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _buildInfoRow('Alasan Penolakan', item.rejectionReason!, isAlert: true),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                if (isPending)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AgriColors.rejectedRed),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showRejectDialog(context, appState, item);
                          },
                          child: Text(
                            '✕ Tolak',
                            style: GoogleFonts.plusJakartaSans(color: AgriColors.rejectedRed, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgriColors.primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            appState.approveVerification(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.userName} berhasil diverifikasi!'),
                                backgroundColor: AgriColors.primaryGreen,
                              ),
                            );
                          },
                          child: Text(
                            '✓ Setujui',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AgriColors.inputBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Tutup',
                            style: GoogleFonts.plusJakartaSans(color: AgriColors.textMuted, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgriColors.darkOliveBtn,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            appState.reopenVerification(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Berkas ${item.userName} dibuka kembali untuk verifikasi ulang.'),
                                backgroundColor: AgriColors.primaryGreen,
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                          label: Text(
                            'Verifikasi Ulang',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAlert = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 11.5, color: AgriColors.textMuted)),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isAlert ? AgriColors.rejectedRed : AgriColors.textMain,
            ),
          ),
        ),
      ],
    );
  }
}
