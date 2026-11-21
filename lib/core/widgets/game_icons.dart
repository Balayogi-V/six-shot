import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_colors.dart';

class DiceGlyph extends StatelessWidget {
  const DiceGlyph({super.key, this.size = 28, this.color = AppColors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _DicePainter(color));
  }
}

class _DicePainter extends CustomPainter {
  _DicePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide * 0.82;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(side * 0.24));

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.12);
    canvas.translate(-size.width / 2, -size.height / 2);

    final shadow = rrect.shift(Offset(0, side * 0.06));
    canvas.drawRRect(shadow, Paint()..color = AppColors.ink);
    canvas.drawRRect(rrect, Paint()..color = color);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = side * 0.08
        ..color = AppColors.ink,
    );

    final pip = Paint()..color = AppColors.ink;
    final radius = side * 0.085;
    final offsets = [
      Offset(-side * 0.22, -side * 0.22),
      Offset(side * 0.22, -side * 0.22),
      Offset(0, 0),
      Offset(-side * 0.22, side * 0.22),
      Offset(side * 0.22, side * 0.22),
    ];
    for (final offset in offsets) {
      canvas.drawCircle(rect.center + offset, radius, pip);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DicePainter oldDelegate) => oldDelegate.color != color;
}

class BulletIcon extends StatelessWidget {
  const BulletIcon({super.key, this.size = 30, this.color = AppColors.gold});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _BulletPainter(color));
  }
}

class _BulletPainter extends CustomPainter {
  _BulletPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.rotate(math.pi / 4);
    canvas.translate(-w / 2, -h / 2);

    final bodyWidth = w * 0.30;
    final left = (w - bodyWidth) / 2;
    final right = left + bodyWidth;
    final top = h * 0.13;
    final bottom = h * 0.87;
    final nose = (right - left) / 2;

    final path = Path()
      ..moveTo(left, bottom)
      ..lineTo(left, top + nose)
      ..quadraticBezierTo(left, top, left + nose, top)
      ..quadraticBezierTo(right, top, right, top + nose)
      ..lineTo(right, bottom)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.075
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.ink,
    );

    final band = Rect.fromLTRB(left, bottom - h * 0.09, right, bottom);
    canvas.drawRect(
      band,
      Paint()..color = AppColors.ink.withValues(alpha: 0.70),
    );

    final shine = Rect.fromLTWH(
      left + bodyWidth * 0.18,
      top + nose * 0.45,
      bodyWidth * 0.16,
      (bottom - top) * 0.42,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shine, Radius.circular(bodyWidth * 0.09)),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BulletPainter oldDelegate) => oldDelegate.color != color;
}

class ChevronDown extends StatelessWidget {
  const ChevronDown({super.key, required this.color, this.size = 14});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.62),
      painter: _ChevronPainter(color),
    );
  }
}

class PlayerArrow extends StatelessWidget {
  const PlayerArrow({super.key, required this.color, this.size = 28});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.84),
      painter: _PlayerArrowPainter(color),
    );
  }
}

class _PlayerArrowPainter extends CustomPainter {
  _PlayerArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.16, h * 0.06)
      ..lineTo(w * 0.84, h * 0.06)
      ..quadraticBezierTo(w * 0.96, h * 0.06, w * 0.9, h * 0.2)
      ..lineTo(w * 0.59, h * 0.86)
      ..quadraticBezierTo(w * 0.5, h * 0.98, w * 0.41, h * 0.86)
      ..lineTo(w * 0.1, h * 0.2)
      ..quadraticBezierTo(w * 0.04, h * 0.06, w * 0.16, h * 0.06)
      ..close();

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(color, Colors.white, 0.5)!,
          color,
          Color.lerp(color, Colors.black, 0.12)!,
        ],
        stops: const [0, 0.55, 1],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, fill);

    canvas.save();
    canvas.clipPath(path);
    final gloss = Path()
      ..moveTo(w * 0.2, h * 0.12)
      ..quadraticBezierTo(w * 0.5, h * 0.02, w * 0.8, h * 0.12)
      ..quadraticBezierTo(w * 0.72, h * 0.32, w * 0.5, h * 0.34)
      ..quadraticBezierTo(w * 0.28, h * 0.32, w * 0.2, h * 0.12)
      ..close();
    canvas.drawPath(
      gloss,
      Paint()..color = Colors.white.withValues(alpha: 0.38),
    );
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.09
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.ink,
    );
  }

  @override
  bool shouldRepaint(_PlayerArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

class TargetGlyph extends StatelessWidget {
  const TargetGlyph({super.key, this.size = 24, this.color = AppColors.red});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _TargetPainter(color),
    );
  }
}

class _TargetPainter extends CustomPainter {
  _TargetPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    canvas.drawCircle(center, r * 0.84, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      r * 0.84,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.14,
    );
    canvas.drawCircle(center, r * 0.55, Paint()..color = color);
    canvas.drawCircle(
      center,
      r * 0.55,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.1,
    );
    canvas.drawCircle(center, r * 0.26, Paint()..color = Colors.white);
    canvas.drawCircle(center, r * 0.12, Paint()..color = AppColors.red);

    final tick = Paint()
      ..color = AppColors.ink
      ..strokeWidth = r * 0.1
      ..strokeCap = StrokeCap.round;
    for (final direction in const [
      Offset(0, -1),
      Offset(0, 1),
      Offset(-1, 0),
      Offset(1, 0),
    ]) {
      canvas.drawLine(
        center + direction * r * 0.68,
        center + direction * r * 0.95,
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(_TargetPainter oldDelegate) => oldDelegate.color != color;
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.08)
      ..lineTo(size.width * 0.5, size.height * 0.82)
      ..lineTo(size.width * 0.92, size.height * 0.08);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.ink,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.09
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.color != color;
}
