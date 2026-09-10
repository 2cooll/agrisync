import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/data/services/push_notification_service.dart';
import 'package:agrisync/data/services/system_notification_helper.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  NotificationPermissionStatus _permissionStatus = NotificationPermissionStatus.granted;
  bool _isCheckingPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    setState(() => _isCheckingPermission = true);
    final status = await PushNotificationService.getPermissionStatus();
    if (mounted) {
      setState(() {
        _permissionStatus = status;
        _isCheckingPermission = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _isCheckingPermission = true);
    final newStatus = await PushNotificationService.requestPermission();
    if (mounted) {
      setState(() {
        _permissionStatus = newStatus;
        _isCheckingPermission = false;
      });

      if (newStatus == NotificationPermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Izin notifikasi sistem & web berhasil diaktifkan!'),
            backgroundColor: AgriColors.primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
        // Trigger a test system notification
        final appState = Provider.of<AppState>(context, listen: false);
        PushNotificationService.sendTestNotification(
          appState,
          categoryKey: 'orders',
          context: context,
        );
      } else if (newStatus == NotificationPermissionStatus.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Izin notifikasi ditolak oleh browser/perangkat. Silakan ubah di setelan situs browser.'),
            backgroundColor: AgriColors.rejectedRed,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _triggerTestPush(AppState appState, String categoryKey, String categoryName) async {
    final isEnabled = appState.notificationSettings[categoryKey] ?? (categoryKey != 'promotions');
    if (!isEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Notifikasi "$categoryName" sedang dinonaktifkan. Aktifkan switch di atas untuk menerima push.'),
          backgroundColor: const Color(0xFFC62828),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Auto-request permission if not yet granted
    if (_permissionStatus == NotificationPermissionStatus.defaultStatus) {
      await _requestPermission();
    }

    if (!mounted) return;

    final success = PushNotificationService.sendTestNotification(
      appState,
      categoryKey: categoryKey,
      context: context,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔔 Push notifikasi "$categoryName" berhasil keluar!'),
          backgroundColor: AgriColors.primaryGreen,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final settings = appState.notificationSettings;

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      title: 'Notifikasi',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferensi Notifikasi & Peringatan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Atur jenis pemberitahuan dan perizinan push notifikasi real-time pada perangkat Anda.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AgriColors.textMuted),
            ),
            const SizedBox(height: 16),

            // SYSTEM PERMISSION STATUS CARD
            _buildPermissionStatusCard(),
            const SizedBox(height: 16),

            // Transaksi & Negosiasi
            _buildSection(
              title: 'Transaksi & Negosiasi',
              children: [
                _buildSwitchTile(
                  title: 'Penawaran & Chat Negosiasi',
                  subtitle: 'Pemberitahuan saat mitra mengirim tawaran atau pesan baru',
                  value: settings['negotiations'] ?? true,
                  onTest: () => _triggerTestPush(appState, 'negotiations', 'Penawaran Negosiasi'),
                  onChanged: (v) {
                    appState.setNotificationSetting('negotiations', v);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(v ? 'Notifikasi negosiasi diaktifkan' : 'Notifikasi negosiasi dimatikan'),
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'Status Pesanan & Escrow',
                  subtitle: 'Update saat pembayaran disetor, barang dikirim, atau selesai',
                  value: settings['orders'] ?? true,
                  onTest: () => _triggerTestPush(appState, 'orders', 'Pesanan & Escrow'),
                  onChanged: (v) {
                    appState.setNotificationSetting('orders', v);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(v ? 'Notifikasi pesanan diaktifkan' : 'Notifikasi pesanan dimatikan'),
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informasi Panen & Pasar
            _buildSection(
              title: 'Panen & Rekomendasi Pasar',
              children: [
                _buildSwitchTile(
                  title: 'Jadwal & Estimasi Panen',
                  subtitle: 'Pengingat saat waktu panen mendekati tanggal siap petik',
                  value: settings['harvests'] ?? true,
                  onTest: () => _triggerTestPush(appState, 'harvests', 'Jadwal Panen'),
                  onChanged: (v) {
                    appState.setNotificationSetting('harvests', v);
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'Prediksi & Tren Harga Komoditas',
                  subtitle: 'Update kenaikan/penurunan harga sayuran di pasar induk',
                  value: settings['price_trends'] ?? true,
                  onTest: () => _triggerTestPush(appState, 'price_trends', 'Tren Harga Pasar'),
                  onChanged: (v) {
                    appState.setNotificationSetting('price_trends', v);
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'Promo & Diskon Komisi Platform',
                  subtitle: 'Info voucher diskon biaya layanan dan event panen raya',
                  value: settings['promotions'] ?? false,
                  onTest: () => _triggerTestPush(appState, 'promotions', 'Promo & Diskon'),
                  onChanged: (v) {
                    appState.setNotificationSetting('promotions', v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Suara & Email
            _buildSection(
              title: 'Sistem & Email',
              children: [
                _buildSwitchTile(
                  title: 'Suara & Getar Perangkat',
                  subtitle: 'Bunyikan nada dering dan getar saat notifikasi penting masuk',
                  value: settings['sound_vibrate'] ?? true,
                  onChanged: (v) {
                    appState.setNotificationSetting('sound_vibrate', v);
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'Ringkasan Email Mingguan',
                  subtitle: 'Kirim laporan transaksi dan statistik penjualan ke email',
                  value: settings['email_digest'] ?? true,
                  onChanged: (v) {
                    appState.setNotificationSetting('email_digest', v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Live Push Notification Test Center
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AgriColors.sageCardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8)),
                boxShadow: AgriColors.softCardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AgriColors.primaryGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: AgriColors.primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uji Coba Push Notifikasi Langsung',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AgriColors.textMain,
                              ),
                            ),
                            Text(
                              'Tekan tombol di bawah untuk mencoba simulasi push banner:',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickTestChip(
                        label: '📦 Push Pesanan',
                        onTap: () => _triggerTestPush(appState, 'orders', 'Pesanan & Escrow'),
                      ),
                      _buildQuickTestChip(
                        label: '💬 Push Negosiasi',
                        onTap: () => _triggerTestPush(appState, 'negotiations', 'Penawaran Negosiasi'),
                      ),
                      _buildQuickTestChip(
                        label: '🌾 Push Panen',
                        onTap: () => _triggerTestPush(appState, 'harvests', 'Jadwal Panen'),
                      ),
                      _buildQuickTestChip(
                        label: '📈 Push Harga Pasar',
                        onTap: () => _triggerTestPush(appState, 'price_trends', 'Tren Harga Pasar'),
                      ),
                      _buildQuickTestChip(
                        label: '🏷️ Push Promo',
                        onTap: () => _triggerTestPush(appState, 'promotions', 'Promo & Diskon'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionStatusCard() {
    final isGranted = _permissionStatus == NotificationPermissionStatus.granted;
    final isDenied = _permissionStatus == NotificationPermissionStatus.denied;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGranted
            ? AgriColors.badgeGreenBg
            : (isDenied ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted
              ? AgriColors.primaryGreen
              : (isDenied ? AgriColors.rejectedRed : const Color(0xFFFFB300)),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isGranted
                        ? Icons.verified_user_rounded
                        : (isDenied ? Icons.block_rounded : Icons.info_rounded),
                    color: isGranted
                        ? AgriColors.primaryGreen
                        : (isDenied ? AgriColors.rejectedRed : const Color(0xFFE65100)),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Perizinan Notifikasi Sistem',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AgriColors.textMain,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isGranted
                      ? AgriColors.primaryGreen
                      : (isDenied ? AgriColors.rejectedRed : const Color(0xFFE65100)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isGranted ? 'DIIZINKAN' : (isDenied ? 'DIBLOKIR' : 'PERLU IZIN'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isGranted
                ? 'Perangkat Anda telah mengizinkan push notifikasi real-time & pop-up sistem saat ada negosiasi, pesanan baru, atau tren harga.'
                : (isDenied
                    ? 'Izin notifikasi diblokir oleh setelan browser/perangkat Anda. Klik ikon gembok/setelan di address bar untuk mengizinkan (Allow).'
                    : 'Aktifkan perizinan notifikasi agar banner pop-up dan update harga panen dapat langsung muncul di layar perangkat Anda.'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isGranted ? AgriColors.darkOliveBtn : Colors.black87,
              height: 1.35,
            ),
          ),
          if (!isGranted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: _isCheckingPermission ? null : _requestPermission,
                icon: _isCheckingPermission
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.notifications_active_rounded, size: 18),
                label: Text(
                  isDenied ? 'Cek Ulang Izin Notifikasi' : 'Aktifkan Izin Notifikasi Sekarang',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDenied ? AgriColors.rejectedRed : AgriColors.darkOliveBtn,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickTestChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AgriColors.darkOliveBtn,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AgriColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AgriColors.darkOliveBtn,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onTest,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (onTest != null) ...[
                      InkWell(
                        onTap: onTest,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AgriColors.lightSageBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.3)),
                          ),
                          child: Text(
                            'Uji Coba',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AgriColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            activeColor: AgriColors.primaryGreen,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
