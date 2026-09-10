import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AgriUserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final bool isVerified;
  final bool showBadge;
  final Color? backgroundColor;
  final Color? iconColor;
  final Border? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const AgriUserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.isVerified = false,
    this.showBadge = false,
    this.backgroundColor,
    this.iconColor,
    this.border,
    this.shadows,
    this.onTap,
  });

  bool get _hasValidImage =>
      imageUrl != null &&
      imageUrl!.trim().isNotEmpty &&
      !imageUrl!.contains('placehold.co') &&
      !imageUrl!.contains('placeholder');

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;
    ImageProvider? imageProvider;

    if (_hasValidImage) {
      final cleanUrl = imageUrl!.trim();
      if (cleanUrl.startsWith('data:image')) {
        try {
          final base64Data = cleanUrl.split(',').last;
          final bytes = base64Decode(base64Data);
          imageProvider = MemoryImage(bytes);
        } catch (_) {}
      } else if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
        imageProvider = NetworkImage(cleanUrl);
      } else if (cleanUrl.startsWith('assets/')) {
        imageProvider = AssetImage(cleanUrl);
      }
    }

    if (imageProvider != null) {
      avatarWidget = CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? AgriColors.lightSageBg,
        backgroundImage: imageProvider,
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    } else {
      // Default profile avatar icon
      avatarWidget = Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFC8E6C9),
            ],
          ),
          border: Border.all(
            color: AgriColors.primaryGreen.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.person_rounded,
            size: radius * 1.15,
            color: iconColor ?? AgriColors.darkOliveBtn,
          ),
        ),
      );
    }

    if (border != null || shadows != null) {
      avatarWidget = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
          boxShadow: shadows,
        ),
        child: avatarWidget,
      );
    }

    if (isVerified && showBadge) {
      avatarWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(radius > 30 ? 4 : 2.5),
              decoration: BoxDecoration(
                color: AgriColors.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: radius > 30 ? 14 : 10,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}
