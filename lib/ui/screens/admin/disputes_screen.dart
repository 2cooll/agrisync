import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';

class DisputesScreen extends StatelessWidget {
  const DisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final disputes = appState.disputes;

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      title: 'Manajemen Sengketa',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan Sengketa Aktif',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AgriColors.textMain,
            ),
          ),
          const SizedBox(height: 14),

          Expanded(
            child: ListView.builder(
              itemCount: disputes.length,
              itemBuilder: (context, index) {
                final d = disputes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AgriColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: d.isResolved ? AgriColors.primaryGreen.withOpacity(0.5) : AgriColors.pendingOrange.withOpacity(0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            d.orderNumber,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AgriColors.textMain),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: d.isResolved ? AgriColors.badgeGreenBg : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              d.isResolved ? 'SELESAI' : 'BUTUH MEDIASI',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: d.isResolved ? AgriColors.darkOliveBtn : AgriColors.pendingOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pelapor: ${d.reporterName} vs ${d.reportedName}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: AgriColors.textMain),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d.issueDescription,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AgriColors.textMuted),
                      ),
                      const SizedBox(height: 10),
                      if (!d.isResolved)
                        AgriPillButton(
                          text: 'SELESAIKAN & MEDIASI SENGKETA',
                          type: AgriButtonType.darkOlive,
                          height: 36,
                          onPressed: () {
                            appState.resolveDispute(d.id, 'Telah dimediasi dengan pengembalian penyesuaian timbangan.');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sengketa berhasil diselesaikan.'),
                                backgroundColor: AgriColors.primaryGreen,
                              ),
                            );
                          },
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
