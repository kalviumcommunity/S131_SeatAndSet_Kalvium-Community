import 'package:flutter/material.dart';

class AdminLogo extends StatelessWidget {
  final double size;

  const AdminLogo({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.95),
      painter: _AdminLogoPainter(),
    );
  }
}

class _AdminLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Outer stylized chevron / triangle with arched base
    path.moveTo(w * 0.5, 0); // Apex
    path.quadraticBezierTo(w * 0.55, 0, w * 0.95, h * 0.78); // Right shoulder down
    path.quadraticBezierTo(w * 1.0, h * 0.88, w * 0.90, h * 0.92); // Right base round
    path.lineTo(w * 0.68, h * 0.92); // Bottom right flat
    // Central cutout arch
    path.quadraticBezierTo(w * 0.66, h * 0.62, w * 0.5, h * 0.62); // Cutout arch top
    path.quadraticBezierTo(w * 0.34, h * 0.62, w * 0.32, h * 0.92); // Cutout arch left
    path.lineTo(w * 0.10, h * 0.92); // Bottom left flat
    path.quadraticBezierTo(0, h * 0.88, w * 0.05, h * 0.78); // Left base round
    path.quadraticBezierTo(w * 0.45, 0, w * 0.5, 0); // Back to apex
    path.close();

    // Soft drop shadow / glow
    final shadowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, shadowPaint);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
