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
import 'package:agrisync/ui/widgets/app_bottom_nav_bar.dart';
import 'package:agrisync/ui/screens/pebisnis/pebisnis_home_screen.dart';
import 'package:agrisync/ui/screens/petani/petani_home_screen.dart';
import 'package:agrisync/ui/screens/admin/admin_dashboard_screen.dart';
import 'package:agrisync/ui/screens/chat/chat_inbox_screen.dart';
import 'package:agrisync/ui/screens/profile/user_profile_screen.dart';

class PetaniOrdersScreen extends StatefulWidget {
  final bool isRootTab;

  const PetaniOrdersScreen({super.key, this.isRootTab = false});

  @override
  State<PetaniOrdersScreen> createState() => _PetaniOrdersScreenState();
}

class _PetaniOrdersScreenState extends State<PetaniOrdersScreen> {
  int _navIndex = 1;

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
      if (_navIndex == 2) return const ChatInboxScreen(isRootTab: true);
      if (_navIndex == 3) return const UserProfileScreen(isRootTab: true);
    }

    final orders = appState.mySalesOrders;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: !widget.isRootTab,
      showNotification: true,
      title: 'Riwayat Penjualan Panen',
      bottomNavigationBar: widget.isRootTab
          ? AgriBottomNavBar(
              role: UserRole.petani,
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Penjualan & Pesanan',
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
                    child: Text(
                      'Belum ada riwayat penjualan atau pesanan masuk.',
                      style: GoogleFonts.plusJakartaSans(color: AgriColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AgriColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AgriColors.inputBorder.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.orderNumber,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AgriColors.textMain),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AgriColors.badgeGreenBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order.status.label,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AgriColors.darkOliveBtn),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pembeli: ${order.businessName} (${order.businessType})',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AgriColors.textMain),
                            ),
                            Text(
                              'Produk: ${order.productTitle} • ${order.quantityKg} kg @ ${currencyFormatter.format(order.agreedPricePerKg)}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AgriColors.textMuted),
                            ),
                            Text(
                              'Total Pendapatan: ${currencyFormatter.format(order.grandTotal)}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AgriColors.darkOliveBtn),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Alamat: ${order.deliveryAddress}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                            ),
                            if (order.notes != null && order.notes!.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AgriColors.lightSageBg.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AgriColors.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.sticky_note_2_outlined, size: 14, color: AgriColors.darkOliveBtn),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Catatan: ${order.notes}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: AgriColors.darkOliveBtn,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),

                            // Status update actions for farmer
                            if (order.status == OrderStatus.diproses)
                              AgriPillButton(
                                text: 'KONFIRMASI & SIAPKAN PENGIRIMAN',
                                type: AgriButtonType.primaryLime,
                                height: 38,
                                onPressed: () {
                                  appState.updateOrderStatus(order.id, OrderStatus.dikirim);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pesanan dikonfirmasi dan dialihkan ke Dalam Pengiriman.'),
                                      backgroundColor: AgriColors.primaryGreen,
                                    ),
                                  );
                                },
                              )
                            else if (order.status == OrderStatus.dikirim)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AgriColors.lightSageBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.local_shipping_outlined, size: 16, color: AgriColors.darkOliveBtn),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Sedang dikirim — Menunggu konfirmasi terima oleh pembeli',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: AgriColors.darkOliveBtn,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (order.status == OrderStatus.selesai)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AgriColors.badgeGreenBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline_rounded, size: 16, color: AgriColors.verifiedGreen),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Pesanan Selesai — Dana telah masuk ke saldo Anda',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AgriColors.verifiedGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
