import 'dart:math' as math;

import 'package:flutter/material.dart';

class DottedTargetRing extends StatefulWidget {
  const DottedTargetRing({
    super.key,
    required this.color,
    this.strokeWidth = 3.2,
  });

  final Color color;
  final double strokeWidth;

  @override
  State<DottedTargetRing> createState() => _DottedTargetRingState();
}

class _DottedTargetRingState extends State<DottedTargetRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _DottedRingPainter(
            color: widget.color,
            strokeWidth: widget.strokeWidth,
            rotation: _controller.value * math.pi * 2,
          ),
        );
      },
    );
  }
}

class _DottedRingPainter extends CustomPainter {
  _DottedRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.rotation,
  });

  final Color color;
  final double strokeWidth;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const count = 18;
    final dash = math.pi * 2 / count * 0.54;
    final step = math.pi * 2 / count;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    for (var i = 0; i < count; i++) {
      final start = rotation + i * step;
      canvas.drawArc(rect, start, dash, false, stroke);
    }
  }

  @override
  bool shouldRepaint(_DottedRingPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.rotation != rotation;
  }
}
