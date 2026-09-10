import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/data/models/chat_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/widgets/agri_product_image.dart';
import 'package:agrisync/ui/widgets/custom_text_fields.dart';
import 'package:agrisync/ui/widgets/agri_user_avatar.dart';
import 'package:agrisync/ui/widgets/profile_detail_dialog.dart';
import 'package:agrisync/ui/screens/pebisnis/order_confirmation_screen.dart';

class ChatNegotiationScreen extends StatefulWidget {
  final String threadId;

  const ChatNegotiationScreen({
    super.key,
    required this.threadId,
  });

  @override
  State<ChatNegotiationScreen> createState() => _ChatNegotiationScreenState();
}

class _ChatNegotiationScreenState extends State<ChatNegotiationScreen> {
  final _messageController = TextEditingController();
  final _offerPriceController = TextEditingController();
  final _offerQtyController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showOfferInputs = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final appState = Provider.of<AppState>(context, listen: false);
      final thread = appState.getChatThread(widget.threadId);
      if (thread != null) {
        if (thread.activeOffer != null) {
          _offerPriceController.text = thread.activeOffer!.offeredPrice.toString();
          _offerQtyController.text = thread.activeOffer!.quantityKg.toString();
        } else {
          _offerPriceController.text = thread.productPrice.toString();
          _offerQtyController.text = '100';
        }
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _offerPriceController.dispose();
    _offerQtyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final appState = Provider.of<AppState>(context, listen: false);
    appState.sendChatMessage(widget.threadId, text);
    _messageController.clear();

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleOfferSubmit() {
    final price = int.tryParse(_offerPriceController.text.trim()) ?? 0;
    final qty = int.tryParse(_offerQtyController.text.trim()) ?? 0;
    if (price <= 0 || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan harga dan kuantitas yang valid')),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    appState.submitOffer(widget.threadId, price, qty);
    setState(() => _showOfferInputs = false);
    _scrollToBottom();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Penawaran ${currencyFormatter.format(price)}/kg ($qty kg) berhasil diajukan!'),
        backgroundColor: AgriColors.primaryGreen,
      ),
    );
  }

