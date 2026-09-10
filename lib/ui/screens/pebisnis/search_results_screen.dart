import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/product_card.dart';
import 'package:agrisync/ui/widgets/app_bottom_nav_bar.dart';
import 'package:agrisync/ui/screens/pebisnis/filter_options_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/product_detail_screen.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/ui/screens/pebisnis/pebisnis_home_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/cart_screen.dart';
import 'package:agrisync/ui/screens/petani/petani_home_screen.dart';
import 'package:agrisync/ui/screens/petani/petani_orders_screen.dart';
import 'package:agrisync/ui/screens/admin/admin_dashboard_screen.dart';
import 'package:agrisync/ui/screens/admin/pending_verifications_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/favorites_screen.dart';
import 'package:agrisync/ui/screens/chat/chat_inbox_screen.dart';
import 'package:agrisync/ui/screens/profile/user_profile_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final bool isRootTab;
  final bool autoFocus;

  const SearchResultsScreen({
    super.key,
    this.isRootTab = false,
    this.autoFocus = false,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  int _navIndex = 1;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.searchQuery.isNotEmpty) {
        _searchController.text = appState.searchQuery;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    if (widget.isRootTab && _navIndex != 1) {
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
      if (_navIndex == 3) return const UserProfileScreen(isRootTab: true);
    }
    final products = appState.filteredProducts;

    return AgriCurvedScaffold(
      headerHeight: 65,
      showBack: !widget.isRootTab,
      showMenu: false,
      title: 'Katalog & Pencarian',
      bottomNavigationBar: widget.isRootTab
          ? AgriBottomNavBar(
              role: user.role,
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const FilterOptionsScreen(),
            ),
          );
        },
        backgroundColor: AgriColors.darkOliveBtn,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Search Input Bar
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: AgriColors.surfaceCardGradient,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8), width: 1.0),
              boxShadow: AgriColors.softCardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: widget.autoFocus,
                    textInputAction: TextInputAction.search,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AgriColors.textMain,
                    ),
                    onSubmitted: (value) {
                      final query = value.trim();
                      appState.setSearchQuery(query.isEmpty ? null : query);
                    },
                    onChanged: (value) {
                      final query = value.trim();
                      appState.setSearchQuery(query.isEmpty ? null : query);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari komoditas, kualitas, atau nama petani...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AgriColors.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(Icons.search, color: AgriColors.primaryGreen, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: AgriColors.textHint),
                              onPressed: () {
                                _searchController.clear();
                                appState.setSearchQuery(null);
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Active Category / Filter Pills
          if (appState.selectedCategory != null || appState.filterQuality != 'Semua')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (appState.selectedCategory != null)
                      _buildFilterBadge(
                        'Kategori: ${appState.selectedCategory}',
                        () => appState.setCategory(null),
                      ),
                    if (appState.filterQuality != 'Semua')
                      _buildFilterBadge(
                        'Kualitas: ${appState.filterQuality}',
                        () => appState.setFilters(
                          minPrice: appState.filterMinPrice,
                          maxPrice: appState.filterMaxPrice,
                          minStock: appState.filterMinStock,
                          maxStock: appState.filterMaxStock,
                          quality: 'Semua',
                          location: appState.filterLocation,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // List of Product Cards matching Mockup
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 54, color: AgriColors.textHint),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada produk yang cocok.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AgriColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            appState.resetFilters();
                          },
                          child: Text(
                            'Reset Pencarian & Filter',
                            style: GoogleFonts.plusJakartaSans(
                              color: AgriColors.primaryGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: products.length,
                    padding: const EdgeInsets.only(top: 6, bottom: 70),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductSearchResultCard(
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AgriColors.badgeGreenBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AgriColors.verifiedGreen,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 14, color: AgriColors.verifiedGreen),
          ),
        ],
      ),
    );
  }
}

