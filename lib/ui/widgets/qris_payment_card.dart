import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class QRISPaymentCard extends StatelessWidget {
  final String qrString;
  final String transactionId;
  final double amount;
  final String merchantName;
  final String nmid;
  final VoidCallback? onSimulateSuccess;
  final bool isSettling;

  const QRISPaymentCard({
    super.key,
    required this.qrString,
    required this.transactionId,
    required this.amount,
    this.merchantName = 'AGRISYNC OFFICIAL ESCROW',
    this.nmid = 'ID1020268899120',
    this.onSimulateSuccess,
    this.isSettling = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. QRIS Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFD32F2F), // Official QRIS Red
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'QRIS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFD32F2F),
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STANDAR PEMBAYARAN NASIONAL',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Quick Response Code Indonesian Standard',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8.5,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ASPI / BI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Merchant Info
                Text(
                  merchantName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AgriColors.textMain,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  'NMID: $nmid • Acquirer: AGRISYNC NUSANTARA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AgriColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),

                // 2. High-Fidelity Visual QR Code Graphic
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(180, 180),
                        painter: QRISMatrixPainter(data: qrString),
                      ),
                      // Center QRIS / AgriSync mini badge
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD32F2F), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.eco_rounded,
                            color: AgriColors.primaryGreen,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 3. Total Tagihan Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AgriColors.lightSageBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Nominal Tagihan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AgriColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            currencyFormatter.format(amount),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AgriColors.darkOliveBtn,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFB300)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFE65100)),
                            const SizedBox(width: 4),
                            Text(
                              '15:00 Menit',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE65100),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 4. KODE STRING QRIS (Raw Payload Text Box) with COPY button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.qr_code_2_rounded, size: 16, color: AgriColors.darkOliveBtn),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Kode String QRIS:',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: AgriColors.textMain,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: qrString));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kode QRIS berhasil disalin ke papan klip!'),
                                  backgroundColor: AgriColors.primaryGreen,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AgriColors.darkOliveBtn,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.copy_rounded, color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    'SALIN KODE',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SelectableText(
                          qrString,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: const Color(0xFF374151),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 5. Supported E-Wallets & Mobile Banking Logos / Badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dapat dibayar melalui semua E-Wallet & M-Banking:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AgriColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildAppBadge('GoPay', const Color(0xFF00AED6)),
                        _buildAppBadge('OVO', const Color(0xFF4C3494)),
                        _buildAppBadge('DANA', const Color(0xFF118EEA)),
                        _buildAppBadge('ShopeePay', const Color(0xFFEE4D2D)),
                        _buildAppBadge('BCA Mobile', const Color(0xFF003D79)),
                        _buildAppBadge('Livin\' Mandiri', const Color(0xFF00569B)),
                        _buildAppBadge('BRImo', const Color(0xFF00529C)),
                        _buildAppBadge('BNI Mobile', const Color(0xFFE55300)),
                        _buildAppBadge('LinkAja', const Color(0xFFE2231A)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 6. Step-by-Step Payment Instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.help_outline_rounded, size: 15, color: AgriColors.darkOliveBtn),
                          const SizedBox(width: 6),
                          Text(
                            'Cara Pembayaran QRIS:',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AgriColors.textMain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildStepItem('1', 'Buka aplikasi e-Wallet atau Mobile Banking pilihan Anda.'),
                      _buildStepItem('2', 'Pilih menu Scan QRIS atau tempel Kode String QRIS di atas.'),
                      _buildStepItem('3', 'Arahkan kamera ke gambar QR Code di atas.'),
                      _buildStepItem('4', 'Pastikan nama merchant adalah "$merchantName".'),
                      _buildStepItem('5', 'Konfirmasi nominal dan masukkan PIN transaksi Anda.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBadge(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        name,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStepItem(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 1, right: 6),
            decoration: const BoxDecoration(
              color: AgriColors.darkOliveBtn,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AgriColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter that deterministicly generates high-contrast QR matrix pattern with standard corner finder squares
class QRISMatrixPainter extends CustomPainter {
  final String data;

  QRISMatrixPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBlack = Paint()
      ..color = const Color(0xFF111827)
      ..style = PaintingStyle.fill;

    const gridSize = 25; // 25x25 QR Matrix
    final moduleSize = size.width / gridSize;

    // Draw background white
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Helper: Draw Finder Pattern at (row, col) 7x7 outer, 5x5 white, 3x3 black
    void drawFinderPattern(int startRow, int startCol) {
      // 7x7 black
      canvas.drawRect(
        Rect.fromLTWH(startCol * moduleSize, startRow * moduleSize, 7 * moduleSize, 7 * moduleSize),
        paintBlack,
      );
      // 5x5 white
      canvas.drawRect(
        Rect.fromLTWH((startCol + 1) * moduleSize, (startRow + 1) * moduleSize, 5 * moduleSize, 5 * moduleSize),
        bgPaint,
      );
      // 3x3 black center
      canvas.drawRect(
        Rect.fromLTWH((startCol + 2) * moduleSize, (startRow + 2) * moduleSize, 3 * moduleSize, 3 * moduleSize),
        paintBlack,
      );
    }

    // Top-Left Finder
    drawFinderPattern(0, 0);
    // Top-Right Finder
    drawFinderPattern(0, gridSize - 7);
    // Bottom-Left Finder
    drawFinderPattern(gridSize - 7, 0);

    // Alignment Pattern at bottom right (5x5, 3x3 white, 1x1 black)
    const alignRow = gridSize - 7;
    const alignCol = gridSize - 7;
    canvas.drawRect(
      Rect.fromLTWH(alignCol * moduleSize, alignRow * moduleSize, 5 * moduleSize, 5 * moduleSize),
      paintBlack,
    );
    canvas.drawRect(
      Rect.fromLTWH((alignCol + 1) * moduleSize, (alignRow + 1) * moduleSize, 3 * moduleSize, 3 * moduleSize),
      bgPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH((alignCol + 2) * moduleSize, (alignRow + 2) * moduleSize, 1 * moduleSize, 1 * moduleSize),
      paintBlack,
    );

    // Timing patterns
    for (int i = 8; i < gridSize - 8; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(Rect.fromLTWH(i * moduleSize, 6 * moduleSize, moduleSize, moduleSize), paintBlack);
        canvas.drawRect(Rect.fromLTWH(6 * moduleSize, i * moduleSize, moduleSize, moduleSize), paintBlack);
      }
    }

    // Data modules deterministic grid based on data hash
    final safeData = data.isEmpty ? '00020101021226580016ID.CO.AGRISYNC.WWW01189360091100223344550215AGRISYNC' : data;
    final bytes = safeData.codeUnits;
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        // Skip Top-Left Finder (0-7, 0-7)
        if (r <= 7 && c <= 7) continue;
        // Skip Top-Right Finder (0-7, 18-24)
        if (r <= 7 && c >= gridSize - 8) continue;
        // Skip Bottom-Left Finder (18-24, 0-7)
        if (r >= gridSize - 8 && c <= 7) continue;
        // Skip Alignment pattern
        if (r >= alignRow && r < alignRow + 5 && c >= alignCol && c < alignCol + 5) continue;
        // Skip Center logo area (9-15, 9-15)
        if (r >= 9 && r <= 15 && c >= 9 && c <= 15) continue;

        final byteIndex = (r * gridSize + c) % bytes.length;
        final byteVal = bytes[byteIndex];
        final isFilled = ((byteVal ^ (r * 7 + c * 13)) % 3) != 0;

        if (isFilled) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * moduleSize, r * moduleSize, moduleSize * 0.92, moduleSize * 0.92),
              Radius.circular(moduleSize * 0.18),
            ),
            paintBlack,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QRISMatrixPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
