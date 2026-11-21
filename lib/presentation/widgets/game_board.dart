import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_dimensions.dart';
import '../../domain/game_state.dart';
import 'player_column.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.state,
    required this.onTargetSelected,
  });

  final GameState state;
  final ValueChanged<SlotRef> onTargetSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final players = state.players;
        final count = players.length;
        final rowGap = count >= AppDimensions.denseBoardPlayerThreshold
            ? AppDimensions.denseBoardPlayerGap
            : AppDimensions.boardPlayerGap;
        const headerHeight = AppDimensions.boardHeaderHeight;
        final slotGap = count >= AppDimensions.denseBoardPlayerThreshold
            ? AppDimensions.denseBoardSlotGap
            : AppDimensions.boardSlotGap;

        final colWidth = ((constraints.maxWidth - rowGap * (count - 1)) / count)
            .clamp(
              AppDimensions.boardMinColumnWidth,
              AppDimensions.boardMaxColumnWidth,
            )
            .toDouble();

        final usableHeight = constraints.maxHeight >
                AppDimensions.boardHeightInset
            ? constraints.maxHeight - AppDimensions.boardHeightInset
            : AppDimensions.boardMinUsableHeight;
        final slotByHeight =
            (usableHeight -
                headerHeight -
                AppDimensions.boardHeaderSlotGap -
                slotGap * (state.players.first.slots.length - 1)) /
            state.players.first.slots.length;
        final slotSize = math.min(
          math.min(colWidth, slotByHeight),
          AppDimensions.boardMaxSlotSize,
        );

        final targets = state.validTargets;

        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var p = 0; p < count; p++) ...[
                PlayerColumn(
                  player: players[p],
                  playerIndex: p,
                  isActive: p == state.activePlayerIndex,
                  isTargeting: state.isAiming,
                  targetSlots: {
                    for (final ref in targets)
                      if (ref.playerIndex == p) ref.slotIndex,
                  },
                  highlightFaction: state.activePlayer.faction,
                  width: colWidth,
                  headerHeight: headerHeight,
                  slotSize: slotSize,
                  slotGap: slotGap,
                  onTargetSelected: onTargetSelected,
                ),
                if (p != count - 1) SizedBox(width: rowGap),
              ],
            ],
          ),
        );
      },
    );
  }
}
