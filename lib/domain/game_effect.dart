import 'package:equatable/equatable.dart';

import 'faction.dart';
import 'soldier_stage.dart';

enum GameEffectType { spawn, evolve, kill, wasted, victory }

class GameEffect extends Equatable {
  const GameEffect({
    required this.id,
    required this.type,
    this.stage,
    this.faction,
    this.playerIndex,
    this.slotIndex,
  });

  final int id;
  final GameEffectType type;
  final SoldierStage? stage;
  final Faction? faction;
  final int? playerIndex;
  final int? slotIndex;

  @override
  List<Object?> get props => [id, type, stage, faction, playerIndex, slotIndex];
}
