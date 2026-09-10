import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/data/models/verification_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/widgets/app_bottom_nav_bar.dart';
import 'package:agrisync/ui/screens/orders/order_history_screen.dart';
import 'package:agrisync/ui/screens/auth/welcome_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/pebisnis_home_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/cart_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/favorites_screen.dart';
import 'package:agrisync/ui/screens/petani/petani_home_screen.dart';
import 'package:agrisync/ui/screens/petani/petani_orders_screen.dart';
import 'package:agrisync/ui/screens/admin/admin_dashboard_screen.dart';
import 'package:agrisync/ui/screens/admin/pending_verifications_screen.dart';
import 'package:agrisync/ui/screens/chat/chat_inbox_screen.dart';
import 'package:agrisync/ui/screens/subscription/subscription_paywall_screen.dart';
import 'package:agrisync/ui/widgets/premium_badge.dart';
import 'package:agrisync/ui/screens/profile/edit_profile_screen.dart';
import 'package:agrisync/ui/screens/profile/account_security_screen.dart';
import 'package:agrisync/ui/screens/profile/notification_settings_screen.dart';
import 'package:agrisync/ui/screens/profile/app_preferences_screen.dart';
import 'package:agrisync/ui/screens/profile/help_support_screen.dart';
import 'package:agrisync/ui/widgets/agri_user_avatar.dart';
import 'package:agrisync/ui/widgets/profile_detail_dialog.dart';

class UserProfileScreen extends StatefulWidget {
  final bool isRootTab;

