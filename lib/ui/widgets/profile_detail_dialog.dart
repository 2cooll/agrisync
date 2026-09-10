import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/agri_user_avatar.dart';
import 'package:agrisync/data/models/product_model.dart';
import 'package:agrisync/ui/widgets/agri_product_image.dart';

class ProfileDetailDialog {
  /// Displays a zoomed, full-screen lightbox preview of a profile picture
  static void showZoomedAvatar(
    BuildContext context, {
    required String? imageUrl,
    required String name,
    String? role,
    VoidCallback? onEdit,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Close and Edit buttons bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        onEdit();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                      label: Text(
                        'Edit Profil',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Large Enlarged Avatar
              Hero(
                tag: 'zoomed_avatar_${imageUrl ?? name}',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: AgriUserAvatar(
                    imageUrl: imageUrl,
                    name: name,
                    radius: 120,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // User Name & Role Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (role != null && role.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        role,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AgriColors.badgeGreenBg,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Displays counterparty (Buyer / Farmer) detailed profile bottom sheet
  static void showUserProfileSheet(
    BuildContext context, {
    required String name,
    required String role,
    String? avatarUrl,
    String? location,
    String? phone,
    String? email,
    bool isVerified = true,
    List<ProductModel>? products,
    VoidCallback? onChatPressed,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header with Close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Profil Pengguna',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AgriColors.textMain,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AgriColors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Avatar with Zoom Tap Hint
                GestureDetector(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    showZoomedAvatar(
                      context,
                      imageUrl: avatarUrl,
                      name: name,
                      role: role,
                    );
                  },
                  child: Stack(
                    children: [
                      AgriUserAvatar(
                        imageUrl: avatarUrl,
                        name: name,
                        radius: 46,
                        isVerified: isVerified,
                        showBadge: true,
                        border: Border.all(color: AgriColors.primaryGreen, width: 2.5),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AgriColors.darkOliveBtn,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '(Ketuk foto untuk memperbesar)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AgriColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),

                // Name & Role Badge
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AgriColors.textMain,
                  ),
                ),
                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVerified ? AgriColors.badgeGreenBg : AgriColors.lightSageBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isVerified ? AgriColors.primaryGreen : AgriColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVerified ? Icons.verified_rounded : Icons.person_outline_rounded,
                        size: 14,
                        color: isVerified ? AgriColors.verifiedGreen : AgriColors.textMain,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$role • ${isVerified ? "Terverifikasi Resmi" : "Pengguna AgriSync"}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isVerified ? AgriColors.darkOliveBtn : AgriColors.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Location & Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AgriColors.lightSageBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AgriColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      if (location != null && location.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 18, color: AgriColors.primaryGreen),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                location,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AgriColors.textMain,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (email != null && email.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 18, color: AgriColors.darkOliveBtn),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                email,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: AgriColors.textMain,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (phone != null && phone.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 18, color: AgriColors.darkOliveBtn),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                phone,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: AgriColors.textMain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Products list if available (for farmers)
                if (products != null && products.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Komoditas yang Dijual:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AgriColors.textMain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final p = products[index];
                        return Container(
                          width: 160,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AgriColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              AgriProductImage(
                                imageUrl: p.imageUrl,
                                width: 40,
                                height: 40,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      p.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AgriColors.textMain,
                                      ),
                                    ),
                                    Text(
                                      'Rp${p.pricePerKg}/kg',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AgriColors.darkOliveBtn,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      side: const BorderSide(color: AgriColors.inputBorder),
                    ),
                    child: Text(
                      'Tutup',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AgriColors.textMain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
