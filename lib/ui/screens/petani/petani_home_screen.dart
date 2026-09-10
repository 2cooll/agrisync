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
import 'package:agrisync/ui/widgets/agri_user_avatar.dart';
import 'package:agrisync/ui/screens/petani/add_product_screen.dart';
import 'package:agrisync/ui/screens/petani/petani_orders_screen.dart';
import 'package:agrisync/ui/screens/chat/chat_inbox_screen.dart';
import 'package:agrisync/ui/screens/profile/user_profile_screen.dart';
import 'package:agrisync/ui/widgets/agri_product_image.dart';
import 'package:agrisync/ui/screens/pebisnis/product_detail_screen.dart';

class PetaniHomeScreen extends StatefulWidget {
  const PetaniHomeScreen({super.key});

  @override
  State<PetaniHomeScreen> createState() => _PetaniHomeScreenState();
}

class _PetaniHomeScreenState extends State<PetaniHomeScreen> {
  int _navIndex = 0;
  int _selectedSection = 0; // 0: Panen Saya, 1: Pasar Komoditas, 2: Feedback Pembeli
  String _marketSearchQuery = '';
  String _marketSelectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    if (_navIndex == 1) {
      return const PetaniOrdersScreen(isRootTab: true);
    } else if (_navIndex == 2) {
      return const ChatInboxScreen(isRootTab: true);
    } else if (_navIndex == 3) {
      return const UserProfileScreen(isRootTab: true);
    }

    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final myProducts = appState.myFarmerProducts;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

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

