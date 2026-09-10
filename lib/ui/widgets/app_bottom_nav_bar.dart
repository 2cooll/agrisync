import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/user_model.dart';
import '../theme/app_colors.dart';

class AgriBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final UserRole role;

  const AgriBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.role = UserRole.pebisnis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AgriColors.surfaceWhite,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFAFDF7),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AgriColors.cardBorder.withOpacity(0.6),
            width: 1,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E1E293B),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildNavItemsForRole(role),
        ),
      ),
    );
  }

  List<Widget> _buildNavItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.petani:
        return [
          _buildNavItem(0, 'Beranda', Icons.home_outlined, Icons.home_rounded),
          _buildNavItem(1, 'Pesanan', Icons.shopping_bag_outlined, Icons.shopping_bag_rounded),
          _buildNavItem(2, 'Inbox Chat', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
          _buildNavItem(3, 'Profil', Icons.person_outline_rounded, Icons.person_rounded),
        ];
      case UserRole.admin:
        return [
          _buildNavItem(0, 'Dashboard', Icons.dashboard_outlined, Icons.dashboard_rounded),
          _buildNavItem(1, 'Verifikasi', Icons.verified_user_outlined, Icons.verified_user_rounded),
          _buildNavItem(2, 'Chat', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
          _buildNavItem(3, 'Profil', Icons.person_outline_rounded, Icons.person_rounded),
        ];
      case UserRole.pebisnis:
      default:
        return [
          _buildNavItem(0, 'Beranda', Icons.home_outlined, Icons.home_rounded),
          _buildNavItem(1, 'Keranjang', Icons.shopping_cart_outlined, Icons.shopping_cart_rounded),
          _buildNavItem(2, 'Favorit', Icons.favorite_border_rounded, Icons.favorite_rounded),
          _buildNavItem(3, 'Profil', Icons.person_outline_rounded, Icons.person_rounded),
        ];
    }
  }

  Widget _buildNavItem(int index, String label, IconData unselectedIcon, IconData selectedIcon) {
    final isSelected = currentIndex == index;
    const activeColor = AgriColors.darkOliveBtn;
    const inactiveColor = AgriColors.textHint;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                gradient: isSelected ? AgriColors.badgeGreenGradient : null,
                color: isSelected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: AgriColors.primaryGreen.withOpacity(0.35), width: 1.0)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AgriColors.primaryGreen.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isSelected ? selectedIcon : unselectedIcon,
                size: 22,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
