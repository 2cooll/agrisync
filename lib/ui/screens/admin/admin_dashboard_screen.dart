import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/app_bottom_nav_bar.dart';
import 'package:agrisync/ui/screens/admin/pending_verifications_screen.dart';
import 'package:agrisync/ui/screens/admin/transaction_overview_screen.dart';
import 'package:agrisync/ui/screens/admin/disputes_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/search_results_screen.dart';
import 'package:agrisync/ui/screens/profile/user_profile_screen.dart';
import 'package:agrisync/ui/screens/chat/chat_inbox_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_navIndex == 2) {
      return const ChatInboxScreen(isRootTab: true);
    } else if (_navIndex == 3) {
      return const UserProfileScreen(isRootTab: true);
    }

    final appState = Provider.of<AppState>(context);

    return AgriCurvedScaffold(
      showBack: false,
      showNotification: true,
      headerHeight: 110,
      title: 'Admin Home',
      bottomNavigationBar: AgriBottomNavBar(
        role: UserRole.admin,
        currentIndex: _navIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PendingVerificationsScreen(),
              ),
            );
          } else {
            setState(() => _navIndex = index);
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Title matching Mockup 3 Screen 1
            Text(
              'Admin Home',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 18),

            // 2x3 Grid of Metric Cards matching Mockup 3 Screen 1
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
              children: [
                // 1. Total Petani
                _buildAdminGridCard(
                  icon: Icons.person_rounded,
                  label: 'Total Petani',
                  value: NumberFormat.decimalPattern('id_ID').format(appState.totalPetaniStat),
                  onTap: () {},
                ),

                // 2. Total Pebisnis
                _buildAdminGridCard(
                  icon: Icons.groups_rounded,
                  label: 'Total Pebisnis',
                  value: NumberFormat.decimalPattern('id_ID').format(appState.totalPebisnisStat),
                  onTap: () {},
                ),

                // 3. Pending Verifikasi (Tappable)
                _buildAdminGridCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Pending Verifikasi',
                  value: '${appState.pendingVerifikasiStat}',
                  isHighlighted: appState.pendingVerifikasiStat > 0,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PendingVerificationsScreen(),
                      ),
                    );
                  },
                ),

                // 4. Transaksi Aktif (Tappable)
                _buildAdminGridCard(
                  icon: Icons.shopping_cart_rounded,
                  label: 'Transaksi Aktif',
                  value: '${appState.activeTransactionStat}',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TransactionOverviewScreen(),
                      ),
                    );
                  },
                ),

                // 5. Kelola Sengketa (Tappable)
                _buildAdminGridCard(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Sengketa Aktif',
                  value: '${appState.activeDisputesStat}',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DisputesScreen(),
                      ),
                    );
                  },
                ),

                // 6. Katalog Produk (Tappable)
                _buildAdminGridCard(
                  icon: Icons.description_rounded,
                  label: 'Katalog Produk',
                  value: '${appState.products.length}',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SearchResultsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Shortcut: Transaction Volume Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AgriColors.sageCardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AgriColors.cardBorder.withOpacity(0.8)),
                boxShadow: AgriColors.softCardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      gradient: AgriColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AgriColors.buttonShadowPrimary,
                    ),
                    child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporan Volume & Keuangan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AgriColors.textMain,
                          ),
                        ),
                        Text(
                          'Pantau volume transaksi dan neraca rekber escrow.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AgriColors.darkOliveBtn),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TransactionOverviewScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminGridCard({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlighted = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AgriColors.sageCardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? AgriColors.primaryGreen : AgriColors.cardBorder.withOpacity(0.8),
          width: isHighlighted ? 1.8 : 1,
        ),
        boxShadow: AgriColors.softCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isHighlighted ? AgriColors.primaryGreen : AgriColors.darkOliveBtn,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AgriColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AgriColors.darkOliveBtn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