  void _showCounterOfferDialog(BuildContext context, NegotiationOffer currentOffer) {
    final counterPriceController = TextEditingController(text: currentOffer.offeredPrice.toString());
    final counterQtyController = TextEditingController(text: currentOffer.quantityKg.toString());
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final price = int.tryParse(counterPriceController.text.trim()) ?? 0;
            final qty = int.tryParse(counterQtyController.text.trim()) ?? 0;
            final total = price * qty;

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AgriColors.lightSageBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.sync_alt_rounded, color: AgriColors.darkOliveBtn, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Ajukan Tawar Balik',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AgriColors.textMain,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AgriColors.textMuted),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AgriColors.lightSageBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AgriColors.darkOliveBtn, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tawaran sebelumnya: ${currencyFormatter.format(currentOffer.offeredPrice)}/kg (${currentOffer.quantityKg} kg)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AgriColors.darkOliveBtn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Harga Tawar Balik (per kg)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AgriColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AgriTextField(
                    controller: counterPriceController,
                    hintText: 'Contoh: 25000',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.payments_outlined, size: 18, color: AgriColors.textMuted),
                    onChanged: (_) => setModalState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Jumlah Kuantitas (kg)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AgriColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AgriTextField(
                    controller: counterQtyController,
                    hintText: 'Contoh: 100',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.scale_outlined, size: 18, color: AgriColors.textMuted),
                    onChanged: (_) => setModalState(() {}),
                  ),
                  const SizedBox(height: 14),
                  // Total preview
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AgriColors.badgeGreenBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimasi Total:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AgriColors.darkOliveBtn,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(total),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AgriColors.darkOliveBtn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AgriPillButton(
                    text: 'KIRIM TAWARAN BALASAN',
                    type: AgriButtonType.darkOlive,
                    height: 44,
                    onPressed: () {
                      final newPrice = int.tryParse(counterPriceController.text.trim()) ?? 0;
                      final newQty = int.tryParse(counterQtyController.text.trim()) ?? 0;
                      if (newPrice <= 0 || newQty <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Harga dan kuantitas harus valid')),
                        );
                        return;
                      }

                      final appState = Provider.of<AppState>(context, listen: false);
                      appState.counterOffer(widget.threadId, newPrice, newQty);
                      Navigator.of(context).pop();
                      _scrollToBottom();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tawar balik ${currencyFormatter.format(newPrice)}/kg ($newQty kg) terkirim!'),
                          backgroundColor: AgriColors.primaryGreen,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRejectOfferDialog(BuildContext context, NegotiationOffer currentOffer) {
    String? selectedReason;
    final customReasonController = TextEditingController();
    final reasons = [
      'Harga penawaran terlalu rendah',
      'Stok barang terbatas',
      'Biaya operasional / logistik meningkat',
      'Kuantitas yang diminta belum sesuai',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AgriColors.badgeRedBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.cancel_outlined, color: AgriColors.badgeRedText, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Tolak Penawaran',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AgriColors.textMain,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AgriColors.textMuted),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pilih alasan penolakan (opsional) agar pihak lawan dapat memahami dan mengajukan penawaran baru:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: AgriColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...reasons.map((r) {
                    final isSelected = selectedReason == r;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedReason = isSelected ? null : r;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AgriColors.lightSageBg : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AgriColors.primaryGreen : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              size: 16,
                              color: isSelected ? AgriColors.primaryGreen : AgriColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                r,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: AgriColors.textMain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  AgriTextField(
                    controller: customReasonController,
                    hintText: 'Atau tuliskan alasan lainnya...',
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AgriColors.textMain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final finalReason = customReasonController.text.trim().isNotEmpty
                                ? customReasonController.text.trim()
                                : selectedReason;

                            final appState = Provider.of<AppState>(context, listen: false);
                            appState.rejectOffer(widget.threadId, reason: finalReason);
                            Navigator.of(context).pop();
                            _scrollToBottom();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Penawaran berhasil ditolak.'),
                                backgroundColor: AgriColors.badgeRedText,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgriColors.badgeRedText,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Konfirmasi Tolak',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCounterpartyProfile(BuildContext context, AppState appState, ChatThread thread) {
    final currentUserId = appState.currentUser.id;
    final otherUserId = thread.getOtherUserId(currentUserId);
    final otherUserName = thread.getOtherUserName(currentUserId);
    final otherUserRole = thread.getOtherUserRole(currentUserId);

    final otherUser = appState.findUserById(otherUserId);
    final isFarmer = otherUserRole.toLowerCase().contains('petani') || (otherUser != null && otherUser.role == UserRole.petani);
    final products = isFarmer
        ? appState.products.where((p) => p.farmerId == otherUserId || p.farmerName == otherUserName).toList()
        : null;

    ProfileDetailDialog.showUserProfileSheet(
      context,
      name: otherUser?.name ?? otherUserName,
      role: otherUser?.roleDisplay ?? otherUserRole,
      avatarUrl: otherUser?.avatarUrl ?? thread.avatarUrl,
      location: otherUser?.farmLocation ?? (thread.otherUserLocation.isNotEmpty ? thread.otherUserLocation : 'Jawa Timur, Indonesia'),
      phone: otherUser?.phone,
      email: otherUser?.email,
      isVerified: otherUser?.isVerified ?? thread.isVerified,
      products: products,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final thread = appState.getChatThread(widget.threadId);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    if (thread == null) {
      return const Scaffold(
        body: Center(child: Text('Thread tidak ditemukan')),
      );
    }

    final activeOffer = thread.activeOffer;
    final product = appState.getProductById(thread.productId);
    final currentUserId = appState.currentUser.id;
    final otherUserId = thread.getOtherUserId(currentUserId);
    final otherUserName = thread.getOtherUserName(currentUserId);
    final otherUserRole = thread.getOtherUserRole(currentUserId);
    final otherUser = appState.findUserById(otherUserId);
    final isOtherVerified = otherUser?.isVerified ?? thread.isVerified;
    final otherAvatar = otherUser?.avatarUrl ?? thread.avatarUrl;

    return AgriCurvedScaffold(
      headerHeight: 74,
      showBack: true,
      titleWidget: GestureDetector(
        onTap: () => _showCounterpartyProfile(context, appState, thread),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AgriUserAvatar(
              imageUrl: otherAvatar,
              name: otherUserName,
              radius: 19,
              isVerified: isOtherVerified,
              showBadge: true,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          otherUserName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 14),
                    ],
                  ),
                  Text(
                    '$otherUserRole • ${isOtherVerified ? "Terverifikasi" : "Online"}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AgriColors.badgeGreenBg,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Title
          Text(
            'Negotiation Chat',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AgriColors.textMain,
            ),
          ),
          const SizedBox(height: 10),

          // 1. Top Product Preview Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AgriColors.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AgriColors.inputBorder.withOpacity(0.6), width: 1.2),
            ),
            child: Row(
              children: [
                AgriProductImage(
                  imageUrl: thread.productImageUrl,
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.productTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AgriColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${currencyFormatter.format(thread.productPrice)}/kg',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AgriColors.darkOliveBtn,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _showOfferInputs = !_showOfferInputs);
                  },
                  icon: Icon(
                    _showOfferInputs ? Icons.close : Icons.tune_rounded,
                    size: 16,
                    color: AgriColors.primaryGreen,
                  ),
                  label: Text(
                    _showOfferInputs ? 'Tutup' : 'Beri Nego',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AgriColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 2. Expandable / Active Negotiation Offer Input Section
          if (_showOfferInputs) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AgriColors.lightSageBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AgriColors.cardBorder, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Form Pengajuan Penawaran Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AgriColors.darkOliveBtn,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: AgriTextField(
                          controller: _offerPriceController,
                          hintText: 'Harga (Rp/kg)',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.payments_outlined, size: 18, color: AgriColors.textMuted),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AgriTextField(
                          controller: _offerQtyController,
                          hintText: 'Jumlah (kg)',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.scale_outlined, size: 18, color: AgriColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AgriPillButton(
                    text: 'AJUKAN PENAWARAN HARGA',
                    type: AgriButtonType.darkOlive,
                    height: 42,
                    onPressed: _handleOfferSubmit,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // 3. 2-Way Active Negotiation Offer Card
          if (activeOffer != null)
            _buildTwoWayOfferCard(
              context: context,
              appState: appState,
              thread: thread,
              activeOffer: activeOffer,
              product: product,
              currencyFormatter: currencyFormatter,
            ),

          // 4. Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: thread.messages.length,
              itemBuilder: (context, index) {
                final msg = thread.messages[index];
                final isMe = msg.senderId == appState.currentUser.id ||
                    (appState.currentUser.role == UserRole.pebisnis ? msg.isFromPebisnis : !msg.isFromPebisnis);

                // Check if this message is a system-generated negotiation milestone
                final isNegotiationLog = msg.text.startsWith('📝') ||
                    msg.text.startsWith('🔄') ||
                    msg.text.startsWith('🤝') ||
                    msg.text.startsWith('❌');

                if (isNegotiationLog) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: msg.text.startsWith('🤝')
                          ? AgriColors.badgeGreenBg
                          : msg.text.startsWith('❌')
                              ? AgriColors.badgeRedBg
                              : AgriColors.lightSageBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: msg.text.startsWith('🤝')
                            ? AgriColors.primaryGreen.withOpacity(0.5)
                            : msg.text.startsWith('❌')
                                ? AgriColors.badgeRedText.withOpacity(0.3)
                                : AgriColors.cardBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            msg.text,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: msg.text.startsWith('❌') ? AgriColors.badgeRedText : AgriColors.textMain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (isMe) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72,
                      ),
                      decoration: BoxDecoration(
                        color: AgriColors.badgeGreenBg,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.zero,
                        ),
                        border: Border.all(
                          color: AgriColors.primaryGreen.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.text,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              color: AgriColors.textMain,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              DateFormat('HH:mm').format(msg.timestamp),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: AgriColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Received message from counterparty: display counterparty avatar with tap to view profile
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _showCounterpartyProfile(context, appState, thread),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 2),
                          child: AgriUserAvatar(
                            imageUrl: otherAvatar,
                            name: otherUserName,
                            radius: 15,
                            isVerified: isOtherVerified,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.68,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                              bottomLeft: Radius.zero,
                              bottomRight: Radius.circular(14),
                            ),
                            border: Border.all(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  color: AgriColors.textMain,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  DateFormat('HH:mm').format(msg.timestamp),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: AgriColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 5. Message Input Bar
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AgriColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AgriColors.inputBorder, width: 1.2),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                      decoration: const InputDecoration(
                        hintText: 'Tulis pesan...',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AgriColors.darkOliveBtn,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2-Way Interactive Negotiation Card
  Widget _buildTwoWayOfferCard({
    required BuildContext context,
    required AppState appState,
    required ChatThread thread,
    required NegotiationOffer activeOffer,
    required dynamic product,
    required NumberFormat currencyFormatter,
  }) {
    final currentUserId = appState.currentUser.id;
    final isMeSender = activeOffer.senderId == currentUserId;
    final isBuyer = appState.currentUser.role == UserRole.pebisnis;

    // STATE 1: Penawaran Telah Disepakati (ACCEPTED)
    if (activeOffer.status == NegotiationStatus.accepted) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AgriColors.badgeGreenBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AgriColors.primaryGreen, width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration_rounded, color: AgriColors.primaryGreen, size: 20),
                const SizedBox(width: 6),
                Text(
                  'KESEPAKATAN HARGA TERCAPAI!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AgriColors.darkOliveBtn,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Harga sepakat: ${currencyFormatter.format(activeOffer.offeredPrice)}/kg (${activeOffer.quantityKg} kg)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AgriColors.darkOliveBtn,
              ),
            ),
            Text(
              'Total: ${currencyFormatter.format(activeOffer.totalAmount)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 10),
            if (isBuyer)
              AgriPillButton(
                text: 'PESAN & BAYAR SEKARANG',
                type: AgriButtonType.darkOlive,
                height: 42,
                onPressed: () {
                  if (product != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderConfirmationScreen(
                          product: product,
                          agreedPrice: activeOffer.offeredPrice,
                          defaultQuantity: activeOffer.quantityKg,
                        ),
                      ),
                    );
                  }
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Menunggu pembeli (${thread.getOtherUserName(currentUserId)}) menyelesaikan proses checkout & pembayaran escrow.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AgriColors.textMuted,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // STATE 2: Penawaran Ditolak (REJECTED)
    if (activeOffer.status == NegotiationStatus.rejected) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AgriColors.badgeRedBg.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AgriColors.badgeRedText.withOpacity(0.4), width: 1.2),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AgriColors.badgeRedText, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Penawaran sebelumnya belum disepakati.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AgriColors.badgeRedText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Anda atau lawan bicara dapat mengajukan penawaran baru kapan saja untuk melanjutkan negosiasi.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            AgriPillButton(
              text: 'AJUKAN PENAWARAN BARU',
              type: AgriButtonType.darkOlive,
              height: 38,
              onPressed: () {
                setState(() => _showOfferInputs = true);
              },
            ),
          ],
        ),
      );
    }

    // STATE 3: Penawaran Masih Pending (PENDING)
    // SUB-CASE 3A: Penawaran dikirim oleh DIRI SENDIRI (Menunggu respon pihak lain)
    if (isMeSender) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AgriColors.lightSageBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AgriColors.inputBorder.withOpacity(0.6), width: 1.2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_top_rounded, color: AgriColors.darkOliveBtn, size: 18),
                const SizedBox(width: 6),
                Text(
                  'MENUNGGU RESPON ${thread.getOtherUserName(currentUserId).toUpperCase()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AgriColors.darkOliveBtn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Tawaran Anda: ${currencyFormatter.format(activeOffer.offeredPrice)}/kg (${activeOffer.quantityKg} kg) • Total: ${currencyFormatter.format(activeOffer.totalAmount)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _showOfferInputs = true);
              },
              icon: const Icon(Icons.edit_note_rounded, size: 16, color: AgriColors.darkOliveBtn),
              label: Text(
                'Ubah Tawaran Saya',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AgriColors.darkOliveBtn,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: const BorderSide(color: AgriColors.darkOliveBtn, width: 1),
              ),
            ),
          ],
        ),
      );
    }

    // SUB-CASE 3B: Penawaran DITERIMA DARI PIHAK LAIN (Current user bisa Terima / Tawar Balik / Tolak)
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AgriColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AgriColors.badgeGreenBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_offer_rounded, color: AgriColors.primaryGreen, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PENAWARAN DARI ${thread.getOtherUserName(currentUserId).toUpperCase()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AgriColors.darkOliveBtn,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AgriColors.lightSageBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harga Ditawar:',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AgriColors.textMuted),
                    ),
                    Text(
                      '${currencyFormatter.format(activeOffer.offeredPrice)}/kg',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AgriColors.darkOliveBtn,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Kuantitas (${activeOffer.quantityKg} kg):',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AgriColors.textMuted),
                    ),
                    Text(
                      currencyFormatter.format(activeOffer.totalAmount),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AgriColors.textMain,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3 Action Buttons: TERIMA, TAWAR BALIK, TOLAK
          Row(
            children: [
              // TERIMA
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () {
                    appState.acceptOffer(widget.threadId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Penawaran ${currencyFormatter.format(activeOffer.offeredPrice)}/kg disetujui!'),
                        backgroundColor: AgriColors.primaryGreen,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                  label: Text(
                    'TERIMA',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgriColors.darkOliveBtn,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // TAWAR BALIK
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _showCounterOfferDialog(context, activeOffer),
                  icon: const Icon(Icons.sync_alt_rounded, size: 16, color: AgriColors.darkOliveBtn),
                  label: Text(
                    'TAWAR BALIK',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: AgriColors.darkOliveBtn),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(color: AgriColors.darkOliveBtn, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // TOLAK
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () => _showRejectOfferDialog(context, activeOffer),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(color: AgriColors.badgeRedText, width: 1.2),
                  ),
                  child: Text(
                    'TOLAK',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: AgriColors.badgeRedText),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
