import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/faction_ui.dart';
import '../../core/widgets/game_icons.dart';
import '../../domain/faction.dart';
import '../../domain/game_state.dart';
import '../../domain/player_state.dart';
import 'slot_circle.dart';

class PlayerColumn extends StatelessWidget {
  const PlayerColumn({
    super.key,
    required this.player,
    required this.playerIndex,
    required this.isActive,
    required this.isTargeting,
    required this.targetSlots,
    required this.highlightFaction,
    required this.width,
    required this.headerHeight,
    required this.slotSize,
    required this.slotGap,
    required this.onTargetSelected,
  });

  final PlayerState player;
  final int playerIndex;
  final bool isActive;
  final bool isTargeting;
  final Set<int> targetSlots;
  final Faction highlightFaction;
  final double width;
  final double headerHeight;
  final double slotSize;
  final double slotGap;
  final ValueChanged<SlotRef> onTargetSelected;

  @override
  Widget build(BuildContext context) {
    final faction = player.faction;
    final isOut = player.isOut;

    final arrowSize = math.min(width * 0.46, 30.0);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: headerHeight,
          child: Center(
            child: Opacity(
              opacity: isOut ? 0.14 : (isActive ? 1 : 0.28),
              child: isActive && !isOut
                  ? _BouncingArrow(color: faction.color, size: arrowSize)
                  : PlayerArrow(color: faction.color, size: arrowSize),
            ),
          ),
        ),
        const SizedBox(height: 4),
        for (var i = 0; i < player.slots.length; i++) ...[
          SlotCircle(
            faction: faction,
            playerIndex: playerIndex,
            slotIndex: i,
            slot: player.slots[i],
            size: slotSize,
            highlightFaction: highlightFaction,
            isTargeting: isTargeting && targetSlots.contains(i),
            onTap: () => onTargetSelected(SlotRef(playerIndex, i)),
          ),
          if (i != player.slots.length - 1) SizedBox(height: slotGap),
        ],
      ],
    );

    final column = Opacity(
      opacity: isOut ? 0.48 : 1,
      child: content,
    );

    return Semantics(
      container: true,
      label:
          'Player ${playerIndex + 1} ${faction.label}, '
          '${player.kills} kills${isOut ? ', eliminated' : ''}',
      child: SizedBox(
        width: width,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            column,
            if (isOut)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: AppColors.red, width: 3),
                        ),
                        child: const Text(
                          'OUT',
                          style: TextStyle(
                            fontFamily: AppText.display,
                            fontSize: 14,
                            height: 1,
                            letterSpacing: 1,
                            color: AppColors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BouncingArrow extends StatefulWidget {
  const _BouncingArrow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  State<_BouncingArrow> createState() => _BouncingArrowState();
}

class _BouncingArrowState extends State<_BouncingArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..repeat(reverse: true);
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
      builder: (context, child) {
        final jump = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, jump * 3.5),
          child: child,
        );
      },
      child: PlayerArrow(color: widget.color, size: widget.size),
    );
  }
}
