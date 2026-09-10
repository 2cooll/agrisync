import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/notification_model.dart';
import '../theme/app_colors.dart';

class AgriPushBanner extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback onDismissed;

  const AgriPushBanner({
    super.key,
    required this.notification,
    this.onTap,
    required this.onDismissed,
  });

  static OverlayEntry? _currentEntry;

  /// Tampilkan Push Banner secara global di atas layar
  static void show(
    BuildContext context, {
    required NotificationModel notification,
    VoidCallback? onTap,
  }) {
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => AgriPushBanner(
        notification: notification,
        onTap: () {
          entry.remove();
          _currentEntry = null;
          onTap?.call();
        },
        onDismissed: () {
          entry.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  @override
  State<AgriPushBanner> createState() => _AgriPushBannerState();
}

class _AgriPushBannerState extends State<AgriPushBanner> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animController);

    _animController.forward();

    // Auto dismiss after 4.5 seconds
    _autoDismissTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    if (!mounted) return;
    _animController.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.notification.type) {
      case NotificationType.order:
        return Icons.shopping_bag_rounded;
      case NotificationType.negotiation:
        return Icons.handshake_rounded;
      case NotificationType.chat:
        return Icons.chat_bubble_rounded;
      case NotificationType.harvest:
        return Icons.agriculture_rounded;
      case NotificationType.priceTrend:
        return Icons.trending_up_rounded;
      case NotificationType.promotion:
        return Icons.local_offer_rounded;
      case NotificationType.system:
        return Icons.verified_user_rounded;
    }
  }

  Color _getIconColor() {
    switch (widget.notification.type) {
      case NotificationType.order:
        return AgriColors.primaryGreen;
      case NotificationType.negotiation:
        return const Color(0xFFE65100);
      case NotificationType.chat:
        return const Color(0xFF1565C0);
      case NotificationType.harvest:
        return const Color(0xFF2E7D32);
      case NotificationType.priceTrend:
        return const Color(0xFF00897B);
      case NotificationType.promotion:
        return const Color(0xFFC2185B);
      case NotificationType.system:
        return AgriColors.darkOliveBtn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final iconColor = _getIconColor();

    return Positioned(
      top: topPadding > 0 ? topPadding + 8 : 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onDismissed(),
              child: GestureDetector(
                onTap: widget.onTap ?? _dismiss,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2818).withOpacity(0.96),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.6), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification Icon Badge
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: iconColor.withOpacity(0.5)),
                        ),
                        child: Icon(_getIcon(), color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 14),

                      // Notification Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'AGRISYNC',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.1,
                                        color: AgriColors.primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 3,
                                      height: 3,
                                      decoration: const BoxDecoration(
                                        color: Colors.white54,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Baru saja',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.touch_app_rounded, size: 14, color: Colors.white38),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.notification.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.notification.message,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.85),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
