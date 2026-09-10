import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/widgets/app_bottom_nav_bar.dart';
import 'package:agrisync/ui/widgets/agri_product_image.dart';
import 'package:agrisync/ui/screens/pebisnis/pebisnis_home_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/cart_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/search_results_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/product_detail_screen.dart';
import 'package:agrisync/ui/screens/profile/user_profile_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final bool isRootTab;

  const FavoritesScreen({super.key, this.isRootTab = false});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _navIndex = 2;

  @override
  Widget build(BuildContext context) {
    if (widget.isRootTab && _navIndex != 2) {
      if (_navIndex == 0) return const PebisnisHomeScreen();
      if (_navIndex == 1) return const PebisnisCartScreen(isRootTab: true);
      if (_navIndex == 3) return const UserProfileScreen(isRootTab: true);
    }

    final appState = Provider.of<AppState>(context);
    final favorites = appState.favoriteProducts;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: !widget.isRootTab,
      showNotification: true,
      title: 'Sayuran Ditandai',
      bottomNavigationBar: widget.isRootTab
          ? AgriBottomNavBar(
              role: UserRole.pebisnis,
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Sayuran Ditandai',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AgriColors.textMain,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AgriColors.badgeGreenBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${favorites.length} Item',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AgriColors.darkOliveBtn,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (favorites.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AgriColors.lightSageBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 48,
                          color: AgriColors.darkOliveBtn,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum Ada Sayuran Ditandai',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AgriColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Tandai komoditas sayuran yang Anda incar untuk memantau harga dan stok secara praktis.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: AgriColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 200,
                        child: AgriPillButton(
                          text: 'JELAJAHI SAYURAN',
                          type: AgriButtonType.primaryLime,
                          height: 44,
                          onPressed: () {
                            if (widget.isRootTab) {
                              setState(() => _navIndex = 1);
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const SearchResultsScreen()),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: favorites.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final prod = favorites[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AgriColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AgriColors.cardBorder, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AgriProductImage(
                              imageUrl: prod.imageUrl,
                              width: 85,
                              height: 85,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          prod.title,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AgriColors.textMain,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.favorite_rounded, color: AgriColors.rejectedRed, size: 22),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Hapus dari Favorit',
                                        onPressed: () {
                                          appState.toggleFavorite(prod.id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${prod.title} dihapus dari daftar favorit'),
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${currencyFormatter.format(prod.pricePerKg)}/kg',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AgriColors.darkOliveBtn,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Stok: ${prod.stockKg} kg • ${prod.farmerLocation}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: AgriColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Petani: ${prod.farmerName}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AgriColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18, color: AgriColors.cardBorder),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AgriColors.darkOliveBtn,
                                  side: const BorderSide(color: AgriColors.cardBorder),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(product: prod),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Lihat Detail',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AgriColors.darkOliveBtn,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(product: prod),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Beli / Nego',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
