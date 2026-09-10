import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/payment_gateway_service.dart';
import '../../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/premium_badge.dart';
import '../../widgets/qris_payment_card.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onPaymentSuccess;

  const PaymentCheckoutScreen({
    super.key,
    required this.order,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  PaymentMethodType _selectedMethod = PaymentMethodType.qris;
  PaymentTransaction? _activeTx;
  bool _isSettling = false;

  @override
  void initState() {
    super.initState();
    final payMethod = widget.order.paymentMethod.toLowerCase();
    if (payMethod.contains('mandiri')) {
      _selectedMethod = PaymentMethodType.mandiriVa;
    } else if (payMethod.contains('bca')) {
      _selectedMethod = PaymentMethodType.bcaVa;
    } else if (payMethod.contains('bni')) {
      _selectedMethod = PaymentMethodType.bniVa;
    } else if (payMethod.contains('bri')) {
      _selectedMethod = PaymentMethodType.briVa;
    } else {
      _selectedMethod = PaymentMethodType.qris;
    }

    // Initialize transaction immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTransaction();
    });
  }

  void _initTransaction() {
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);
    final isPro = appState.currentUser.isProMember;
    final breakdown = PaymentGatewayService.calculateBreakdown(
      itemSubtotal: widget.order.totalPrice,
      shippingFee: 25000,
      isProUser: isPro,
    );

    setState(() {
      _activeTx = PaymentGatewayService.createTransactionSync(
        orderId: widget.order.id,
        amount: breakdown['total']!,
        isProUser: isPro,
        method: _selectedMethod,
      );
    });
  }

  void _switchPaymentMethod(PaymentMethodType method) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isPro = appState.currentUser.isProMember;
    final breakdown = PaymentGatewayService.calculateBreakdown(
      itemSubtotal: widget.order.totalPrice,
      shippingFee: 25000,
      isProUser: isPro,
    );

    setState(() {
      _selectedMethod = method;
      _activeTx = PaymentGatewayService.createTransactionSync(
        orderId: widget.order.id,
        amount: breakdown['total']!,
        isProUser: isPro,
        method: method,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final isFarmer = user.role == UserRole.petani;
    final isPro = user.isProMember;

    // Status Pembayaran: Terbayar jika activeTx sudah settlement atau status order sudah selesai
    final isPaid = _activeTx?.status == PaymentStatus.settlement ||
        widget.order.status == OrderStatus.selesai;

    final breakdown = PaymentGatewayService.calculateBreakdown(
      itemSubtotal: widget.order.totalPrice,
      shippingFee: 25000,
      isProUser: isPro,
    );

    // Fallback activeTx to guarantee instant rendering of QR / VA without blank screen
    final currentTx = _activeTx ??
        PaymentGatewayService.createTransactionSync(
          orderId: widget.order.id,
          amount: breakdown['total']!,
          isProUser: isPro,
          method: _selectedMethod,
        );

    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        title: Text(
          isFarmer ? 'Rincian Pembayaran Escrow' : 'Rincian & Pembayaran QRIS / VA',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AgriColors.textMain,
        elevation: 0.5,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: PremiumBadge(label: 'Escrow Protected', isPro: false),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AgriColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ringkasan Pesanan',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AgriColors.textMain,
                        ),
                      ),
                      Text(
                        widget.order.orderNumber,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AgriColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AgriColors.cardBorder),
                  _buildSummaryRow('Produk', widget.order.productTitle),
                  _buildSummaryRow('Jumlah', '${widget.order.quantityKg} kg'),
                  _buildSummaryRow(
                    isFarmer ? 'Pembeli' : 'Petani Penjual',
                    isFarmer ? widget.order.businessName : widget.order.farmerName,
                  ),
                  _buildSummaryRow('Subtotal Hasil Tani', currencyFormatter.format(breakdown['subtotal'])),
                  _buildSummaryRow('Estimasi Biaya Logistik', currencyFormatter.format(breakdown['shippingFee'])),
                  _buildSummaryRow(
                    isPro ? 'Komisi AgriSync PRO (1.0%)' : 'Biaya Layanan AgriSync (2.5%)',
                    currencyFormatter.format(breakdown['platformFee']),
                    isHighlight: true,
                  ),
                  const Divider(height: 20, color: AgriColors.cardBorder),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Total Tagihan Escrow',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AgriColors.textMain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          currencyFormatter.format(breakdown['total']),
                          textAlign: TextAlign.right,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AgriColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // KASUS 1: SUDAH TERBAYAR (LUNAS DI ESCROW)
            // ==========================================
            if (isPaid) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AgriColors.badgeGreenBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AgriColors.primaryGreen, width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.verified_rounded, color: AgriColors.verifiedGreen, size: 54),
                    const SizedBox(height: 12),
                    Text(
                      'STATUS: SUDAH TERBAYAR & LUNAS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AgriColors.darkOliveBtn,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dana Aman Tersimpan di Rekening Bersama (Escrow) AgriSync',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AgriColors.textMain,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Metode Pembayaran', widget.order.paymentMethod),
                    _buildSummaryRow('ID Transaksi', currentTx.transactionId),
                    _buildSummaryRow('ID Escrow', 'ESC-${widget.order.orderNumber}'),
                    _buildSummaryRow(
                      'Waktu Verifikasi',
                      DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
                    ),
                    _buildSummaryRow('Jumlah Terbayar', currencyFormatter.format(breakdown['total'])),
                    const SizedBox(height: 12),
                    Text(
                      isFarmer
                          ? 'Dana telah disetor oleh pembeli (${widget.order.businessName}). Saldo akan otomatis dicairkan ke rekening Anda setelah pesanan dikonfirmasi selesai.'
                          : 'Pembayaran Anda telah diverifikasi otomatis. Dana Anda diamankan di Escrow hingga Anda mengonfirmasi penerimaan komoditas dalam kondisi baik.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AgriColors.textMuted,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomPrimaryButton(
                text: 'Kembali ke Status Pesanan',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]
            // ==========================================
            // KASUS 2: BELUM TERBAYAR - UNTUK PETANI
            // ==========================================
            else if (isFarmer) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.hourglass_top_rounded, color: Color(0xFFF57C00), size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'MENUNGGU PEMBAYARAN PEMBELI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pembeli (${widget.order.businessName}) belum menyelesaikan pembayaran pesanan sebesar ${currencyFormatter.format(breakdown['total'])}.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AgriColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Catatan: Harap jangan melakukan pengiriman barang sebelum status pesanan berubah menjadi Terbayar / Diproses.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AgriColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomPrimaryButton(
                text: 'Kembali ke Status Pesanan',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]
            // ==========================================
            // KASUS 3: UNTUK PEBISNIS / SANDBOX GATEWAY (QRIS / VA)
            // ==========================================
            else ...[
              // 1. Selector Tab Saluran Pembayaran
              Text(
                'Pilih Saluran Pembayaran (Gateway Sandbox)',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  color: AgriColors.textMain,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMethodTab(
                      type: PaymentMethodType.qris,
                      label: 'QRIS (Semua e-Wallet & Bank)',
                      icon: Icons.qr_code_2_rounded,
                      badge: 'INSTANT',
                    ),
                    const SizedBox(width: 8),
                    _buildMethodTab(
                      type: PaymentMethodType.bcaVa,
                      label: 'BCA Virtual Account',
                      icon: Icons.account_balance_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildMethodTab(
                      type: PaymentMethodType.mandiriVa,
                      label: 'Mandiri VA',
                      icon: Icons.account_balance_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildMethodTab(
                      type: PaymentMethodType.bniVa,
                      label: 'BNI VA',
                      icon: Icons.account_balance_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildMethodTab(
                      type: PaymentMethodType.briVa,
                      label: 'BRI VA',
                      icon: Icons.account_balance_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 2. Active Channel Display: QRIS or Virtual Account
              if (_selectedMethod == PaymentMethodType.qris) ...[
                // Display High-Fidelity National QRIS Card
                QRISPaymentCard(
                  qrString: currentTx.qrString ??
                      '00020101021226580016ID.CO.AGRISYNC.WWW01189360091100223344550215${currentTx.transactionId}',
                  transactionId: currentTx.transactionId,
                  amount: currentTx.grossAmount,
                  merchantName: 'AGRISYNC OFFICIAL ESCROW',
                  nmid: 'ID1020268899120',
                ),
              ] else ...[
                // Display Virtual Account Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AgriColors.primaryDark, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getMethodTitle(_selectedMethod),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AgriColors.textMain,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AgriColors.badgeGreenBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'AUTOMATIC VERIFIED',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AgriColors.darkOliveBtn,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nomor Virtual Account',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AgriColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentTx.vaNumber ?? '8801209938128392',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: AgriColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: currentTx.vaNumber ?? '8801209938128392'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Nomor Virtual Account disalin ke clipboard!'),
                                    backgroundColor: AgriColors.primaryGreen,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AgriColors.darkOliveBtn,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.copy_rounded, color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'SALIN',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
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
                      ),
                      const SizedBox(height: 14),
                      _buildSummaryRow('Nama Akun', 'AGRISYNC ESCROW - ${widget.order.businessName}'),
                      _buildSummaryRow('Total Tagihan', currencyFormatter.format(currentTx.grossAmount)),
                      _buildSummaryRow('Batas Waktu Pembayaran', '24 Jam'),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // 3. Sandbox Gateway Simulation Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.science_rounded, color: AgriColors.darkOliveBtn, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Payment Gateway Sandbox Simulator',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AgriColors.darkOliveBtn,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tekan tombol di bawah untuk simulasi penyelesaian pembayaran real-time menggunakan Webhook Sandbox.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AgriColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomPrimaryButton(
                      text: '⚡ Simulasikan Pembayaran Lunas (Sandbox)',
                      isLoading: _isSettling,
                      onPressed: () => _simulatePaymentSettlement(currentTx),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTab({
    required PaymentMethodType type,
    required String label,
    required IconData icon,
    String? badge,
  }) {
    final isSelected = _selectedMethod == type;
    return GestureDetector(
      onTap: () => _switchPaymentMethod(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AgriColors.darkOliveBtn : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AgriColors.darkOliveBtn : AgriColors.cardBorder,
            width: isSelected ? 1.5 : 1.0,
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
              color: isSelected ? Colors.white : AgriColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AgriColors.textMain,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.25) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMethodTitle(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.bcaVa:
        return 'BCA Virtual Account';
      case PaymentMethodType.mandiriVa:
        return 'Mandiri Virtual Account';
      case PaymentMethodType.bniVa:
        return 'BNI Virtual Account';
      case PaymentMethodType.briVa:
        return 'BRI Virtual Account';
      default:
        return 'Virtual Account';
    }
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isHighlight ? AgriColors.primaryDark : AgriColors.textSecondary,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isHighlight ? AgriColors.primaryDark : AgriColors.textMain,
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _simulatePaymentSettlement(PaymentTransaction tx) async {
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() => _isSettling = true);
    final settledTx = await PaymentGatewayService.simulateSettlement(tx);
    appState.updateOrderStatus(widget.order.id, OrderStatus.diproses);
    if (!mounted) return;
    setState(() {
      _activeTx = settledTx;
      _isSettling = false;
    });

    if (mounted) {
      widget.onPaymentSuccess();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: AgriColors.accentGreen, size: 64),
              const SizedBox(height: 16),
              Text(
                'Pembayaran Sukses!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AgriColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dana telah diamankan di Rekening Bersama (Escrow) AgriSync. Petani mitra akan segera memproses pengiriman komoditas Anda.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AgriColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Tutup & Lihat Status Escrow',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: AgriColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
