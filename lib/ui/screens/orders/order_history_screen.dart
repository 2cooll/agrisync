import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/order_model.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/agri_product_image.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/screens/profile/rating_dialog.dart';
import 'package:agrisync/ui/screens/orders/order_tracking_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final isFarmer = user.role == UserRole.petani;
    final isBuyer = user.role == UserRole.pebisnis;

    final List<OrderModel> orders = isFarmer
        ? appState.mySalesOrders
        : (isBuyer ? appState.myPurchaseOrders : appState.orders);

    final screenTitle = isFarmer
        ? 'Riwayat Penjualan'
        : (isBuyer ? 'Riwayat Pembelian' : 'Riwayat Transaksi');

    final emptyMessage = isFarmer
        ? 'Belum ada riwayat penjualan hasil panen.'
        : (isBuyer ? 'Belum ada riwayat pembelian komoditas.' : 'Belum ada riwayat pesanan.');

    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      title: screenTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            screenTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AgriColors.textMain,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 54, color: AgriColors.textHint),
                        const SizedBox(height: 12),
                        Text(
                          emptyMessage,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AgriColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AgriColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AgriColors.inputBorder.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.orderNumber,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AgriColors.textMain,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: order.status == OrderStatus.selesai
                                        ? AgriColors.badgeGreenBg
                                        : AgriColors.lightSageBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order.status.label,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AgriColors.darkOliveBtn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isFarmer
                                  ? 'Pembeli: ${order.businessName} (${order.businessType})'
                                  : 'Petani Penjual: ${order.farmerName}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AgriColors.darkOliveBtn,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateStr,
                              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                            ),
                            const Divider(height: 16),
                            Row(
                              children: [
                                AgriProductImage(
                                  imageUrl: order.productImageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.productTitle,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: AgriColors.textMain,
                                        ),
                                      ),
                                      Text(
                                        '${order.quantityKg} kg • ${currencyFormatter.format(order.grandTotal)}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: AgriColors.darkOliveBtn,
                                        ),
                                      ),
                                      if (order.notes != null && order.notes!.trim().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Catatan: ${order.notes}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic,
                                            color: AgriColors.textMuted,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AgriPillButton(
                                    text: 'Lacak Pesanan',
                                    type: AgriButtonType.outline,
                                    height: 38,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => OrderTrackingScreen(order: order),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (user.role == UserRole.pebisnis &&
                                    order.status == OrderStatus.selesai &&
                                    !order.hasReviewed) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AgriPillButton(
                                      text: 'Beri Ulasan',
                                      type: AgriButtonType.primaryLime,
                                      height: 38,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => RatingDialog(order: order),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
