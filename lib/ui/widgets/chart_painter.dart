import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TransactionSplineChart extends StatelessWidget {
  final List<double> dataPoints;
  final double height;

  const TransactionSplineChart({
    super.key,
    this.dataPoints = const [30, 65, 45, 80, 55, 95],
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: _SplineChartPainter(dataPoints),
      ),
    );
  }
}

class _SplineChartPainter extends CustomPainter {
  final List<double> points;

  _SplineChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final w = size.width;
    final h = size.height;
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final minVal = points.reduce((a, b) => a < b ? a : b) * 0.7;

    final stepX = w / (points.length - 1);

    final List<Offset> coords = [];
    for (int i = 0; i < points.length; i++) {
      final normalizedY = (points[i] - minVal) / (maxVal - minVal);
      final y = h - (normalizedY * (h * 0.75)) - (h * 0.1);
      coords.add(Offset(i * stepX, y));
    }

    final path = Path();
    path.moveTo(coords[0].dx, coords[0].dy);

    for (int i = 0; i < coords.length - 1; i++) {
      final p0 = coords[i];
      final p1 = coords[i + 1];
      final ctrl1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final ctrl2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, p1.dx, p1.dy);
    }

    // Draw filled area with gradient
    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AgriColors.primaryGreen.withOpacity(0.35),
          AgriColors.primaryGreen.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, gradientPaint);

    // Draw smooth line
    final linePaint = Paint()
      ..color = AgriColors.primaryGreen
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SplineChartPainter oldDelegate) => true;
}
