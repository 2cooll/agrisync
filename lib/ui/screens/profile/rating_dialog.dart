import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/order_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/widgets/custom_text_fields.dart';

class RatingDialog extends StatefulWidget {
  final OrderModel order;

  const RatingDialog({
    super.key,
    required this.order,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _selectedRating = 5.0;
  final _reviewController = TextEditingController(text: 'Hasil panen sangat segar dan sesuai standar Grade A!');
  bool _isLoading = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _isLoading = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final orderId = widget.order.id;
    final rating = _selectedRating;
    final review = _reviewController.text.trim();

    Future.delayed(const Duration(milliseconds: 500), () {
      appState.submitOrderReview(
        orderId,
        rating,
        review,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Terima kasih! Ulasan Anda berhasil disimpan.'),
            backgroundColor: AgriColors.primaryGreen,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AgriColors.surfaceWhite,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Beri Ulasan & Rating',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.order.productTitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AgriColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Star Rating Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1.0;
                return IconButton(
                  icon: Icon(
                    starValue <= _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AgriColors.starGold,
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() => _selectedRating = starValue);
                  },
                );
              }),
            ),
            const SizedBox(height: 12),

            // Review Input Field
            AgriTextField(
              controller: _reviewController,
              hintText: 'Tuliskan ulasan kualitas produk...',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            AgriPillButton(
              text: 'KIRIM ULASAN',
              type: AgriButtonType.darkOlive,
              isLoading: _isLoading,
              height: 44,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