  const UserProfileScreen({super.key, this.isRootTab = false});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _navIndex = 3;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    if (widget.isRootTab && _navIndex != 3) {
      if (_navIndex == 0) {
        switch (user.role) {
          case UserRole.pebisnis:
            return const PebisnisHomeScreen();
          case UserRole.petani:
            return const PetaniHomeScreen();
          case UserRole.admin:
            return const AdminDashboardScreen();
        }
      }
      if (_navIndex == 1) {
        switch (user.role) {
          case UserRole.pebisnis:
            return const PebisnisCartScreen(isRootTab: true);
          case UserRole.petani:
            return const PetaniOrdersScreen(isRootTab: true);
          case UserRole.admin:
            return const PendingVerificationsScreen();
        }
      }
      if (_navIndex == 2) {
        if (user.role == UserRole.pebisnis) {
          return const FavoritesScreen(isRootTab: true);
        }
        return const ChatInboxScreen(isRootTab: true);
      }
    }

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: !widget.isRootTab,
      showNotification: true,
      title: 'Profil & Pengaturan',
      bottomNavigationBar: widget.isRootTab
          ? AgriBottomNavBar(
              role: user.role,
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Avatar & Info with Zoom Lightbox Preview
            Center(
              child: GestureDetector(
                onTap: () {
                  ProfileDetailDialog.showZoomedAvatar(
                    context,
                    imageUrl: user.avatarUrl,
                    name: user.name,
                    role: '${user.roleDisplay} • ${user.isVerified ? "Terverifikasi" : "Menunggu Verifikasi"}',
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                  );
                },
                child: Stack(
                  children: [
                    AgriUserAvatar(
                      imageUrl: user.avatarUrl,
                      name: user.name,
                      radius: 44,
                      isVerified: user.isVerified,
                      showBadge: true,
                      border: Border.all(color: Colors.white, width: 3),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x24000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AgriColors.darkOliveBtn,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              user.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email ?? user.phone,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AgriColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),

            // Verification & Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user.isVerified
                    ? AgriColors.badgeGreenBg
                    : (user.verificationStatus == VerificationStatus.rejected
                        ? Colors.red.shade50
                        : AgriColors.lightSageBg),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: user.isVerified
                      ? AgriColors.primaryGreen
                      : (user.verificationStatus == VerificationStatus.rejected
                          ? AgriColors.rejectedRed
                          : AgriColors.primaryGreen),
                ),
              ),
              child: Text(
                '${user.roleDisplay} • ${user.isVerified ? "Terverifikasi" : (user.verificationStatus == VerificationStatus.rejected ? "Ditolak (Perlu Revisi)" : "Menunggu Verifikasi")}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: user.verificationStatus == VerificationStatus.rejected
                      ? AgriColors.rejectedRed
                      : AgriColors.darkOliveBtn,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pro Membership Banner (CPMK 2 & 5 Monetization)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SubscriptionPaywallScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: user.isProMember
                      ? const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: user.isProMember ? const Color(0xFF81C784) : const Color(0xFFFFB300),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (user.isProMember ? Colors.green : Colors.orange).withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: user.isProMember ? Colors.white.withOpacity(0.2) : const Color(0xFFFFB300),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.isProMember ? 'AgriSync PRO Member' : 'Upgrade ke AgriSync PRO',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: user.isProMember ? Colors.white : const Color(0xFFE65100),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              PremiumBadge(
                                label: user.isProMember ? 'ACTIVE' : 'HEMAT 20%',
                                isPro: !user.isProMember,
                                fontSize: 8,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.isProMember
                                ? 'Komisi 1.0% aktif & prioritas listing'
                                : 'Prediksi harga panen & komisi hemat 1.0%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: user.isProMember ? Colors.white70 : Colors.brown.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: user.isProMember ? Colors.white : const Color(0xFFE65100),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // SECTION 1: AKUN & KEAMANAN
            _buildSectionHeader('Akun & Keamanan'),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profil & Informasi',
                subtitle: 'Nama, email, telepon, dan alamat peta kebun/bisnis',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.lock_outline_rounded,
                title: 'Keamanan & Kata Sandi',
                subtitle: 'Ganti password, 2FA, dan sesi perangkat',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AccountSecurityScreen()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.verified_user_outlined,
                title: 'Status Verifikasi Dokumen',
                subtitle: user.isVerified ? 'Akun Terverifikasi Resmi' : 'Menunggu Peninjauan Admin',
                onTap: () => _showVerificationModal(context, user, appState),
              ),
            ]),
            const SizedBox(height: 16),

            // SECTION 2: AKTIVITAS & TRANSAKSI
            _buildSectionHeader('Aktivitas & Transaksi'),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Inbox Chat & Negosiasi Harga',
                subtitle: 'Pantau riwayat tawar-menawar harga dan obrolan',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatInboxScreen()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.receipt_long_outlined,
                title: user.role == UserRole.petani
                    ? 'Riwayat Penjualan Hasil Tani'
                    : (user.role == UserRole.pebisnis
                        ? 'Riwayat Pembelian Komoditas'
                        : 'Riwayat Transaksi Platform'),
                subtitle: user.role == UserRole.petani
                    ? 'Pantau pesanan hasil panen terjual'
                    : 'Pantau status pesanan dan escrow',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 16),

            // SECTION 3: PREFERENSI & SISTEM
            _buildSectionHeader('Preferensi & Aplikasi'),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Pengaturan Notifikasi',
                subtitle: 'Peringatan negosiasi, pesanan, dan tren panen',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.tune_rounded,
                title: 'Tampilan, Bahasa & Satuan',
                subtitle: 'Bahasa Indonesia, tema, kg/ton, dan cache',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AppPreferencesScreen()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 16),