          // User Name & Farm Location
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.yard_outlined, size: 12, color: Colors.white70),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        user.farmLocation ?? 'Kebun Malang, Jatim',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.92),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AgriBottomNavBar(
        role: UserRole.petani,
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() => _navIndex = index);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (appState.isOfflineMode) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8E1), Color(0xFFFFF3CD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFB300), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300).withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_off_rounded, color: Color(0xFFE65100), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mode Offline Aktif',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE65100),
                            ),
                          ),
                          Text(
                            'Perubahan & data panen baru disimpan di cache lokal perangkat.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFFB78103),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (appState.offlinePendingQueue.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE65100),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${appState.offlinePendingQueue.length} Antrean',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Farmer Verification Status Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: user.isVerified ? AgriColors.badgeGreenBg : AgriColors.lightSageBg,
                gradient: user.isVerified
                    ? const LinearGradient(
                        colors: [Color(0xFFE8F8EA), Color(0xFFDCF4DE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : AgriColors.sageCardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.35)),
                boxShadow: AgriColors.softCardShadow,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AgriColors.primaryGreen,
                    child: Icon(
                      user.isVerified ? Icons.verified : Icons.hourglass_top_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name,
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AgriColors.textMain),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            if (user.isVerified)
                              const Icon(Icons.check_circle, color: AgriColors.darkOliveBtn, size: 16),
                          ],
                        ),
                        Text(
                          user.farmLocation ?? 'Malang, Jawa Timur',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AgriColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Section Switcher Tabs (Panen Saya, Pasar Komoditas, Feedback Pembeli)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AgriColors.lightSageBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AgriColors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSectionTab(
                      index: 0,
                      label: 'Panen Saya',
                      icon: Icons.grass_rounded,
                      badgeCount: myProducts.length,
                    ),
                  ),
                  Expanded(
                    child: _buildSectionTab(
                      index: 1,
                      label: 'Pasar',
                      icon: Icons.storefront_outlined,
                      badgeCount: appState.products.length,
                    ),
                  ),
                  Expanded(
                    child: _buildSectionTab(
                      index: 2,
                      label: 'Ulasan',
                      icon: Icons.star_outline_rounded,
                      badgeCount: appState.myFarmerReceivedReviews.length,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ====================================================
            // TAB 0: PANEN SAYA (MANAJEMEN HASIL PANEN SENDIRI)
            // ====================================================
            if (_selectedSection == 0) ...[
              // 2x2 Metric Cards
              Row(
                children: [
                  _buildMetricCard('Total Produk', '${myProducts.length}', Icons.inventory_2_outlined),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    'Stok Tersedia',
                    '${myProducts.fold(0, (sum, p) => sum + p.stockKg)} kg',
                    Icons.scale_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetricCard('Pesanan Aktif', '${appState.mySalesOrders.length}', Icons.shopping_bag_outlined),
                  const SizedBox(width: 12),
                  _buildMetricCard('Rating Petani', '⭐ ${appState.getFarmerAverageRating(user.id)}', Icons.star_outline),
                ],
              ),
              const SizedBox(height: 20),

              // Button: Tambah Hasil Panen Baru
              AgriPillButton(
                text: '+ TAMBAH HASIL PANEN BARU',
                type: AgriButtonType.primaryLime,
                height: 48,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddProductScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Section Header: Daftar Hasil Panen Saya
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hasil Panen Saya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AgriColors.textMain,
                    ),
                  ),
                  Text(
                    '${myProducts.length} Produk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AgriColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (myProducts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AgriColors.cardBorder),
                    boxShadow: AgriColors.softCardShadow,
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.eco_outlined, size: 48, color: AgriColors.textHint),
                      const SizedBox(height: 10),
                      Text(
                        'Belum ada hasil panen yang diterbitkan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AgriColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tekan tombol "+ Tambah Hasil Panen Baru" di atas untuk mulai mempublikasikan komoditas Anda ke pasar.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AgriColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: myProducts.length,
                  itemBuilder: (context, index) {
                    final prod = myProducts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AgriColors.surfaceCardGradient,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8)),
                        boxShadow: AgriColors.softCardShadow,
                      ),
                      child: Row(
                        children: [
                          AgriProductImage(
                            imageUrl: prod.imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        prod.title,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AgriColors.textMain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (prod.isPendingSync || appState.offlinePendingQueue.any((q) => q['productId'] == prod.id)) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFFFB300), width: 0.8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.cloud_off_rounded, size: 11, color: Color(0xFFE65100)),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            'Menunggu Sinyal Cloud',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFFE65100),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Text(
                                  '${currencyFormatter.format(prod.pricePerKg)}/kg • Stok: ${prod.stockKg} kg',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AgriColors.darkOliveBtn,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Panen: ${prod.harvestEstimate}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: AgriColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Action buttons: Edit & Delete
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AgriColors.darkOliveBtn, size: 19),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                tooltip: 'Edit / Update Sayuran',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AddProductScreen(productToEdit: prod),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AgriColors.rejectedRed, size: 19),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                tooltip: 'Hapus Sayuran',
                                onPressed: () {
                                  appState.deleteProduct(prod.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Produk berhasil dihapus')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],

            // ====================================================
            // TAB 1: PASAR KOMODITAS (JELAJAH PRODUK PETANI LAIN)
            // ====================================================
            if (_selectedSection == 1) ...[
              Text(
                'Pasar Komoditas & Pantau Harga',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AgriColors.textMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lihat pasokan panen dan perbandingan harga dari petani mitra daerah lain.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: AgriColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),

              // Search bar in Market
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AgriColors.inputBorder),
                  boxShadow: AgriColors.softCardShadow,
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _marketSearchQuery = val),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Cari komoditas atau petani...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AgriColors.darkOliveBtn, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    suffixIcon: _marketSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _marketSearchQuery = ''),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category Horizontal Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Semua', 'Sayuran', 'Buah', 'Palawija', 'Kacang'].map((cat) {
                    final isSel = _marketSelectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        selectedColor: AgriColors.darkOliveBtn,
                        backgroundColor: Colors.white,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSel ? Colors.white : AgriColors.textMain,
                        ),
                        onSelected: (_) => setState(() => _marketSelectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Market Products List
              Builder(
                builder: (context) {
                  final allMarketProducts = appState.products.where((p) {
                    final matchesCat = _marketSelectedCategory == 'Semua' || p.category == _marketSelectedCategory;
                    final matchesQuery = _marketSearchQuery.isEmpty ||
                        p.title.toLowerCase().contains(_marketSearchQuery.toLowerCase()) ||
                        p.farmerName.toLowerCase().contains(_marketSearchQuery.toLowerCase()) ||
                        p.farmerLocation.toLowerCase().contains(_marketSearchQuery.toLowerCase());
                    return matchesCat && matchesQuery;
                  }).toList();

                  if (allMarketProducts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'Tidak ada komoditas yang cocok dengan pencarian.',
                          style: GoogleFonts.plusJakartaSans(color: AgriColors.textMuted),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allMarketProducts.length,
                    itemBuilder: (context, index) {
                      final prod = allMarketProducts[index];
                      final isMine = prod.farmerId == user.id;

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: prod),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isMine ? AgriColors.primaryGreen.withOpacity(0.5) : AgriColors.cardBorder,
                              width: isMine ? 1.5 : 1.0,
                            ),
                            boxShadow: AgriColors.softCardShadow,
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  AgriProductImage(
                                    imageUrl: prod.imageUrl,
                                    width: 75,
                                    height: 75,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  if (isMine)
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AgriColors.darkOliveBtn,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Milik Anda',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
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
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AgriColors.textMain,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AgriColors.badgeGreenBg,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            prod.qualityGrade,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: AgriColors.darkOliveBtn,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${currencyFormatter.format(prod.pricePerKg)}/kg • Stok: ${prod.stockKg} kg',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AgriColors.darkOliveBtn,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline_rounded, size: 13, color: AgriColors.textMuted),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            '${prod.farmerName} (${prod.farmerLocation})',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              color: AgriColors.textMuted,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AgriColors.textHint, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],

            // ====================================================
            // TAB 2: FEEDBACK & ULASAN DARI PEMBELI
            // ====================================================
            if (_selectedSection == 2) ...[
              // Farmer Overall Reputation Card
              Builder(
                builder: (context) {
                  final reviews = appState.getFarmerReviews(user.id);
                  final avgScore = appState.getFarmerAverageRating(user.id);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF263211), Color(0xFF384918)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AgriColors.softCardShadow,
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reputasi Toko Petani',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$avgScore',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      ' / 5.0',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Berdasarkan ${reviews.length} ulasan dari pemesan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.verified_rounded, color: AgriColors.primaryGreen, size: 36),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Semua Ulasan & Testimoni Pemesan (${reviews.length})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AgriColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (reviews.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AgriColors.cardBorder),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.rate_review_outlined, size: 48, color: AgriColors.textHint),
                              const SizedBox(height: 10),
                              Text(
                                'Belum Ada Feedback Ulasan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AgriColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ulasan bintang dan komentar penilaian dari restoran/pembeli yang memesan komoditas Anda akan otomatis tampil di sini.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AgriColors.textMuted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final rev = reviews[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8)),
                                boxShadow: AgriColors.softCardShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 14,
                                              backgroundColor: AgriColors.badgeGreenBg,
                                              child: Icon(Icons.storefront_rounded, size: 16, color: AgriColors.darkOliveBtn),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                rev.buyerName,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: AgriColors.textMain,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            i < rev.rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AgriColors.lightSageBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Order ${rev.quantityKg} kg • ${rev.productTitle}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: AgriColors.darkOliveBtn,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '"${rev.comment}"',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: AgriColors.textMain,
                                      fontStyle: FontStyle.italic,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTab({
    required int index,
    required String label,
    required IconData icon,
    required int badgeCount,
  }) {
    final isSelected = _selectedSection == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedSection = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AgriColors.darkOliveBtn : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x20000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AgriColors.textMain,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AgriColors.textMain,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? AgriColors.primaryGreen : AgriColors.inputBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black87 : AgriColors.textMain,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AgriColors.sageCardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8)),
          boxShadow: AgriColors.softCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AgriColors.darkOliveBtn, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AgriColors.darkOliveBtn,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AgriColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
