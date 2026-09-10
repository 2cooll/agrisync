import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/chart_painter.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/screens/admin/disputes_screen.dart';

class TransactionOverviewScreen extends StatelessWidget {
  const TransactionOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title matching Mockup 3 Screen 4
            Text(
              'Transaction Overview',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle matching mockup
            Text(
              'Volume Transaksi Bulan Ini (kilogram)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 8),

            // Smooth Wave Spline Chart matching Mockup 3 Screen 4
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AgriColors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AgriColors.inputBorder.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const TransactionSplineChart(
                    dataPoints: [28, 55, 42, 85, 60, 98, 75, 110],
                    height: 180,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Minggu 1', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AgriColors.textMuted)),
                      Text('Minggu 2', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AgriColors.textMuted)),
                      Text('Minggu 3', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AgriColors.textMuted)),
                      Text('Minggu 4', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AgriColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Table matching Mockup 3 Screen 4
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AgriColors.inputBorder, width: 1.2),
              ),
              child: Table(
                border: TableBorder.all(color: AgriColors.inputBorder, width: 1.2),
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(1.5),
                },
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Text(
                          'Total Pendapatan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AgriColors.textMain,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Text(
                          currencyFormatter.format(348250000),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AgriColors.darkOliveBtn,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Text(
                          'Sengketa Aktif',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AgriColors.textMain,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              '${appState.activeDisputesStat}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AgriColors.rejectedRed,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const DisputesScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Mediasi >',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AgriColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            AgriPillButton(
              text: 'KELOLA SENGKETA & KELUHAN',
              type: AgriButtonType.darkOlive,
              height: 48,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DisputesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
