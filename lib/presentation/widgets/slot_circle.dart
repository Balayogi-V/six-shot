import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';
import '../../core/faction_ui.dart';
import '../../domain/faction.dart';
import '../../domain/slot_state.dart';
import '../../domain/soldier_stage.dart';
import 'dotted_target_ring.dart';

class SlotCircle extends StatelessWidget {
  const SlotCircle({
    super.key,
    required this.faction,
    required this.playerIndex,
    required this.slotIndex,
    required this.slot,
    required this.size,
    required this.highlightFaction,
    required this.isTargeting,
    this.onTap,
  });

  final Faction faction;
  final int playerIndex;
  final int slotIndex;
  final SlotState slot;
  final double size;
  final Faction highlightFaction;
  final bool isTargeting;
  final VoidCallback? onTap;

  bool get _canTap => isTargeting && slot.isTargetable && onTap != null;

  @override
  Widget build(BuildContext context) {
    final dead = slot.isDestroyed;
    final borderWidth = AppDimensions.slotBorderWidth(size);
    final targetStrokeWidth = AppDimensions.targetRingStrokeWidth(size);
    final targetRingInset = AppDimensions.targetRingInset(targetStrokeWidth);

    Widget circle = AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dead ? AppColors.surface : faction.soft,
        border: Border.all(
          color: dead ? AppColors.inkSoft : AppColors.ink,
          width: borderWidth,
        ),
        boxShadow: dead
            ? null
            : [
                BoxShadow(
                  color: faction.ring.withValues(alpha: 0.32),
                  offset: Offset(0, AppDimensions.slotShadowOffset(size)),
                  blurRadius: 0,
                ),
              ],
      ),
      child: ClipOval(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 650),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.65, end: 1).animate(animation),
                child: child,
              ),
            );
          },
          child: _SlotArt(
            key: ValueKey('${slot.stage}-${slot.killedBy}'),
            faction: faction,
            slot: slot,
            size: size,
          ),
        ),
      ),
    );

    final dotSize = AppDimensions.destroyedMarkerSize(size);

    Widget result = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (slot.isTargetable && isTargeting)
            Positioned(
              top: -targetRingInset,
              right: -targetRingInset,
              bottom: -targetRingInset,
              left: -targetRingInset,
              child: IgnorePointer(
                child: DottedTargetRing(
                  color: highlightFaction.color,
                  strokeWidth: targetStrokeWidth,
                ),
              ),
            ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _canTap ? onTap : null,
            child: Opacity(
              opacity: dead ? AppDimensions.disabledSlotOpacity : 1,
              child: circle,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: AppDimensions.slotIndexBadgeSize(size),
              height: AppDimensions.slotIndexBadgeSize(size),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.ink,
                  width: AppDimensions.slotIndexBorderWidth(size),
                ),
              ),
              child: Center(
                child: Text(
                  '${slotIndex + 1}',
                  style: TextStyle(
                    fontFamily: AppText.display,
                    fontSize: AppDimensions.slotIndexFontSize(size),
                    height: 1,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
          if (dead)
            Positioned(
              bottom: size * 0.01,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (slot.killedBy ?? faction).color,
                  border: Border.all(
                    color: AppColors.ink,
                    width: AppDimensions.destroyedMarkerBorderWidth(size),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    result = Semantics(
      button: _canTap,
      enabled: _canTap,
      image: !_canTap,
      label: _semanticLabel(),
      excludeSemantics: true,
      child: result,
    );

    return result;
  }

  String _semanticLabel() {
    final owner = 'Player ${playerIndex + 1} ${faction.label}';
    final base = '$owner slot ${slotIndex + 1}';
    if (slot.isDestroyed) {
      final killer = slot.killedBy == null
          ? ''
          : ', killed by ${slot.killedBy!.label}';
      return '$base, destroyed$killer';
    }
    if (slot.isEmpty) return '$base, empty';

    final stage = switch (slot.stage!) {
      SoldierStage.spawned => 'spawned recruit',
      SoldierStage.trained => 'trained soldier',
      SoldierStage.armed => 'armed soldier',
      SoldierStage.strike => 'strike ready soldier',
      SoldierStage.grave => 'grave',
    };

    if (_canTap) {
      return 'Eliminate $owner slot ${slotIndex + 1}, $stage';
    }
    return '$base, $stage';
  }
}

class _SlotArt extends StatelessWidget {
  const _SlotArt({
    super.key,
    required this.faction,
    required this.slot,
    required this.size,
  });

  final Faction faction;
  final SlotState slot;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (slot.isEmpty) {
      return Center(
        child: Icon(
          Icons.add_rounded,
          size: size * AppDimensions.emptySlotIconRatio,
          color: faction.ring.withValues(alpha: 0.45),
        ),
      );
    }

    final stage = slot.stage!;
    final scale = switch (stage) {
      SoldierStage.spawned => AppDimensions.spawnedSoldierScale,
      SoldierStage.trained => AppDimensions.trainedSoldierScale,
      SoldierStage.armed => AppDimensions.armedSoldierScale,
      SoldierStage.strike => AppDimensions.strikeSoldierScale,
      SoldierStage.grave => AppDimensions.graveSoldierScale,
    };

    return Transform.scale(
      scale: scale,
      child: Image.asset(
        stage.assetPath(faction),
        fit: BoxFit.contain,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
