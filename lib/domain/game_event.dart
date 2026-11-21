import 'package:equatable/equatable.dart';

import 'game_state.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => const [];
}

class RollDice extends GameEvent {
  const RollDice();
}

class ResolveRoll extends GameEvent {
  const ResolveRoll();
}

class SelectTarget extends GameEvent {
  const SelectTarget(this.target);

  final SlotRef target;

  @override
  List<Object?> get props => [target];
}

class RestartGame extends GameEvent {
  const RestartGame();
}
