import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';
import '../../../data/models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/curved_header_scaffold.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_text_fields.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/agri_product_image.dart';
import '../../../data/services/location_service.dart';
import '../common/map_location_picker_screen.dart';
import 'pebisnis_home_screen.dart';
import 'favorites_screen.dart';
import '../profile/user_profile_screen.dart';
import 'product_detail_screen.dart';
import '../orders/order_history_screen.dart';

class PebisnisCartScreen extends StatefulWidget {
  final bool isRootTab;

  const PebisnisCartScreen({super.key, this.isRootTab = false});

  @override
  State<PebisnisCartScreen> createState() => _PebisnisCartScreenState();
}

class _PebisnisCartScreenState extends State<PebisnisCartScreen> {
  int _navIndex = 1;
  bool _isCheckingOut = false;
  late final TextEditingController _addressController;
  final TextEditingController _notesController = TextEditingController();
  final Map<String, TextEditingController> _itemNotesControllers = {};

  TextEditingController _getNotesController(String productId, [String? initialText]) {
    if (!_itemNotesControllers.containsKey(productId)) {
      _itemNotesControllers[productId] = TextEditingController(text: initialText ?? '');
    }
    return _itemNotesControllers[productId]!;
  }

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _addressController = TextEditingController(
      text: appState.currentUser.farmLocation ?? 'Jl. Ijen No. 45, Klojen, Kota Malang, Jawa Timur',
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    for (final c in _itemNotesControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final cartItems = appState.cartItems;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    if (widget.isRootTab && _navIndex != 1) {
      if (_navIndex == 0) return const PebisnisHomeScreen();
      if (_navIndex == 2) return const FavoritesScreen(isRootTab: true);
      if (_navIndex == 3) return const UserProfileScreen(isRootTab: true);
    }

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: !widget.isRootTab,
      showNotification: true,
      title: 'Keranjang Belanja',
      bottomNavigationBar: widget.isRootTab
          ? AgriBottomNavBar(
              role: UserRole.pebisnis,
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
            )
          : null,
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AgriColors.lightSageBg,
                      shape: BoxShape.circle,
                      boxShadow: AgriColors.softCardShadow,
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: AgriColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Keranjang Belanja Kosong',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AgriColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Belum ada hasil panen komoditas yang ditambahkan.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: AgriColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AgriPillButton(
                    text: '+ CARI SAYURAN SEGAR',
                    width: 220,
                    height: 44,
                    type: AgriButtonType.primaryLime,
                    onPressed: () {
                      if (widget.isRootTab) {
                        setState(() => _navIndex = 0);
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row Header Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${cartItems.length} Komoditas Terpilih',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AgriColors.textMain,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          appState.clearCart();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Keranjang belanja telah dikosongkan')),
                          );
                        },
                        icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: AgriColors.rejectedRed),
                        label: Text(
                          'Kosongkan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AgriColors.rejectedRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Cart Items List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final product = item.product;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AgriColors.surfaceCardGradient,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8)),
                          boxShadow: AgriColors.softCardShadow,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(product: product),
                                      ),
                                    );
                                  },
                                  child: AgriProductImage(
                                    imageUrl: product.imageUrl,
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                                              product.title,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w800,
                                                color: AgriColors.textMain,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close_rounded, size: 18, color: AgriColors.textHint),
                                            visualDensity: VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              appState.removeFromCart(product.id);
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Petani: ${product.farmerName} • ${product.farmerLocation}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          color: AgriColors.textMuted,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${currencyFormatter.format(product.pricePerKg)} / kg',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AgriColors.darkOliveBtn,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            // Stepper & Subtotal Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Stepper
                                Container(
                                  decoration: BoxDecoration(
                                    color: AgriColors.lightSageBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AgriColors.cardBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 16, color: AgriColors.darkOliveBtn),
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          appState.updateCartQuantity(product.id, item.quantityKg - 10);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Text(
                                          '${item.quantityKg} kg',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                            color: AgriColors.textMain,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16, color: AgriColors.darkOliveBtn),
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          if (item.quantityKg + 10 <= product.stockKg) {
                                            appState.updateCartQuantity(product.id, item.quantityKg + 10);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Maksimal stok tersedia: ${product.stockKg} kg')),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // Item Total Price
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Subtotal',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AgriColors.textMuted),
                                    ),
                                    Text(
                                      currencyFormatter.format(item.totalPrice),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AgriColors.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            // Dedicated Notes per Seller/Product
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.sticky_note_2_outlined, size: 15, color: AgriColors.darkOliveBtn),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Catatan Pesanan untuk ${product.farmerName}:',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: AgriColors.darkOliveBtn,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  AgriTextField(
                                    controller: _getNotesController(product.id, item.notes),
                                    hintText: 'Instruksi khusus untuk petani ${product.farmerName} (Contoh: Kemasan peti kayu, petik pagi)...',
                                    maxLines: 2,
                                    onChanged: (val) {
                                      appState.updateCartNotes(product.id, val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // Delivery Address & Order Notes Form Card
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_shipping_outlined, color: AgriColors.primaryGreen, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Alamat Pengiriman',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AgriColors.textMain,
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final LocationResult? result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MapLocationPickerScreen(
                                      title: 'Pilih Alamat Pengiriman',
                                      initialAddress: _addressController.text,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    _addressController.text = result.fullFormattedAddress;
                                  });
                                }
                              },
                              icon: const Icon(Icons.map_rounded, size: 14, color: AgriColors.primaryGreen),
                              label: Text(
                                'Pilih di Peta',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AgriColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AgriTextField(
                          controller: _addressController,
                          hintText: 'Alamat lengkap tujuan pengiriman seluruh hasil panen...',
                          maxLines: 2,
                          prefixIcon: const Icon(Icons.location_on_outlined, color: AgriColors.darkOliveBtn, size: 20),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: AgriColors.primaryGreen),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Catatan khusus untuk masing-masing toko/petani dapat diisi langsung pada kartu komoditas di atas.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AgriColors.darkOliveBtn,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.verified_user_outlined, color: AgriColors.darkOliveBtn, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Transaksi dilindungi Rekening Bersama Escrow AgriSync (100% Aman).',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AgriColors.darkOliveBtn,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cost Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AgriColors.surfaceCardGradient,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8)),
                      boxShadow: AgriColors.softCardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rincian Pembayaran',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AgriColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          'Total Harga Komoditas (${appState.cartTotalQuantity} kg)',
                          currencyFormatter.format(appState.cartSubtotal),
                        ),
                        const SizedBox(height: 6),
                        _buildSummaryRow(
                          'Ongkos Kirim Armada Logistik',
                          currencyFormatter.format(appState.cartEstimatedShipping),
                        ),
                        if (user.isProMember) ...[
                          const SizedBox(height: 6),
                          _buildSummaryRow(
                            'Diskon AgriSync PRO (5%)',
                            '- ${currencyFormatter.format(appState.cartProDiscount)}',
                            isDiscount: true,
                          ),
                        ],
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Tagihan Escrow',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AgriColors.textMain,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(appState.cartGrandTotal),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AgriColors.darkOliveBtn,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Checkout Button
                  AgriPillButton(
                    text: 'CHECKOUT SEKARANG (ESCROW)',
                    type: AgriButtonType.darkOlive,
                    height: 50,
                    isLoading: _isCheckingOut,
                    onPressed: () async {
                      final addr = _addressController.text.trim();
                      if (addr.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Harap masukkan alamat pengiriman.'),
                            backgroundColor: AgriColors.rejectedRed,
                          ),
                        );
                        return;
                      }

                      setState(() => _isCheckingOut = true);
                      await Future.delayed(const Duration(milliseconds: 700));

                      // Create official orders for each item in cart with their respective individual notes
                      for (final item in cartItems) {
                        final specificNote = _itemNotesControllers[item.product.id]?.text.trim() ?? item.notes?.trim();
                        final finalNote = (specificNote != null && specificNote.isNotEmpty)
                            ? specificNote
                            : (_notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null);

                        appState.createOrder(
                          product: item.product,
                          quantityKg: item.quantityKg,
                          agreedPricePerKg: item.product.pricePerKg,
                          deliveryAddress: addr,
                          paymentMethod: 'Escrow Rekber (BCA Virtual Account)',
                          notes: finalNote,
                        );
                      }

                      appState.clearCart();
                      if (!context.mounted) return;
                      setState(() => _isCheckingOut = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pesanan berhasil dibuat & masuk ke Rekber Escrow!'),
                          backgroundColor: AgriColors.primaryGreen,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 4,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isDiscount ? AgriColors.verifiedGreen : AgriColors.textMuted,
              fontWeight: isDiscount ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isDiscount ? AgriColors.verifiedGreen : AgriColors.textMain,
            ),
          ),
        ),
      ],
    );
  }
}
