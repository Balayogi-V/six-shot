import 'package:flutter/material.dart';

import '../app_colors.dart';
import 'brawler_text.dart';

class BrawlerButton extends StatefulWidget {
  const BrawlerButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.icon,
    this.height = 70,
    this.fontSize = 29,
    this.semanticLabel,
    this.textColor = AppColors.white,
    this.textStrokeColor = AppColors.ink,
    this.textShadowOffset = 3,
    this.showGloss = true,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double height;
  final double fontSize;
  final String? semanticLabel;
  final Color textColor;
  final Color textStrokeColor;
  final double textShadowOffset;
  final bool showGloss;

  @override
  State<BrawlerButton> createState() => _BrawlerButtonState();
}

class _BrawlerButtonState extends State<BrawlerButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel ?? widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => _setPressed(true) : null,
        onTapCancel: _enabled ? () => _setPressed(false) : null,
        onTapUp: _enabled ? (_) => _setPressed(false) : null,
        onTap: widget.onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: _enabled ? 1 : 0.62,
          child: Transform.translate(
            offset: Offset(0, _pressed ? 4 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              height: widget.height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.ink, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(0, _pressed ? 2 : 7),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.showGloss)
                      Positioned(
                        left: 22,
                        top: 8,
                        child: Container(
                          width: 74,
                          height: 9,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                widget.icon!,
                                const SizedBox(width: 12),
                              ],
                              BrawlerText(
                                widget.label,
                                fontSize: widget.fontSize,
                                color: widget.textColor,
                                strokeColor: widget.textStrokeColor,
                                strokeWidth: 5.5,
                                shadowOffset: widget.textShadowOffset,
                                letterSpacing: 0.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
