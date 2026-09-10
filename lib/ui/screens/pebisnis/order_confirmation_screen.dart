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
import 'package:agrisync/ui/widgets/custom_text_fields.dart';
import 'package:agrisync/ui/screens/orders/order_tracking_screen.dart';
import 'package:agrisync/ui/screens/orders/payment_checkout_screen.dart';
import 'package:agrisync/data/models/order_model.dart';
import 'package:agrisync/data/services/location_service.dart';
import 'package:agrisync/ui/screens/common/map_location_picker_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final ProductModel product;
  final int agreedPrice;
  final int defaultQuantity;

  const OrderConfirmationScreen({
    super.key,
    required this.product,
    required this.agreedPrice,
    this.defaultQuantity = 100,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  late int _quantity;
  late TextEditingController _qtyController;
  final _addressController = TextEditingController(text: 'Jl. Ijen No. 45, Klojen, Kota Malang, Jawa Timur');
  final _notesController = TextEditingController();
  String _selectedPaymentMethod = 'Rekber AgriSync (Escrow Aman)';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default quantity adjusted to available stock
    final available = widget.product.stockKg;
    _quantity = widget.defaultQuantity <= available
        ? widget.defaultQuantity
        : (available > 0 ? available : 1);
    _qtyController = TextEditingController(text: _quantity.toString());
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQty) {
    final maxStock = widget.product.stockKg;
    if (newQty < 1) newQty = 1;
    if (maxStock > 0 && newQty > maxStock) newQty = maxStock;

    setState(() {
      _quantity = newQty;
      _qtyController.text = newQty.toString();
    });
  }

  void _confirmAndPay() {
    if (_isLoading) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final currentProduct = appState.allProducts.firstWhere(
      (p) => p.id == widget.product.id,
      orElse: () => widget.product,
    );
    final maxStock = currentProduct.stockKg;

    if (_quantity < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah pembelian minimal 1 kg.')),
      );
      return;
    }

    if (maxStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maaf, stok komoditas ini telah habis.'),
          backgroundColor: AgriColors.rejectedRed,
        ),
      );
      return;
    }

    if (_quantity > maxStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jumlah melebihi stok yang tersedia ($maxStock kg).'),
          backgroundColor: AgriColors.rejectedRed,
        ),
      );
      return;
    }

    if (appState.currentUser.role != UserRole.pebisnis) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya akun Pebisnis yang dapat melakukan pemesanan komoditas.'),
          backgroundColor: AgriColors.rejectedRed,
        ),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap masukkan alamat pengiriman.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final navigator = Navigator.of(context);
    final qty = _quantity;
    final price = widget.agreedPrice;
    final addr = _addressController.text.trim();
    final payMethod = _selectedPaymentMethod;
    final notes = _notesController.text.trim();

    final newOrder = appState.createOrder(
      product: currentProduct,
      quantityKg: qty,
      agreedPricePerKg: price,
      deliveryAddress: addr,
      paymentMethod: payMethod,
      notes: notes,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (payMethod.toLowerCase().contains('qris') || payMethod.toLowerCase().contains('e-wallet')) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentCheckoutScreen(
              order: newOrder,
              onPaymentSuccess: () {
                appState.updateOrderStatus(newOrder.id, OrderStatus.diproses);
              },
            ),
          ),
        );
      } else {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(
              order: newOrder,
              isFromCheckout: true,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final total = _quantity * widget.agreedPrice;
    final maxStock = widget.product.stockKg;

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      title: 'Order Confirmation',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konfirmasi Pesanan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 20),

            // Order Summary breakdown table matching mockup
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AgriColors.lightSageBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AgriColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Produk:', widget.product.title, isBoldValue: true),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Petani:', widget.product.farmerName),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Stok Tersedia:', '$maxStock kg'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Harga Sepakat:', '${currencyFormatter.format(widget.agreedPrice)}/kg'),
                  const Divider(height: 24, thickness: 1, color: AgriColors.cardBorder),
                  _buildSummaryRow(
                    'Total:',
                    currencyFormatter.format(total),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Interactive Quantity Selector (Stepper + Input Field)
            Text(
              'Tentukan Jumlah Pembelian (kg)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AgriColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AgriColors.inputBorder, width: 1.2),
              ),
              child: Row(
                children: [
                  // Minus Button
                  InkWell(
                    onTap: _quantity > 1 ? () => _updateQuantity(_quantity - 10 > 0 ? _quantity - 10 : 1) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _quantity > 1 ? AgriColors.lightSageBg : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 20,
                        color: _quantity > 1 ? AgriColors.darkOliveBtn : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Quantity Text Input
                  Expanded(
                    child: TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AgriColors.textMain,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        suffixText: 'kg',
                        isDense: true,
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null) {
                          setState(() {
                            _quantity = parsed;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Plus Button
                  InkWell(
                    onTap: _quantity < maxStock ? () => _updateQuantity(_quantity + 10 <= maxStock ? _quantity + 10 : maxStock) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _quantity < maxStock ? AgriColors.primaryGreen : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: _quantity < maxStock ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Maksimal pembelian: $maxStock kg sesuai stok panen petani saat ini.',
              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
            ),
            const SizedBox(height: 20),

            // Address field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alamat Pengiriman',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AgriColors.textMain,
                  ),
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
                  icon: const Icon(Icons.map_rounded, size: 16, color: AgriColors.primaryGreen),
                  label: Text(
                    'Pilih di Peta (OSM)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
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
              hintText: 'Alamat lengkap pengiriman...',
              maxLines: 2,
              prefixIcon: const Icon(Icons.location_on_outlined, color: AgriColors.darkOliveBtn, size: 20),
            ),
            const SizedBox(height: 16),

            // Catatan Pesanan / Notes
            Text(
              'Catatan Pesanan (Instruksi Khusus)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            AgriTextField(
              controller: _notesController,
              hintText: 'Contoh: Kemasan peti kayu, panen pagi hari, atau instruksi pengiriman khusus...',
              maxLines: 2,
              prefixIcon: const Icon(Icons.sticky_note_2_outlined, color: AgriColors.darkOliveBtn, size: 20),
            ),
            const SizedBox(height: 16),

            // Payment Method Selector
            Text(
              'Metode Pembayaran',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AgriColors.surfaceWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AgriColors.inputBorder, width: 1.2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AgriColors.darkOliveBtn),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AgriColors.textMain,
                  ),
                  items: [
                    'Rekber AgriSync (Escrow Aman)',
                    'Transfer Bank BCA',
                    'Transfer Bank Mandiri',
                    'QRIS / E-Wallet',
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPaymentMethod = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Escrow guarantee banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AgriColors.badgeGreenBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: AgriColors.primaryGreen, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dana Anda ditampung di Rekening Bersama AgriSync dan baru diteruskan ke petani setelah panen diterima sesuai standar.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AgriColors.textMain,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Button: KONFIRMASI PESANAN & BAYAR matching Mockup 2 Screen 4
            AgriPillButton(
              text: 'KONFIRMASI PESANAN & BAYAR (${currencyFormatter.format(total)})',
              type: AgriButtonType.darkOlive,
              isLoading: _isLoading,
              height: 50,
              onPressed: _confirmAndPay,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBoldValue = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 4,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              color: isTotal ? AgriColors.textMain : AgriColors.textMuted,
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
              fontSize: isTotal ? 17 : 14,
              fontWeight: isTotal || isBoldValue ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? AgriColors.darkOliveBtn : AgriColors.textMain,
            ),
          ),
        ),
      ],
    );
  }
}
