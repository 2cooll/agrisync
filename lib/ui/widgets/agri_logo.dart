import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AgriLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;

  const AgriLogo({
    super.key,
    this.size = 110,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stylized Sprout / Leaf Icon inside circle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AgriColors.surfaceWhite,
            border: Border.all(color: AgriColors.primaryGreen, width: 3),
            boxShadow: [
              BoxShadow(
                color: AgriColors.primaryGreen.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: CustomPaint(
              size: Size(size * 0.58, size * 0.58),
              painter: _SproutPainter(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // App Title
        Text(
          'AgriSync',
          style: GoogleFonts.merriweather(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AgriColors.textMain,
            letterSpacing: -0.5,
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 6),
          Text(
            'Connects Farmers\nand Businesses.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AgriColors.textMuted,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _SproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()
      ..color = AgriColors.primaryGreen
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = AgriColors.darkOliveBtn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Center sprout bud
    final pathBud = Path();
    pathBud.moveTo(w * 0.5, h * 0.15);
    pathBud.quadraticBezierTo(w * 0.65, h * 0.35, w * 0.5, h * 0.55);
    pathBud.quadraticBezierTo(w * 0.35, h * 0.35, w * 0.5, h * 0.15);
    canvas.drawPath(pathBud, paintFill);
    canvas.drawPath(pathBud, paintStroke);

    // Left leaf
    final pathLeft = Path();
    pathLeft.moveTo(w * 0.45, h * 0.52);
    pathLeft.cubicTo(w * 0.15, h * 0.50, w * 0.10, h * 0.85, w * 0.45, h * 0.85);
    pathLeft.cubicTo(w * 0.45, h * 0.70, w * 0.35, h * 0.60, w * 0.45, h * 0.52);
    canvas.drawPath(pathLeft, paintFill);
    canvas.drawPath(pathLeft, paintStroke);

    // Right leaf
    final pathRight = Path();
    pathRight.moveTo(w * 0.55, h * 0.52);
    pathRight.cubicTo(w * 0.85, h * 0.50, w * 0.90, h * 0.85, w * 0.55, h * 0.85);
    pathRight.cubicTo(w * 0.55, h * 0.70, w * 0.65, h * 0.60, w * 0.55, h * 0.52);
    canvas.drawPath(pathRight, paintFill);
    canvas.drawPath(pathRight, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
