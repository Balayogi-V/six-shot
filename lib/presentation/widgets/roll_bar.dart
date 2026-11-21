import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/faction_ui.dart';
import '../../core/widgets/brawler_button.dart';
import '../../core/widgets/game_icons.dart';
import '../../domain/game_state.dart';

class RollBar extends StatelessWidget {
  const RollBar({super.key, required this.state, required this.onRoll});

  final GameState state;
  final VoidCallback onRoll;

  @override
  Widget build(BuildContext context) {
    final active = state.activePlayer;
    final aiming = state.isAiming;
    final over = state.phase == GamePhase.gameOver;

    final label = switch (state.phase) {
      GamePhase.awaitingRoll => 'ROLL DICE',
      GamePhase.rolling => 'ROLLING...',
      GamePhase.targeting => 'PICK A TARGET',
      GamePhase.gameOver => 'BATTLE OVER',
    };

    final hint = switch (state.phase) {
      GamePhase.awaitingRoll => 'Roll to deploy or evolve your soldier',
      GamePhase.rolling => 'The dice decides your fate',
      GamePhase.targeting => 'Tap a dotted enemy soldier to eliminate it',
      GamePhase.gameOver => 'Last squad standing wins',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrawlerButton(
          label: label,
          color: over ? AppColors.inkSoft : active.faction.color,
          height: 68,
          fontSize: 28,
          icon: aiming ? const BulletIcon(size: 24) : const DiceGlyph(size: 26),
          onPressed: state.canRoll ? onRoll : null,
          semanticLabel: aiming
              ? 'Bullet ready. Tap a dotted enemy to fire.'
              : label,
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: 14,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              hint,
              style: const TextStyle(
                fontFamily: AppText.body,
                fontSize: 10.6,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AppColors.inkSoft,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
