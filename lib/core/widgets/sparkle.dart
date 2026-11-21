import 'package:flutter/material.dart';

class Sparkle extends StatelessWidget {
  const Sparkle({
    super.key,
    this.size = 18,
    this.color = const Color(0xFFFFE7A8),
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SparklePainter(color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final inner = r * 0.24;
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(
        center.dx + inner,
        center.dy - inner,
        center.dx + r,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + inner,
        center.dy + inner,
        center.dx,
        center.dy + r,
      )
      ..quadraticBezierTo(
        center.dx - inner,
        center.dy + inner,
        center.dx - r,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - inner,
        center.dy - inner,
        center.dx,
        center.dy - r,
      )
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => oldDelegate.color != color;
}