            // Offline-First Sync Panel (CPMK 4)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: appState.isOfflineMode
                    ? const LinearGradient(
                        colors: [Color(0xFFFFF8E1), Color(0xFFFFF3CD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : AgriColors.surfaceCardGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: appState.isOfflineMode ? const Color(0xFFFFB300) : AgriColors.cardBorder.withOpacity(0.8),
                ),
                boxShadow: AgriColors.softCardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            appState.isOfflineMode ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                            color: appState.isOfflineMode ? const Color(0xFFE65100) : AgriColors.primaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mode Offline (CPMK 4)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AgriColors.textMain,
                                ),
                              ),
                              Text(
                                appState.isOfflineMode ? 'Bekerja dengan cache lokal' : 'Terhubung ke server online',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AgriColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: appState.isOfflineMode,
                        activeColor: const Color(0xFFE65100),
                        onChanged: (val) {
                          appState.setOfflineMode(val);
                        },
                      ),
                    ],
                  ),
                  if (appState.offlinePendingQueue.isNotEmpty) ...[
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${appState.offlinePendingQueue.length} antrean aksi offline siap sinkron',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFFE65100), fontWeight: FontWeight.w600),
                        ),
                        TextButton(
                          onPressed: () {
                            appState.syncOfflineQueue();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Antrean offline berhasil disinkronkan ke server!'),
                                backgroundColor: AgriColors.primaryGreen,
                              ),
                            );
                          },
                          child: const Text('Sinkron Sekarang'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SECTION 4: BANTUAN & INFO
            _buildSectionHeader('Bantuan & Informasi'),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.support_agent_outlined,
                title: 'Pusat Bantuan & Layanan CS',
                subtitle: 'FAQ, kontak WhatsApp CS 24/7, dan panduan',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.gavel_rounded,
                title: 'Syarat Ketentuan & Kebijakan Privasi',
                subtitle: 'Perjanjian pengguna & perlindungan privasi data',
                onTap: () => _showTermsModal(context),
              ),
            ]),
            const SizedBox(height: 16),

            // Beralih Peran (Demo / Reviewer)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AgriColors.sageCardGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8)),
                boxShadow: AgriColors.softCardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sync_alt, size: 18, color: AgriColors.darkOliveBtn),
                      const SizedBox(width: 8),
                      Text(
                        'Beralih Peran Pengguna (Mode Evaluator):',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: AgriColors.textMain),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleButton(context, 'Pebisnis', UserRole.pebisnis, user.role == UserRole.pebisnis),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildRoleButton(context, 'Petani', UserRole.petani, user.role == UserRole.petani),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildRoleButton(context, 'Admin', UserRole.admin, user.role == UserRole.admin),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            AgriPillButton(
              text: 'KELUAR DARI AKUN',
              type: AgriButtonType.outline,
              height: 46,
              onPressed: () {
                appState.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showVerificationModal(BuildContext context, UserModel user, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isRejected = user.verificationStatus == VerificationStatus.rejected;
        final isVerified = user.isVerified;
        final userVerif = appState.verifications.cast<VerificationItem?>().firstWhere(
              (v) => v?.userId == user.id || v?.userName == user.name,
              orElse: () => null,
            );
        final rejectionReason = userVerif?.rejectionReason;

        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isVerified
                              ? Icons.verified_user_rounded
                              : (isRejected ? Icons.cancel_outlined : Icons.pending_actions_rounded),
                          color: isVerified
                              ? AgriColors.primaryGreen
                              : (isRejected ? AgriColors.rejectedRed : Colors.orange.shade800),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Status Legalitas & Verifikasi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AgriColors.textMain,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isVerified
                      ? AgriColors.badgeGreenBg
                      : (isRejected ? Colors.red.shade50 : const Color(0xFFFFF3E0)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isVerified
                        ? AgriColors.primaryGreen
                        : (isRejected ? AgriColors.rejectedRed : Colors.orange.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isVerified
                          ? Icons.check_circle_outline
                          : (isRejected ? Icons.error_outline_rounded : Icons.info_outline),
                      color: isVerified
                          ? AgriColors.primaryGreen
                          : (isRejected ? AgriColors.rejectedRed : Colors.orange.shade800),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isVerified
                                ? 'Akun Terverifikasi Resmi'
                                : (isRejected ? 'Verifikasi Berkas Ditolak' : 'Menunggu Peninjauan Berkas'),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isVerified
                                  ? AgriColors.darkOliveBtn
                                  : (isRejected ? AgriColors.rejectedRed : Colors.orange.shade900),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isVerified
                                ? 'Identitas pemilik kebun/usaha dan dokumen legalitas telah tervalidasi oleh tim admin AgriSync.'
                                : (isRejected
                                    ? (rejectionReason != null && rejectionReason.isNotEmpty
                                        ? 'Alasan Penolakan: "$rejectionReason". Silakan unggah dokumen yang valid di bawah.'
                                        : 'Dokumen Anda belum memenuhi persyaratan. Silakan unggah dokumen revisi di bawah.')
                                    : 'Dokumen Anda sedang dalam antrean validasi 1x24 jam oleh tim admin AgriSync.'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: isVerified
                                  ? AgriColors.darkOliveBtn
                                  : (isRejected ? Colors.red.shade900 : Colors.brown.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rincian Identitas Terdaftar:',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Nama Pemilik / Usaha', user.name),
              _buildInfoRow('Peran Akun', user.roleDisplay),
              _buildInfoRow('Wilayah Operasional', user.farmLocation ?? 'Jawa Timur, Indonesia'),
              _buildInfoRow('Dokumen Terlampir', userVerif?.documentName ?? (user.role == UserRole.petani ? 'KTP & Surat Keterangan Poktan' : 'KTP & NIB Izin Usaha')),
              if (isRejected && rejectionReason != null && rejectionReason.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildInfoRow('Catatan Admin', rejectionReason, isAlert: true),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgriColors.darkOliveBtn,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showUploadVerificationDialog(context, user, appState);
                  },
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: Text(
                    'Perbarui / Unggah Ulang Dokumen',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showUploadVerificationDialog(BuildContext context, UserModel user, AppState appState) {
    final docNameController = TextEditingController(
      text: user.role == UserRole.petani
          ? 'KTP Elektronik & Surat Keterangan Poktan 2026'
          : 'KTP & NIB Usaha Kuliner 2026',
    );
    final detailController = TextEditingController(
      text: user.farmLocation ?? 'Malang, Jawa Timur',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.cloud_upload_outlined, color: AgriColors.primaryGreen, size: 22),
              const SizedBox(width: 8),
              Text(
                'Unggah Berkas Legalitas',
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Dokumen / Jenis Berkas',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: docNameController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: KTP & SIUP/NIB 2026',
                    filled: true,
                    fillColor: AgriColors.surfaceWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Catatan Legalitas / Lokasi Usaha',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: detailController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Lokasi lahan / nomor registrasi...',
                    filled: true,
                    fillColor: AgriColors.surfaceWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AgriColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final docName = docNameController.text.trim();
                final detail = detailController.text.trim();

                if (docName.isEmpty) return;

                appState.submitVerificationDocument(
                  documentName: docName,
                  documentPath: 'assets/docs/verif_${user.id}.pdf',
                  roleDetail: detail,
                );

                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dokumen legalitas berhasil dikirim ke antrean verifikasi Admin!'),
                    backgroundColor: AgriColors.primaryGreen,
                  ),
                );
              },
              child: const Text('Kirim Berkas'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.gavel_rounded, color: AgriColors.darkOliveBtn, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Syarat & Kebijakan Privasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AgriColors.textMain,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Rekening Bersama Escrow AgriSync',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Semua pembayaran komoditas sayuran disimpan dalam escrow aman hingga pembeli memeriksa mutu hasil panen. Petani dijamin menerima dana penuh saat pengiriman terkonfirmasi.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.45, color: AgriColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '2. Negosiasi Transparan & Tanpa Tengkulak',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AgriSync menghubungkan langsung petani produsen dan pelaku usaha kuliner tanpa perantara tengkulak berantai untuk memastikan keadilan harga pasar.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.45, color: AgriColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '3. Perlindungan Privasi & Keamanan Data',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Informasi pribadi, dokumen verifikasi, dan riwayat finansial Anda dilindungi enkripsi standar industri dan tidak akan dibagikan ke pihak ketiga tanpa persetujuan.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.45, color: AgriColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgriColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Saya Menyetujui Ketentuan'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAlert = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade600)),
          ),
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
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AgriColors.darkOliveBtn,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        gradient: AgriColors.surfaceCardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8)),
        boxShadow: AgriColors.softCardShadow,
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String label, UserRole role, bool isCurrent) {
    return InkWell(
      onTap: () {
        final appState = Provider.of<AppState>(context, listen: false);
        appState.switchUserRole(role);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beralih ke mode $label'),
            backgroundColor: AgriColors.primaryGreen,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: isCurrent ? AgriColors.darkOliveGradient : null,
          color: isCurrent ? null : AgriColors.surfaceWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCurrent ? Colors.transparent : AgriColors.inputBorder.withOpacity(0.8),
          ),
          boxShadow: isCurrent ? AgriColors.buttonShadowDark : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color: isCurrent ? Colors.white : AgriColors.textMain,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AgriColors.sageCardGradient,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AgriColors.cardBorder.withOpacity(0.5)),
              ),
              child: Icon(icon, color: AgriColors.darkOliveBtn, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AgriColors.textMain,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AgriColors.textHint),
          ],
        ),
      ),
    );
  }
}
