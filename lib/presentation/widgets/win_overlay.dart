import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/faction_ui.dart';
import '../../core/widgets/brawler_button.dart';
import '../../core/widgets/brawler_text.dart';
import '../../core/widgets/starburst.dart';
import '../../domain/faction.dart';
import '../../domain/game_state.dart';
import '../../domain/soldier_stage.dart';

class WinOverlay extends StatefulWidget {
  const WinOverlay({
    super.key,
    required this.state,
    required this.onPlayAgain,
    required this.onHome,
  });

  final GameState state;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winner = widget.state.winner ?? widget.state.activePlayer.faction;

    return Stack(
      children: [
        ColoredBox(color: AppColors.ink.withValues(alpha: 0.72)),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _confetti,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ConfettiPainter(progress: _confetti.value),
                );
              },
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 372),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.84, end: 1),
                  duration: const Duration(milliseconds: 460),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: ((value - 0.84) / 0.16).clamp(0, 1),
                      child: Transform.scale(scale: value, child: child),
                    );
                  },
                  child: _WinnerCard(
                    state: widget.state,
                    winner: winner,
                    onPlayAgain: widget.onPlayAgain,
                    onHome: widget.onHome,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WinnerCard extends StatelessWidget {
  const _WinnerCard({
    required this.state,
    required this.winner,
    required this.onPlayAgain,
    required this.onHome,
  });

  final GameState state;
  final Faction winner;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.ink, width: 4),
        boxShadow: const [
          BoxShadow(color: AppColors.ink, offset: Offset(0, 8), blurRadius: 0),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 126,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Starburst(
                    colors: Faction.values
                        .map((faction) => faction.color)
                        .toList(),
                    opacity: 0.22,
                    rotation: -0.2,
                  ),
                ),
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: winner.soft,
                    border: Border.all(color: AppColors.ink, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: winner.ring.withValues(alpha: 0.40),
                        offset: const Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: winner.ring, width: 3),
                      ),
                      child: ClipOval(
                        child: Transform.scale(
                          scale: 1.16,
                          child: Image.asset(
                            SoldierStage.strike.assetPath(winner),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Semantics(
            header: true,
            label: '${winner.label} wins!',
            excludeSemantics: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: BrawlerText(
                '${winner.shortLabel} WINS!',
                fontSize: 42,
                color: winner.color,
                strokeWidth: 8,
                shadowOffset: 6,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'LAST SQUAD STANDING',
            style: TextStyle(
              fontFamily: AppText.body,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final player in state.players)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: player.faction.soft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: player.faction.ring, width: 1.6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: player.faction.color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${player.faction.shortLabel} ${player.kills} KILLS',
                        style: const TextStyle(
                          fontFamily: AppText.body,
                          fontSize: 8.4,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: BrawlerButton(
                  label: 'PLAY AGAIN',
                  color: winner.color,
                  height: 57,
                  fontSize: 22,
                  onPressed: onPlayAgain,
                  semanticLabel: 'Play again',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: BrawlerButton(
                  label: 'HOME',
                  color: AppColors.surface,
                  height: 57,
                  fontSize: 22,
                  textColor: AppColors.ink,
                  textStrokeColor: AppColors.ink,
                  textShadowOffset: 0,
                  showGloss: false,
                  onPressed: onHome,
                  semanticLabel: 'Back to home screen',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});

  final double progress;

  static final List<Color> _colors = [
    AppColors.red,
    AppColors.green,
    AppColors.yellow,
    AppColors.blue,
    AppColors.purple,
    AppColors.orange,
    AppColors.gold,
    AppColors.white,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var i = 0; i < 64; i++) {
      final speed = 0.55 + (i % 6) * 0.11;
      final y =
          ((progress * speed + i * 0.161) % 1.0) * (size.height + 60) - 30;
      final baseX = ((i * 0.61803398875) % 1.0) * size.width;
      final x =
          baseX +
          math.sin(progress * math.pi * 2 + i * 0.9) * (10 + (i % 4) * 5);
      final angle = progress * math.pi * 2 * (1 + i % 4) + i;
      final w = 4.0 + (i % 3) * 1.6;
      final h = 8.0 + (i % 4) * 1.4;

      paint.color = _colors[i % _colors.length].withValues(alpha: 0.92);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      if (i % 5 == 0) {
        canvas.drawCircle(Offset.zero, w * 0.75, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: w, height: h),
            Radius.circular(w * 0.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
