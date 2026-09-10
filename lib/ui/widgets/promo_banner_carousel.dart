import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../theme/app_colors.dart';
import '../screens/pebisnis/search_results_screen.dart';
import '../screens/subscription/subscription_paywall_screen.dart';

class PromoBannerItem {
  final String id;
  final String tag;
  final String title;
  final String subtitle;
  final String ctaText;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  PromoBannerItem({
    required this.id,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });
}

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({super.key});

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % _getBanners(context).length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<PromoBannerItem> _getBanners(BuildContext context) {
    return [
      PromoBannerItem(
        id: 'promo_panen',
        tag: '🔥 FLASH SALE PANEN',
        title: 'Panen Raya Cabai & Tomat',
        subtitle: 'Diskon s.d 25% langsung dari petani produsen tanpa perantara',
        ctaText: 'Belanja Sekarang',
        icon: Icons.local_fire_department_rounded,
        gradientColors: const [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        onTap: () {
          final appState = Provider.of<AppState>(context, listen: false);
          appState.setSearchQuery('Cabai');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SearchResultsScreen(),
            ),
          );
        },
      ),
      PromoBannerItem(
        id: 'promo_ongkir',
        tag: '🚚 GRATIS ONGKIR',
        title: 'Armada Truk Berpendingin',
        subtitle: 'Bebas ongkir pengiriman pertama muatan sayur segar ke bisnismu',
        ctaText: 'Klaim Promo',
        icon: Icons.local_shipping_rounded,
        gradientColors: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voucher Gratis Ongkir Logistik Tani berhasil diklaim!'),
              backgroundColor: AgriColors.primaryGreen,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
      PromoBannerItem(
        id: 'promo_pro',
        tag: '⭐ SPESIAL PRO',
        title: 'Hemat Komisi 1.0% + AI Panen',
        subtitle: 'Dapatkan prediksi harga panen 2026 & prioritas pasokan kuliner',
        ctaText: 'Coba PRO',
        icon: Icons.workspace_premium_rounded,
        gradientColors: const [Color(0xFFE65100), Color(0xFFBF360C)],
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SubscriptionPaywallScreen(),
            ),
          );
        },
      ),
      PromoBannerItem(
        id: 'promo_escrow',
        tag: '🛡️ ESCROW AMAN',
        title: 'Jaminan Transaksi Rekber',
        subtitle: 'Dana aman di rekening bersama hingga komoditas dicek & diterima',
        ctaText: 'Pelajari Jaminan',
        icon: Icons.verified_user_rounded,
        gradientColors: const [Color(0xFF334C1B), Color(0xFF1A260E)],
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi di AgriSync dilindungi Rekber Escrow 100% aman.'),
              backgroundColor: AgriColors.darkOliveBtn,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final banners = _getBanners(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 156,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return _buildBannerCard(banner);
            },
          ),
        ),
        const SizedBox(height: 10),
        // Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AgriColors.primaryGreen : AgriColors.cardBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerCard(PromoBannerItem banner) {
    return GestureDetector(
      onTap: banner.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: banner.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F1E293B),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative background circles
            Positioned(
              right: -25,
              top: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            // Large Watermark Icon on right
            Positioned(
              right: 12,
              bottom: 12,
              child: Icon(
                banner.icon,
                size: 76,
                color: Colors.white.withOpacity(0.12),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tag Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.8),
                        ),
                        child: Text(
                          banner.tag,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Title
                      Text(
                        banner.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Subtitle
                      Text(
                        banner.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Call to action button & swipe hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              banner.ctaText,
                              style: GoogleFonts.plusJakartaSans(
                                color: banner.gradientColors.first,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: banner.gradientColors.first,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Geser untuk promo lain ➔',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
