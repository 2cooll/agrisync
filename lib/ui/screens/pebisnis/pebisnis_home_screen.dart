import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/agri_user_avatar.dart';
import 'package:agrisync/ui/widgets/product_card.dart';
import 'package:agrisync/ui/widgets/app_bottom_nav_bar.dart';
import 'package:agrisync/ui/widgets/promo_banner_carousel.dart';
import 'package:agrisync/ui/screens/pebisnis/cart_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/search_results_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/product_detail_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/favorites_screen.dart';
import 'package:agrisync/ui/screens/profile/user_profile_screen.dart';
import 'package:agrisync/ui/screens/profile/edit_profile_screen.dart';
import 'package:agrisync/data/models/user_model.dart';

class PebisnisHomeScreen extends StatefulWidget {
  const PebisnisHomeScreen({super.key});

  @override
  State<PebisnisHomeScreen> createState() => _PebisnisHomeScreenState();
}

class _PebisnisHomeScreenState extends State<PebisnisHomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_navIndex == 1) {
      return const PebisnisCartScreen(isRootTab: true);
    } else if (_navIndex == 2) {
      return const FavoritesScreen(isRootTab: true);
    } else if (_navIndex == 3) {
      return const UserProfileScreen(isRootTab: true);
    }

    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final products = appState.products;

    return AgriCurvedScaffold(
      showBack: false,
      showNotification: true,
      showChat: true,
      headerHeight: 110,
      titleWidget: Row(
        children: [
          // User Avatar with Ring
          GestureDetector(
            onTap: () {
              setState(() => _navIndex = 3);
            },
            child: AgriUserAvatar(
              imageUrl: user.avatarUrl,
              name: user.name,
              radius: 20,
              isVerified: user.isVerified,
              showBadge: true,
              border: Border.all(color: Colors.white, width: 2),
              shadows: const [
                BoxShadow(
                  color: Color(0x24000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // User Name & Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Halo, ${user.name}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.white, size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: Colors.white70),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          user.farmLocation ?? 'Malang, Jawa Timur',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.92),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Colors.white70),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AgriBottomNavBar(
        role: UserRole.pebisnis,
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() => _navIndex = index);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            // Search Bar Trigger matching clean mockup design
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SearchResultsScreen(autoFocus: true),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AgriColors.surfaceCardGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8), width: 1.0),
                  boxShadow: AgriColors.softCardShadow,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AgriColors.primaryGreen, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        appState.searchQuery.isNotEmpty
                            ? appState.searchQuery
                            : 'Cari Cabai Merah, Bawang, Tomat...',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: appState.searchQuery.isNotEmpty ? AgriColors.textMain : AgriColors.textHint,
                          fontWeight: appState.searchQuery.isNotEmpty ? FontWeight.w600 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (appState.searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          appState.setSearchQuery(null);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.close_rounded, size: 18, color: AgriColors.textHint),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Promo Banner Carousel
            const PromoBannerCarousel(),
            const SizedBox(height: 22),

            // Category Section Heading
            Text(
              'Kategori Komoditas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 14),

            // 4 Category Pastel Circles in Row matching mockup
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryItem(
                  context,
                  'Sayuran',
                  Icons.eco_rounded,
                  AgriColors.categorySayuranBg,
                  AgriColors.categorySayuranGradient,
                ),
                _buildCategoryItem(
                  context,
                  'Buah',
                  Icons.apple_rounded,
                  AgriColors.categoryBuahBg,
                  AgriColors.categoryBuahGradient,
                ),
                _buildCategoryItem(
                  context,
                  'Palawija',
                  Icons.grass_rounded,
                  AgriColors.categoryPalawijaBg,
                  AgriColors.categoryPalawijaGradient,
                ),
                _buildCategoryItem(
                  context,
                  'Kacang',
                  Icons.bubble_chart_rounded,
                  AgriColors.categoryKacangBg,
                  AgriColors.categoryKacangGradient,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // "Produk Terbaru" Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Produk Terbaru',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AgriColors.textMain,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SearchResultsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AgriColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2-Column Grid of Products matching mockup
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.84,
              ),
              itemCount: products.length > 4 ? 4 : products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductGridCard(
                  product: product,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String label,
    IconData icon,
    Color circleBgColor,
    Gradient gradient,
  ) {
    return GestureDetector(
      onTap: () {
        final appState = Provider.of<AppState>(context, listen: false);
        appState.setCategory(label);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SearchResultsScreen(),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: circleBgColor,
              gradient: gradient,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x181E293B),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: AgriColors.textMain,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AgriColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

