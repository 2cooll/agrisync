import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/product_model.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/widgets/agri_product_image.dart';
import 'package:agrisync/ui/screens/chat/chat_negotiation_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/order_confirmation_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  void _showFarmerProfileSheet(BuildContext context, AppState appState) {
    final farmerProducts = appState.allProducts.where((p) => p.farmerId == product.farmerId).toList();
    final farmerReviews = appState.getFarmerReviews(product.farmerId);
    final avgRating = appState.getFarmerAverageRating(product.farmerId);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: const BoxDecoration(
            color: AgriColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Modal Grabber
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Sheet
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: AgriColors.badgeGreenBg,
                      child: Icon(Icons.agriculture_rounded, color: AgriColors.darkOliveBtn, size: 30),
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
                                  product.farmerName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AgriColors.textMain,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (product.isFarmerVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: AgriColors.primaryGreen, size: 16),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '📍 ${product.farmerLocation}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: AgriColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 3),
                              Text(
                                '$avgRating',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AgriColors.textMain,
                                ),
                              ),
                              Text(
                                ' (${farmerReviews.length} Ulasan Pembeli)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AgriColors.textMuted,
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
              const Divider(height: 20),

              // Tabs / Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Section 1: Etalase Komoditas
                    Text(
                      'Etalase Komoditas Petani (${farmerProducts.length})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AgriColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (farmerProducts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Belum ada komoditas lain yang dipublikasikan.',
                          style: GoogleFonts.plusJakartaSans(color: AgriColors.textMuted, fontSize: 13),
                        ),
                      )
                    else
                      ...farmerProducts.map((p) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AgriColors.cardBorder),
                              boxShadow: AgriColors.softCardShadow,
                            ),
                            child: Row(
                              children: [
                                AgriProductImage(
                                  imageUrl: p.imageUrl,
                                  width: 55,
                                  height: 55,
                                  borderRadius: BorderRadius.circular(8),
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.title,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: AgriColors.textMain,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${currencyFormatter.format(p.pricePerKg)}/kg • Stok: ${p.stockKg} kg',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AgriColors.darkOliveBtn,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AgriColors.badgeGreenBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.qualityGrade,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AgriColors.darkOliveBtn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),

                    const SizedBox(height: 18),

                    // Section 2: Feedback & Ulasan dari Pemesan
                    Text(
                      'Feedback & Ulasan Pembeli (${farmerReviews.length})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AgriColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (farmerReviews.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AgriColors.cardBorder),
                        ),
                        child: Text(
                          'Belum ada ulasan feedback untuk petani ini.',
                          style: GoogleFonts.plusJakartaSans(color: AgriColors.textMuted, fontSize: 13),
                        ),
                      )
                    else
                      ...farmerReviews.map((rev) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8)),
                              boxShadow: AgriColors.softCardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: AgriColors.lightSageBg,
                                          child: Icon(Icons.storefront, size: 14, color: AgriColors.darkOliveBtn),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          rev.buyerName,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AgriColors.textMain,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < rev.rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                                          color: Colors.amber,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Pembelian ${rev.quantityKg} kg ${rev.productTitle}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AgriColors.darkOliveBtn,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '"${rev.comment}"',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    color: AgriColors.textMain,
                                    fontStyle: FontStyle.italic,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final liveProduct = appState.allProducts.firstWhere(
      (p) => p.id == product.id,
      orElse: () => product,
    );
    final isFav = appState.isFavorite(liveProduct.id);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final productReviews = appState.getProductReviews(liveProduct.id);
    final avgRating = appState.getProductAverageRating(liveProduct.id);
    final isOutOfStock = liveProduct.stockKg <= 0;

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      showNotification: true,
      title: 'Detail Produk',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Crop Image matching Mockup 5
            Stack(
              children: [
                AgriProductImage(
                  imageUrl: liveProduct.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(16),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      appState.toggleFavorite(liveProduct.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFav
                                ? '${liveProduct.title} dihapus dari daftar favorit'
                                : '${liveProduct.title} ditambahkan ke daftar favorit',
                          ),
                          backgroundColor: isFav ? AgriColors.darkOliveBtn : AgriColors.primaryGreen,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? AgriColors.rejectedRed : AgriColors.textHint,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Product Title & Rating Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        liveProduct.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AgriColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$avgRating',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AgriColors.textMain,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${productReviews.length} Ulasan Feedback)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AgriColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AgriColors.badgeGreenBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              liveProduct.qualityGrade,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AgriColors.darkOliveBtn,
                              ),
                            ),
                          ),
                          if (isOutOfStock) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AgriColors.rejectedRed.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'HABIS',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AgriColors.rejectedRed,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Detail Box 1: Nama Produk
            _buildDetailBox('Nama Produk', liveProduct.title),
            const SizedBox(height: 10),

            // Detail Box 2: Petani (With View Profile Action)
            GestureDetector(
              onTap: () => _showFarmerProfileSheet(context, appState),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: AgriColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.4), width: 1.2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Petani: ${liveProduct.farmerName}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AgriColors.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AgriColors.badgeGreenBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Profil & Toko',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AgriColors.darkOliveBtn,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.chevron_right_rounded, size: 14, color: AgriColors.darkOliveBtn),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Detail Box 3: Lokasi
            _buildDetailBox('Lokasi Kebun', liveProduct.farmerLocation),
            const SizedBox(height: 10),

            // Detail Box 4: Harga
            _buildDetailBox('Harga Pasaran', '${currencyFormatter.format(liveProduct.pricePerKg)}/kg'),
            const SizedBox(height: 10),

            // Detail Box 5: Stok
            _buildDetailBox(
              'Stok Tersedia',
              isOutOfStock ? 'Stok Habis (0 kg)' : '${liveProduct.stockKg} kg',
            ),
            const SizedBox(height: 10),

            // Detail Box 6: Kualitas & Estimasi Panen
            _buildDetailBox(
              'Kualitas & Panen',
              '${liveProduct.qualityGrade} • Estimasi Panen: ${liveProduct.harvestEstimate}',
            ),
            const SizedBox(height: 10),

            // Detail Box 7: Description
            _buildDetailBox('Deskripsi Hasil Panen', liveProduct.description, maxLines: 3),

            const SizedBox(height: 20),

            // ====================================================
            // SECTION: RATING & FEEDBACK PEMBELIAN DARI PEMESAN
            // ====================================================
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AgriColors.cardBorder, width: 1.2),
                boxShadow: AgriColors.softCardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.rate_review_outlined, color: AgriColors.darkOliveBtn, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Feedback Pembeli (${productReviews.length})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AgriColors.textMain,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 2),
                          Text(
                            '$avgRating / 5.0',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AgriColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  if (productReviews.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text(
                          'Belum ada ulasan feedback untuk komoditas ini.\nJadilah pemesan pertama yang memberikan ulasan!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: AgriColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ),
                    )
                  else
                    ...productReviews.map(
                      (rev) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AgriColors.lightSageBg.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AgriColors.cardBorder.withOpacity(0.6)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: AgriColors.badgeGreenBg,
                                      child: Icon(Icons.person, size: 14, color: AgriColors.darkOliveBtn),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      rev.buyerName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AgriColors.textMain,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < rev.rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '"${rev.comment}"',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: AgriColors.textMain,
                                fontStyle: FontStyle.italic,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bottom Action Buttons (Role-Aware)
            if (appState.currentUser.role == UserRole.petani)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AgriColors.lightSageBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AgriColors.cardBorder, width: 1.2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.agriculture_rounded, color: AgriColors.darkOliveBtn, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          product.farmerId == appState.currentUser.id
                              ? 'HASIL PANEN ANDA SENDIRI'
                              : 'PRODUK MITRA PETANI LAIN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AgriColors.darkOliveBtn,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.farmerId == appState.currentUser.id
                          ? 'Kelola stok dan pantau pesanan masuk untuk komoditas ini dari Dashboard Petani.'
                          : 'Akun Petani dapat memantau harga komoditas ini sebagai acuan panen daerah.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AgriColors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  // "+ Keranjang" Icon Button
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: isOutOfStock ? Colors.grey.shade200 : AgriColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isOutOfStock ? Colors.grey.shade400 : AgriColors.darkOliveBtn,
                        width: 1.5,
                      ),
                      boxShadow: isOutOfStock ? null : AgriColors.softCardShadow,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add_shopping_cart_rounded,
                        color: isOutOfStock ? Colors.grey.shade500 : AgriColors.darkOliveBtn,
                        size: 22,
                      ),
                      tooltip: isOutOfStock ? 'Stok Habis' : 'Tambah ke Keranjang',
                      onPressed: isOutOfStock
                          ? null
                          : () {
                              final defaultQty = liveProduct.stockKg >= 50 ? 50 : liveProduct.stockKg;
                              appState.addToCart(liveProduct, quantityKg: defaultQty > 0 ? defaultQty : 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${liveProduct.title} ditambahkan ke keranjang!'),
                                  backgroundColor: AgriColors.primaryGreen,
                                  action: SnackBarAction(
                                    label: 'Lihat',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const PebisnisCartScreen()),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // "CHAT/NEGOSIASI" Button (Lime Green)
                  Expanded(
                    child: AgriPillButton(
                      text: 'CHAT/NEGOSIASI',
                      type: AgriButtonType.primaryLime,
                      height: 48,
                      onPressed: () {
                        final thread = appState.getOrCreateThreadForProduct(liveProduct);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatNegotiationScreen(threadId: thread.id),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // "AJUKAN PEMBELIAN" Button (Dark Olive or Disabled)
                  Expanded(
                    child: AgriPillButton(
                      text: isOutOfStock ? 'STOK HABIS' : 'AJUKAN PEMBELIAN',
                      type: isOutOfStock ? AgriButtonType.outline : AgriButtonType.darkOlive,
                      height: 48,
                      onPressed: isOutOfStock
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrderConfirmationScreen(
                                    product: liveProduct,
                                    agreedPrice: liveProduct.pricePerKg,
                                    defaultQuantity: 100,
                                  ),
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBox(String label, String value, {int maxLines = 1}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AgriColors.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AgriColors.inputBorder.withOpacity(0.7), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: $value',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AgriColors.textMain,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
