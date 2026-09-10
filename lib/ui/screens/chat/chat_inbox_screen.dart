import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/app_bottom_nav_bar.dart';
import 'package:agrisync/ui/screens/chat/chat_negotiation_screen.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/ui/screens/pebisnis/pebisnis_home_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/search_results_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/favorites_screen.dart';
import 'package:agrisync/ui/screens/petani/petani_home_screen.dart';
import 'package:agrisync/ui/screens/petani/petani_orders_screen.dart';
import 'package:agrisync/ui/screens/admin/admin_dashboard_screen.dart';
import 'package:agrisync/ui/screens/admin/pending_verifications_screen.dart';
import 'package:agrisync/ui/widgets/agri_user_avatar.dart';
import 'package:agrisync/ui/widgets/profile_detail_dialog.dart';
import 'package:agrisync/ui/screens/profile/user_profile_screen.dart';

class ChatInboxScreen extends StatefulWidget {
  final bool isRootTab;

  const ChatInboxScreen({super.key, this.isRootTab = false});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  int _navIndex = 2;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    if (widget.isRootTab && _navIndex != 2) {
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
      if (_navIndex == 1) {
        switch (user.role) {
          case UserRole.pebisnis:
            return const SearchResultsScreen(isRootTab: true);
          case UserRole.petani:
            return const PetaniOrdersScreen(isRootTab: true);
          case UserRole.admin:
            return const PendingVerificationsScreen();
        }
      }
      if (_navIndex == 3) return const UserProfileScreen(isRootTab: true);
    }

    // For pebisnis, tab 2 should ideally open FavoritesScreen if clicked
    if (widget.isRootTab && user.role == UserRole.pebisnis && _navIndex == 2) {
      // If a pebisnis landed here via tab 2, show FavoritesScreen
      return const FavoritesScreen(isRootTab: true);
    }

    final threads = appState.chatThreads;

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: !widget.isRootTab,
      showNotification: true,
      title: 'Inbox Chat Negosiasi',
      bottomNavigationBar: widget.isRootTab
          ? AgriBottomNavBar(
              role: user.role,
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inbox & Negosiasi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AgriColors.textMain,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: threads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 54, color: AgriColors.textHint),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada percakapan negosiasi.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AgriColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: threads.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey.withOpacity(0.2),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final thread = threads[index];
                      final timeStr = DateFormat('HH:mm').format(thread.lastMessageTime);

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatNegotiationScreen(threadId: thread.id),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar with tap-to-profile & online green badge
                              GestureDetector(
                                onTap: () {
                                  final otherUserId = thread.getOtherUserId(user.id);
                                  final otherUser = appState.findUserById(otherUserId);
                                  final isFarmer = thread.getOtherUserRole(user.id).toLowerCase().contains('petani') || (otherUser?.role == UserRole.petani);
                                  final products = isFarmer
                                      ? appState.products.where((p) => p.farmerId == otherUserId || p.farmerName == thread.getOtherUserName(user.id)).toList()
                                      : null;

                                  ProfileDetailDialog.showUserProfileSheet(
                                    context,
                                    name: otherUser?.name ?? thread.getOtherUserName(user.id),
                                    role: otherUser?.roleDisplay ?? thread.getOtherUserRole(user.id),
                                    avatarUrl: otherUser?.avatarUrl ?? thread.avatarUrl,
                                    location: otherUser?.farmLocation ?? (thread.otherUserLocation.isNotEmpty ? thread.otherUserLocation : 'Jawa Timur, Indonesia'),
                                    phone: otherUser?.phone,
                                    email: otherUser?.email,
                                    isVerified: otherUser?.isVerified ?? thread.isVerified,
                                    products: products,
                                  );
                                },
                                child: Stack(
                                  children: [
                                    AgriUserAvatar(
                                      imageUrl: thread.avatarUrl,
                                      name: thread.getOtherUserName(user.id),
                                      radius: 24,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: AgriColors.primaryGreen,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Chat info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            thread.getOtherUserName(user.id),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AgriColors.textMain,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          timeStr,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            color: AgriColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      thread.productTitle,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AgriColors.darkOliveBtn,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            thread.lastMessage,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: AgriColors.textMuted,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (thread.unreadCount > 0)
                                          Container(
                                            margin: const EdgeInsets.only(left: 6),
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AgriColors.primaryGreen,
                                              shape: BoxShape.circle,
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
