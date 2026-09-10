import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/premium_badge.dart';

class SubscriptionPaywallScreen extends StatefulWidget {
  const SubscriptionPaywallScreen({super.key});

  @override
  State<SubscriptionPaywallScreen> createState() => _SubscriptionPaywallScreenState();
}

class _SubscriptionPaywallScreenState extends State<SubscriptionPaywallScreen> {
  bool _isAnnual = false;
  int _selectedTierIndex = 1; // 0: Free, 1: Pro, 2: Enterprise
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isAlreadyPro = appState.currentUser.isProMember;

    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AgriColors.textMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: PremiumBadge(label: 'SDG 8 & 12', isPro: true),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Icon & Title
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFF57C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AgriSync Pro Subscription',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AgriColors.textMain,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Maksimalkan profit hasil panen dengan analitik prediksi harga pasar & prioritas rantai pasok.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AgriColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Billing Cycle Switcher (Monthly vs Annual)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AgriColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AgriColors.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCycleOption('Bulanan', !_isAnnual, () {
                      setState(() => _isAnnual = false);
                    }),
                    _buildCycleOption('Tahunan (Hemat 20%)', _isAnnual, () {
                      setState(() => _isAnnual = true);
                    }, hasBadge: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Subscription Cards
              _buildTierCard(
                index: 0,
                title: 'Starter / Free',
                price: 'Rp 0',
                period: 'Selamanya',
                features: [
                  'Katalog komoditas standar',
                  'Maksimal 3 listing aktif',
                  'Komisi transaksi 2.5%',
                  'Dukungan via forum komunitas',
                ],
                isPopular: false,
              ),
              const SizedBox(height: 14),
              _buildTierCard(
                index: 1,
                title: 'AgriSync PRO',
                price: _isAnnual ? 'Rp 39.000' : 'Rp 49.000',
                period: '/ bulan',
                features: [
                  'AI Market Price Forecasting (14 hari)',
                  'Listing produk tanpa batas & prioritas pencarian',
                  'Komisi transaksi hemat (hanya 1.0%)',
                  'Badge Verified PRO Member',
                  'Dukungan prioritas 24/7',
                ],
                isPopular: true,
              ),
              const SizedBox(height: 14),
              _buildTierCard(
                index: 2,
                title: 'Enterprise B2B',
                price: _isAnnual ? 'Rp 149.000' : 'Rp 199.000',
                period: '/ bulan',
                features: [
                  'Semua fitur Pro',
                  'Kontrak pasokan panen terjadwal',
                  'Dedicated Quality Auditor & Escrow Manager',
                  'Laporan jejak karbon & Food Loss Audit',
                ],
                isPopular: false,
              ),
              const SizedBox(height: 28),

              // CTA Action Button
              if (isAlreadyPro && _selectedTierIndex == 1) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AgriColors.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AgriColors.accentGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AgriColors.accentGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Anda saat ini sedang menikmati paket AgriSync Pro aktif!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AgriColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                CustomPrimaryButton(
                  text: _selectedTierIndex == 0
                      ? 'Pilih Paket Starter'
                      : _selectedTierIndex == 1
                          ? 'Aktifkan AgriSync PRO Sekarang'
                          : 'Hubungi Sales Enterprise',
                  isLoading: _isProcessing,
                  onPressed: _handleSubscriptionCheckout,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Langganan dapat dibatalkan kapan saja. Syarat dan Ketentuan berlaku.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AgriColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCycleOption(String title, bool isSelected, VoidCallback onTap, {bool hasBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AgriColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AgriColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard({
    required int index,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isPopular,
  }) {
    final isSelected = _selectedTierIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTierIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AgriColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isPopular ? const Color(0xFFF57C00) : AgriColors.primaryDark)
                : AgriColors.cardBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: (isPopular ? const Color(0xFFF57C00) : AgriColors.primaryDark).withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AgriColors.textMain,
                      ),
                    ),
                    if (isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFB300)),
                        ),
                        child: Text(
                          'PALING POPULER',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? (isPopular ? const Color(0xFFF57C00) : AgriColors.primaryDark)
                      : AgriColors.textHint,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AgriColors.textMain,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  period,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AgriColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AgriColors.cardBorder),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AgriColors.accentGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AgriColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscriptionCheckout() async {
    if (_selectedTierIndex == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda saat ini menggunakan paket Starter Free.')),
      );
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isProcessing = true);

    final appState = Provider.of<AppState>(context, listen: false);

    // Simulate payment processing via Payment Gateway Sandbox
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final success = await appState.upgradeToPro(isAnnual: _isAnnual);

    setState(() => _isProcessing = false);

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFFFB300), size: 64),
              const SizedBox(height: 16),
              Text(
                'Selamat! Anda Kini Pro Member',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AgriColors.textMain,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Nikmati potongan komisi transaksi, prioritas penempatan panen, dan analitik harga pasar real-time.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AgriColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Mulai Eksplorasi',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: AgriColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
