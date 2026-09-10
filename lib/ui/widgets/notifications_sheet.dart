import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../state/app_state.dart';
import '../../data/models/notification_model.dart';
import '../theme/app_colors.dart';
import '../screens/orders/order_tracking_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../screens/chat/chat_negotiation_screen.dart';

class NotificationsSheet extends StatefulWidget {
  final NotificationCategory initialCategory;

  const NotificationsSheet({
    super.key,
    this.initialCategory = NotificationCategory.all,
  });

  static bool _isSheetOpen = false;

  static void show(BuildContext context, {NotificationCategory initialCategory = NotificationCategory.all}) {
    if (_isSheetOpen) return;
    _isSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AgriColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => NotificationsSheet(initialCategory: initialCategory),
    ).whenComplete(() {
      _isSheetOpen = false;
    });
  }

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  late NotificationCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allNotifications = appState.currentUserNotifications;
    final unreadCount = appState.unreadNotificationCount;

    // Filter notifications by selected category
    final filteredNotifications = _selectedCategory == NotificationCategory.all
        ? allNotifications
        : allNotifications.where((n) => n.category == _selectedCategory).toList();

    // Calculate unread counts per category
    final unreadOrdersPayments = allNotifications
        .where((n) => !n.isRead && n.category == NotificationCategory.ordersPayments)
        .length;
    final unreadPromosNews = allNotifications
        .where((n) => !n.isRead && n.category == NotificationCategory.promosNews)
        .length;
    final unreadSystem = allNotifications
        .where((n) => !n.isRead && n.category == NotificationCategory.systemInfo)
        .length;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Pusat Notifikasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AgriColors.textMain,
                      ),
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AgriColors.rejectedRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$unreadCount Baru',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      appState.markAllNotificationsAsRead();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Tandai Dibaca',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AgriColors.primaryGreen,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AgriColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Tabs Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildCategoryTab(
                    label: 'Semua',
                    icon: Icons.all_inbox_rounded,
                    category: NotificationCategory.all,
                    unreadCount: unreadCount,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryTab(
                    label: 'Pesanan & Bayar',
                    icon: Icons.receipt_long_rounded,
                    category: NotificationCategory.ordersPayments,
                    unreadCount: unreadOrdersPayments,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryTab(
                    label: 'Promo & Berita',
                    icon: Icons.campaign_rounded,
                    category: NotificationCategory.promosNews,
                    unreadCount: unreadPromosNews,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryTab(
                    label: 'Info Sistem',
                    icon: Icons.info_outline_rounded,
                    category: NotificationCategory.systemInfo,
                    unreadCount: unreadSystem,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notification List or Categorized Empty State
            if (filteredNotifications.isEmpty)
              Expanded(
                child: Center(
                  child: _buildEmptyState(_selectedCategory),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredNotifications.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filteredNotifications[index];
                    return _buildNotificationCard(context, item, appState);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab({
    required String label,
    required IconData icon,
    required NotificationCategory category,
    required int unreadCount,
  }) {
    final isSelected = _selectedCategory == category;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AgriColors.darkOliveBtn : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AgriColors.darkOliveBtn : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AgriColors.darkOliveBtn.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AgriColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AgriColors.textMain,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AgriColors.rejectedRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? AgriColors.darkOliveBtn : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(NotificationCategory category) {
    IconData emptyIcon;
    String title;
    String subtitle;

    switch (category) {
      case NotificationCategory.ordersPayments:
        emptyIcon = Icons.shopping_bag_outlined;
        title = 'Belum Ada Transaksi & Pesanan';
        subtitle = 'Pemberitahuan status pesanan baru, pembayaran escrow, dan penawaran harga akan tampil di sini.';
        break;
      case NotificationCategory.promosNews:
        emptyIcon = Icons.local_offer_outlined;
        title = 'Belum Ada Promo & Berita';
        subtitle = 'Voucher diskon komisi platform, tren harga pasar komoditas, dan jadwal panen akan tampil di sini.';
        break;
      case NotificationCategory.systemInfo:
        emptyIcon = Icons.admin_panel_settings_outlined;
        title = 'Belum Ada Info Sistem';
        subtitle = 'Pemberitahuan verifikasi berkas, keamanan akun, dan pembaruan sistem akan tampil di sini.';
        break;
      case NotificationCategory.all:
        emptyIcon = Icons.notifications_none_rounded;
        title = 'Belum Ada Notifikasi';
        subtitle = 'Seluruh aktivitas dan pembaruan penting akun Anda akan muncul di sini.';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: AgriColors.lightSageBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              emptyIcon,
              size: 42,
              color: AgriColors.darkOliveBtn,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AgriColors.textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AgriColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel item, AppState appState) {
    IconData icon;
    Color iconBg;
    Color iconColor;
    String badgeTag;
    Color badgeColor;

    switch (item.type) {
      case NotificationType.order:
        icon = Icons.shopping_bag_rounded;
        iconBg = AgriColors.badgeGreenBg;
        iconColor = AgriColors.darkOliveBtn;
        badgeTag = 'Pesanan & Escrow';
        badgeColor = AgriColors.darkOliveBtn;
        break;
      case NotificationType.negotiation:
        icon = Icons.handshake_rounded;
        iconBg = AgriColors.categorySayuranBg;
        iconColor = AgriColors.darkOliveBtn;
        badgeTag = 'Negosiasi';
        badgeColor = AgriColors.darkOliveBtn;
        break;
      case NotificationType.chat:
        icon = Icons.chat_bubble_rounded;
        iconBg = AgriColors.lightSageBg;
        iconColor = AgriColors.primaryGreen;
        badgeTag = 'Pesan Mitra';
        badgeColor = AgriColors.primaryGreen;
        break;
      case NotificationType.harvest:
        icon = Icons.agriculture_rounded;
        iconBg = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF2E7D32);
        badgeTag = 'Jadwal Panen';
        badgeColor = const Color(0xFF2E7D32);
        break;
      case NotificationType.priceTrend:
        icon = Icons.trending_up_rounded;
        iconBg = const Color(0xFFE0F2F1);
        iconColor = const Color(0xFF00897B);
        badgeTag = 'Tren Pasar';
        badgeColor = const Color(0xFF00897B);
        break;
      case NotificationType.promotion:
        icon = Icons.local_offer_rounded;
        iconBg = const Color(0xFFFCE4EC);
        iconColor = const Color(0xFFC2185B);
        badgeTag = 'Promo Diskon';
        badgeColor = const Color(0xFFC2185B);
        break;
      case NotificationType.system:
        icon = Icons.verified_rounded;
        iconBg = AgriColors.lightSageBg;
        iconColor = AgriColors.verifiedGreen;
        badgeTag = 'Info Sistem';
        badgeColor = AgriColors.verifiedGreen;
        break;
    }

    return InkWell(
      onTap: () {
        appState.markNotificationAsRead(item.id);

        if (item.type == NotificationType.order) {
          Navigator.pop(context);
          if (item.referenceId != null) {
            final orderList = appState.orders.where((o) => o.id == item.referenceId);
            if (orderList.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderTrackingScreen(order: orderList.first),
                ),
              );
              return;
            }
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const OrderHistoryScreen(),
            ),
          );
        } else if (item.type == NotificationType.negotiation || item.type == NotificationType.chat) {
          Navigator.pop(context);
          if (item.referenceId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatNegotiationScreen(threadId: item.referenceId!),
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isRead ? AgriColors.surfaceWhite : AgriColors.lightSageBg.withOpacity(0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead ? AgriColors.cardBorder : AgriColors.primaryGreen.withOpacity(0.5),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge Kategori
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: badgeColor.withOpacity(0.3), width: 0.8),
                        ),
                        child: Text(
                          badgeTag,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimeAgo(item.createdAt),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: AgriColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                      color: AgriColors.textMain,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.8,
                      color: AgriColors.textMain.withOpacity(0.85),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead) ...[
              const SizedBox(width: 6),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AgriColors.rejectedRed,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';
    return DateFormat('dd MMM').format(dateTime);
  }
}
