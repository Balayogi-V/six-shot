import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/faction_ui.dart';
import '../../core/widgets/game_icons.dart';
import '../../domain/game_state.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final active = state.activePlayer;
    final aiming = state.isAiming;
    final message = state.message ?? '';

    return Container(
      constraints: const BoxConstraints(minHeight: 47),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: aiming
            ? active.faction.soft.withValues(alpha: 0.82)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.ink, width: 2.4),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.14),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: aiming ? const Color(0xFFFCEFC0) : active.faction.soft,
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            child: Center(
              child: aiming
                  ? const BulletIcon(size: 18)
                  : const DiceGlyph(size: 20),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: Text(
                message,
                key: ValueKey(message),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppText.body,
                  fontSize: 11.4,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
