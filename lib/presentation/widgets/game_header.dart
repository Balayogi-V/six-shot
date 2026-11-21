import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/faction_ui.dart';
import '../../core/widgets/game_icons.dart';
import '../../core/widgets/pulsing.dart';
import '../../core/widgets/sound_toggle.dart';
import '../../domain/game_state.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({super.key, required this.state, required this.onBack});

  final GameState state;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final active = state.activePlayer;
    final faction = active.faction;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onBack,
              tooltip: 'Back to setup',
              color: AppColors.ink,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                fixedSize: const Size(44, 44),
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
                side: const BorderSide(color: AppColors.ink, width: 2.5),
              ),
            ),
            const SizedBox(width: 6),
            const SoundToggle(size: 38),
            const Spacer(),
            if (state.isAiming) ...[
              const Pulsing(child: _BulletBadge()),
              const SizedBox(width: 7),
            ],
            _KillChip(state: state),
          ],
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.62,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 31,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: faction.color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      "${faction.shortLabel}'S TURN  •  ROUND ${state.round}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppText.body,
                        fontSize: 8.2,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: faction.ring,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BulletBadge extends StatelessWidget {
  const _BulletBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Bullet ready, choose a target',
      excludeSemantics: true,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFCEFC0),
          border: Border.all(color: AppColors.ink, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.ink,
              offset: Offset(0, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Center(child: BulletIcon(size: 22)),
      ),
    );
  }
}

class _KillChip extends StatelessWidget {
  const _KillChip({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final active = state.activePlayer;
    final faction = active.faction;
    return Semantics(
      label: '${faction.label} has ${active.kills} kills',
      excludeSemantics: true,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.ink, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.ink,
              offset: Offset(0, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TargetGlyph(size: 26, color: faction.ring),
            const SizedBox(width: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Text(
                '${active.kills}',
                key: ValueKey(active.kills),
                style: const TextStyle(
                  fontFamily: AppText.display,
                  fontSize: 17,
                  height: 1,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
