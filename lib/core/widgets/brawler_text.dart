import 'package:flutter/material.dart';

import '../app_colors.dart';

class BrawlerText extends StatelessWidget {
  const BrawlerText(
    this.text, {
    super.key,
    required this.fontSize,
    required this.color,
    this.strokeColor = AppColors.ink,
    this.strokeWidth = 6,
    this.shadowOffset = 5,
    this.letterSpacing = 0,
    this.maxLines = 1,
  });

  final String text;
  final double fontSize;
  final Color color;
  final Color strokeColor;
  final double strokeWidth;
  final double shadowOffset;
  final double letterSpacing;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: AppText.display,
      fontSize: fontSize,
      height: 1,
      letterSpacing: letterSpacing,
      color: color,
    );

    return ExcludeSemantics(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (shadowOffset > 0)
            Transform.translate(
              offset: Offset(0, shadowOffset),
              child: Text(
                text,
                maxLines: maxLines,
                textAlign: TextAlign.center,
                style: base.copyWith(color: strokeColor),
              ),
            ),
          Text(
            text,
            maxLines: maxLines,
            textAlign: TextAlign.center,
            style: base.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..strokeJoin = StrokeJoin.round
                ..color = strokeColor,
            ),
          ),
          Text(
            text,
            maxLines: maxLines,
            textAlign: TextAlign.center,
            style: base,
          ),
        ],
      ),
    );
  }
}
