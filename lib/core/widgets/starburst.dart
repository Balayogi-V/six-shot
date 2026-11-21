import 'dart:math' as math;

import 'package:flutter/material.dart';

class Starburst extends StatelessWidget {
  const Starburst({
    super.key,
    required this.colors,
    this.opacity = 0.18,
    this.rotation = 0,
    this.child,
  });

  final List<Color> colors;
  final double opacity;
  final double rotation;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarburstPainter(
        colors: colors,
        opacity: opacity,
        rotation: rotation,
      ),
      child: child,
    );
  }
}

class _StarburstPainter extends CustomPainter {
  _StarburstPainter({
    required this.colors,
    required this.opacity,
    required this.rotation,
  });

  final List<Color> colors;
  final double opacity;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        math.sqrt(size.width * size.width + size.height * size.height) / 2;
    const rays = 20;
    const step = math.pi * 2 / rays;
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < rays; i++) {
      if (i.isOdd) continue;
      paint.color = colors[(i ~/ 2) % colors.length].withValues(alpha: opacity);
      final start = rotation + i * step;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(start) * radius,
          center.dy + math.sin(start) * radius,
        )
        ..lineTo(
          center.dx + math.cos(start + step) * radius,
          center.dy + math.sin(start + step) * radius,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StarburstPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.opacity != opacity ||
        oldDelegate.colors != colors;
  }
}
