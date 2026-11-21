import 'package:equatable/equatable.dart';

import 'faction.dart';
import 'soldier_stage.dart';

class SlotState extends Equatable {
  const SlotState({this.stage, this.killedBy});

  const SlotState.empty() : stage = null, killedBy = null;

  final SoldierStage? stage;
  final Faction? killedBy;

  bool get isEmpty => stage == null;

  bool get isDestroyed => stage == SoldierStage.grave;

  bool get hasSoldier => stage != null && stage!.hasSoldier;

  bool get isTargetable => hasSoldier && stage!.isTargetable;

  SlotState copyWith({SoldierStage? stage, Faction? killedBy}) {
    return SlotState(
      stage: stage ?? this.stage,
      killedBy: killedBy ?? this.killedBy,
    );
  }

  @override
  List<Object?> get props => [stage, killedBy];
}
