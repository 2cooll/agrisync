import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../theme/app_colors.dart';
import '../screens/chat/chat_inbox_screen.dart';
import 'notifications_sheet.dart';

class AgriCurvedScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final Widget? titleWidget;
  final bool showBack;
  final VoidCallback? onBack;
  final bool showNotification;
  final VoidCallback? onNotification;
  final bool showChat;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final double headerHeight;
  final EdgeInsetsGeometry contentPadding;
  final bool resizeToAvoidBottomInset;
  final List<Widget>? customHeaderContent;

  const AgriCurvedScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.showBack = true,
    this.onBack,
    this.showNotification = false,
    this.onNotification,
    this.showChat = false,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.headerHeight = 110,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    this.resizeToAvoidBottomInset = true,
    this.customHeaderContent,
    // Kept for backward compatibility if any callers pass showMenu, but no-op
    bool showMenu = false,
    VoidCallback? onMenu,
  });

  static int _lastNavTime = 0;
  static bool _canNavigate() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastNavTime < 600) {
      return false;
    }
    _lastNavTime = now;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final appState = Provider.of<AppState>(context);
    final unreadCount = appState.unreadNotificationCount;
    final unreadChats = appState.chatThreads.where((t) => t.unreadCount > 0).length;

    return Scaffold(
      backgroundColor: AgriColors.headerGreen,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Top Green Header Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight + topPadding,
            child: Container(
              height: headerHeight + topPadding,
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, topPadding + 4, 16, 12),
              decoration: const BoxDecoration(
                gradient: AgriColors.headerGradient,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative background organic watermarks
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    top: -40,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),

                  // Header Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Action row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Pojok kiri atas: Tombol Back (atau tidak render jika root tab dengan titleWidget)
                          if (showBack)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                          else if (titleWidget == null)
                            const SizedBox(width: 40),

                          // Title in header
                          if (title != null && titleWidget == null)
                            Expanded(
                              child: Text(
                                title!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else if (titleWidget != null)
                            Expanded(child: titleWidget!)
                          else
                            const Spacer(),

                          // Pojok kanan atas: Chat & Bell Notifikasi dengan Badge Live
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (showChat)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!_canNavigate()) return;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const ChatInboxScreen()),
                                      );
                                    },
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(0.22),
                                            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.06),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 19),
                                          ),
                                        ),
                                        if (unreadChats > 0)
                                          Positioned(
                                            top: -2,
                                            right: -2,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AgriColors.rejectedRed,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.2),
                                                    blurRadius: 3,
                                                  ),
                                                ],
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 16,
                                                minHeight: 16,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$unreadChats',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (showNotification)
                                GestureDetector(
                                  onTap: () {
                                    if (!_canNavigate()) return;
                                    if (onNotification != null) {
                                      onNotification!();
                                    } else {
                                      NotificationsSheet.show(context);
                                    }
                                  },
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.22),
                                          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.06),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.notifications_rounded, color: Colors.white, size: 20),
                                        ),
                                      ),
                                      if (unreadCount > 0)
                                        Positioned(
                                          top: -2,
                                          right: -2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AgriColors.rejectedRed,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 3,
                                                ),
                                              ],
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 16,
                                              minHeight: 16,
                                            ),
                                            child: Center(
                                              child: Text(
                                                unreadCount > 9 ? '9+' : '$unreadCount',
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              if (!showChat && !showNotification)
                                const SizedBox(width: 40),
                            ],
                          ),
                        ],
                      ),
                      if (customHeaderContent != null) ...customHeaderContent!,
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. White Curved Container Sheet
          Positioned.fill(
            top: headerHeight + topPadding - 16,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AgriColors.surfaceCardGradient,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x181E293B),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x0A263914),
                    blurRadius: 6,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: Padding(
                  padding: contentPadding,
                  child: body,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
