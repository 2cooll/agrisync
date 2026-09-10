import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/order_model.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/widgets/agri_product_image.dart';
import 'package:agrisync/ui/screens/profile/rating_dialog.dart';
import 'package:agrisync/ui/screens/orders/order_history_screen.dart';
import 'package:agrisync/ui/screens/orders/payment_checkout_screen.dart';


class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;
  final bool isFromCheckout;

  const OrderTrackingScreen({
    super.key,
    required this.order,
    this.isFromCheckout = false,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    // Always get freshest order state from AppState
    final liveOrder = appState.orders.firstWhere((o) => o.id == order.id, orElse: () => order);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    final isFarmer = user.role == UserRole.petani;
    final isBuyer = user.role == UserRole.pebisnis;

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      onBack: () {
        if (isFromCheckout) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          Navigator.of(context).maybePop();
        }
      },
      title: 'Status Pesanan',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Number & Status Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  liveOrder.orderNumber,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
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
                    liveOrder.status.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AgriColors.darkOliveBtn,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Tracking Progress Stepper
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AgriColors.lightSageBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AgriColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildTrackingStep(
                    'Pesanan Dibuat & Pembayaran Diverifikasi',
                    'Dana aman tersimpan di Rekber AgriSync',
                    true,
                    isFirst: true,
                  ),
                  _buildTrackingStep(
                    'Petani Mempersiapkan Hasil Panen',
                    'Sortasi kualitas Grade A & pengemasan higienis',
                    liveOrder.status == OrderStatus.diproses ||
                        liveOrder.status == OrderStatus.dikirim ||
                        liveOrder.status == OrderStatus.selesai,
                  ),
                  _buildTrackingStep(
                    'Dalam Pengiriman ke Lokasi Bisnis',
                    liveOrder.trackingNumber != null
                        ? 'No. Resi: ${liveOrder.trackingNumber}'
                        : 'Menunggu armada logistik pertanian',
                    liveOrder.status == OrderStatus.dikirim || liveOrder.status == OrderStatus.selesai,
                  ),
                  _buildTrackingStep(
                    'Pesanan Diterima & Selesai',
                    'Konfirmasi kualitas barang & pelepasan dana ke petani',
                    liveOrder.status == OrderStatus.selesai,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Product & Price Details
            Text(
              'Rincian Produk',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AgriColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AgriColors.inputBorder.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  AgriProductImage(
                    imageUrl: liveOrder.productImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          liveOrder.productTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AgriColors.textMain,
                          ),
                        ),
                        Text(
                          isFarmer
                              ? 'Pembeli: ${liveOrder.businessName} (${liveOrder.businessType})'
                              : 'Petani: ${liveOrder.farmerName}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AgriColors.textMuted),
                        ),
                        Text(
                          '${liveOrder.quantityKg} kg x ${currencyFormatter.format(liveOrder.agreedPricePerKg)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AgriColors.darkOliveBtn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormatter.format(liveOrder.grandTotal),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AgriColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Delivery Address & Order Notes Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AgriColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AgriColors.inputBorder.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AgriColors.darkOliveBtn, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Alamat Pengiriman:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AgriColors.textMain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: Text(
                      liveOrder.deliveryAddress,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AgriColors.textMuted),
                    ),
                  ),
                  if (liveOrder.notes != null && liveOrder.notes!.trim().isNotEmpty) ...[
                    const Divider(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.sticky_note_2_outlined, color: AgriColors.primaryGreen, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Catatan Pesanan (Instruksi Pembeli):',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AgriColors.textMain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Text(
                        liveOrder.notes!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AgriColors.darkOliveBtn,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // ROLE-SPECIFIC ACTION BUTTONS & NOTICES
            // ==========================================
            if (isFarmer) ...[
              // --- FARMER FLOW ---
              if (liveOrder.status == OrderStatus.diproses)
                AgriPillButton(
                  text: 'KONFIRMASI & SIAPKAN PENGIRIMAN',
                  type: AgriButtonType.primaryLime,
                  height: 48,
                  onPressed: () {
                    appState.updateOrderStatus(liveOrder.id, OrderStatus.dikirim);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pesanan berhasil dikonfirmasi dan dialihkan ke Dalam Pengiriman!'),
                        backgroundColor: AgriColors.primaryGreen,
                      ),
                    );
                  },
                )
              else if (liveOrder.status == OrderStatus.dikirim)
                _buildStatusNoticeCard(
                  icon: Icons.local_shipping_outlined,
                  title: 'Dalam Proses Pengiriman',
                  desc: 'Hasil panen sedang dikirim ke lokasi pembeli. Menunggu konfirmasi penerimaan dari Pebisnis.',
                  color: AgriColors.badgeGreenBg,
                )
              else if (liveOrder.status == OrderStatus.selesai)
                _buildStatusNoticeCard(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Pesanan Telah Selesai',
                  desc: 'Pebisnis telah mengonfirmasi penerimaan barang. Dana telah berhasil diteruskan ke saldo petani Anda.',
                  color: AgriColors.badgeGreenBg,
                ),
            ] else if (isBuyer) ...[
              // --- BUYER (PEBISNIS) FLOW ---
              if (liveOrder.status == OrderStatus.menungguPembayaran) ...[
                _buildStatusNoticeCard(
                  icon: Icons.qr_code_2_rounded,
                  title: 'Menunggu Pembayaran Escrow (${liveOrder.paymentMethod})',
                  desc: 'Selesaikan transaksi melalui QRIS atau Virtual Account agar pesanan segera disiapkan dan dikirim oleh petani.',
                  color: const Color(0xFFFFF3E0),
                ),
                const SizedBox(height: 10),
                AgriPillButton(
                  text: liveOrder.paymentMethod.toLowerCase().contains('qris')
                      ? '📱 TAMPILKAN KODE QRIS & BAYAR'
                      : '💳 BAYAR PESANAN SEKARANG (ESCROW)',
                  type: AgriButtonType.primaryLime,
                  height: 48,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PaymentCheckoutScreen(
                          order: liveOrder,
                          onPaymentSuccess: () {
                            appState.updateOrderStatus(liveOrder.id, OrderStatus.diproses);
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ] else if (liveOrder.status == OrderStatus.diproses)
                _buildStatusNoticeCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Petani Sedang Mempersiapkan Panen',
                  desc: 'Pesanan Anda telah diterima oleh petani dan sedang dalam proses sortasi dan pengemasan sebelum dikirim.',
                  color: AgriColors.lightSageBg,
                )
              else if (liveOrder.status == OrderStatus.dikirim)
                AgriPillButton(
                  text: 'KONFIRMASI PESANAN DITERIMA',
                  type: AgriButtonType.primaryLime,
                  height: 48,
                  onPressed: () {
                    appState.updateOrderStatus(liveOrder.id, OrderStatus.selesai);
                    showDialog(
                      context: context,
                      builder: (_) => RatingDialog(order: liveOrder),
                    );
                  },
                )
              else if (liveOrder.status == OrderStatus.selesai) ...[
                if (!liveOrder.hasReviewed)
                  AgriPillButton(
                    text: 'BERI RATING & ULASAN PETANI',
                    type: AgriButtonType.darkOlive,
                    height: 48,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => RatingDialog(order: liveOrder),
                      );
                    },
                  )
                else
                  _buildStatusNoticeCard(
                    icon: Icons.star_rounded,
                    title: 'Ulasan Telah Diberikan',
                    desc: 'Terima kasih telah memberikan ulasan untuk kualitas hasil panen petani.',
                    color: AgriColors.badgeGreenBg,
                  ),
              ],
            ],

            const SizedBox(height: 12),

            // Payment Gateway Checkout & Escrow Details Button (CPMK 5)
            AgriPillButton(
              text: isFarmer
                  ? 'RINCIAN STATUS PEMBAYARAN ESCROW'
                  : 'RINCIAN PAYMENT GATEWAY & ESCROW',
              type: AgriButtonType.primary,
              height: 46,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentCheckoutScreen(
                      order: liveOrder,
                      onPaymentSuccess: () {
                        // Payment simulated successfully
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            AgriPillButton(
              text: isFarmer
                  ? 'LIHAT SEMUA RIWAYAT PENJUALAN'
                  : 'LIHAT SEMUA RIWAYAT PEMBELIAN',
              type: AgriButtonType.outline,
              height: 46,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const OrderHistoryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            AgriPillButton(
              text: 'KEMBALI KE BERANDA UTAMA',
              type: AgriButtonType.primaryLime,
              height: 46,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusNoticeCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AgriColors.darkOliveBtn, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AgriColors.textMain),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AgriColors.textMuted, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(String title, String desc, bool isDone, {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone ? AgriColors.primaryGreen : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check : Icons.circle,
                size: 14,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: isDone ? AgriColors.primaryGreen : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDone ? AgriColors.textMain : AgriColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AgriColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
