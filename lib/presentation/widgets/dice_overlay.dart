import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/app_colors.dart';
import '../../core/faction_ui.dart';
import '../../domain/faction.dart';

class DiceOverlay extends StatefulWidget {
  const DiceOverlay({
    super.key,
    required this.face,
    required this.faction,
    required this.onClosing,
    required this.onFinished,
  });

  final int face;
  final Faction faction;
  final VoidCallback onClosing;
  final VoidCallback onFinished;

  @override
  State<DiceOverlay> createState() => _DiceOverlayState();
}

class _DiceOverlayState extends State<DiceOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  Timer? _timer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    )..forward();
    _timer = Timer(const Duration(milliseconds: 3120), _finish);
  }

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    widget.onClosing();
    _entrance.reverse().then((_) {
      if (!mounted) return;
      _timer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) widget.onFinished();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final diceSize = math.min(width * 0.76, 300.0);
    final glow = widget.faction.color;

    return Semantics(
      label: 'Rolling dice for ${widget.faction.label}',
      liveRegion: true,
      child: AbsorbPointer(
        child: ColoredBox(
          color: AppColors.ink.withValues(alpha: 0.42),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _entrance, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.88, end: 1).animate(
                CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack),
              ),
              child: Center(
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            width: width,
                            height: width,
                            child: IgnorePointer(
                              child: Lottie.asset(
                                'assets/dice/overlays/dice_overlay_${widget.faction.assetKey}.json',
                                fit: BoxFit.contain,
                                repeat: true,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: diceSize,
                            height: diceSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.06),
                              boxShadow: [
                                BoxShadow(
                                  color: glow.withValues(alpha: 0.45),
                                  blurRadius: 64,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Lottie.asset(
                              'assets/dice/dice_flip_3s_${widget.face}.json',
                              fit: BoxFit.contain,
                              repeat: false,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Container(
                                    width: diceSize * 0.58,
                                    height: diceSize * 0.58,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        diceSize * 0.12,
                                      ),
                                      border: Border.all(
                                        color: AppColors.ink,
                                        width: 5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${widget.face}',
                                        style: TextStyle(
                                          fontFamily: AppText.display,
                                          fontSize: diceSize * 0.34,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: widget.faction.color,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.ink, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.ink,
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          'ROLLING FOR ${widget.faction.shortLabel}',
                          style: TextStyle(
                            fontFamily: AppText.body,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.8,
                            color: widget.faction.onColor,
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
      ),
    );
  }
}
