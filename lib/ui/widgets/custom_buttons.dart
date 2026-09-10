import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum AgriButtonType {
  primaryLime,
  darkOlive,
  primary,
  outline,
  danger,
}

class CustomPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final IconData? icon;

  const CustomPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 48,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AgriPillButton(
      text: text,
      onPressed: onPressed,
      type: AgriButtonType.darkOlive,
      isLoading: isLoading,
      width: width,
      height: height,
      icon: icon,
    );
  }
}

class AgriPillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AgriButtonType type;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isLoading;

  const AgriPillButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AgriButtonType.darkOlive,
    this.width = double.infinity,
    this.height = 48,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color? bg;
    Gradient? gradient;
    List<BoxShadow>? shadow;
    Color textColor;
    Border? border;

    switch (type) {
      case AgriButtonType.primaryLime:
        gradient = AgriColors.primaryGradient;
        shadow = AgriColors.buttonShadowPrimary;
        textColor = Colors.white;
        border = null;
        break;
      case AgriButtonType.darkOlive:
      case AgriButtonType.primary:
        gradient = AgriColors.darkOliveGradient;
        shadow = AgriColors.buttonShadowDark;
        textColor = Colors.white;
        border = null;
        break;
      case AgriButtonType.outline:
        bg = Colors.transparent;
        shadow = null;
        textColor = AgriColors.darkOliveBtn;
        border = Border.all(color: AgriColors.darkOliveBtn, width: 1.5);
        break;
      case AgriButtonType.danger:
        gradient = AgriColors.dangerGradient;
        shadow = const [
          BoxShadow(
            color: Color(0x38E53935),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ];
        textColor = Colors.white;
        border = null;
        break;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bg,
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: border,
        boxShadow: shadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: textColor, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: textColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

