import 'package:equatable/equatable.dart';

import 'faction.dart';
import 'game_effect.dart';
import 'player_state.dart';

enum GamePhase { awaitingRoll, rolling, targeting, gameOver }

class SlotRef extends Equatable {
  const SlotRef(this.playerIndex, this.slotIndex);

  final int playerIndex;
  final int slotIndex;

  @override
  List<Object?> get props => [playerIndex, slotIndex];
}

class GameState extends Equatable {
  const GameState({
    required this.players,
    required this.activePlayerIndex,
    required this.phase,
    required this.effects,
    this.pendingRoll,
    this.winner,
    this.message,
    this.round = 1,
  });

  factory GameState.initial(int playerCount) {
    assert(playerCount >= 2 && playerCount <= 6);
    final players = List<PlayerState>.generate(
      playerCount,
      (index) => PlayerState.newPlayer(Faction.values[index]),
    );
    return GameState(
      players: players,
      activePlayerIndex: 0,
      phase: GamePhase.awaitingRoll,
      effects: const [],
      message: '${players.first.faction.shortLabel} STARTS — ROLL THE DICE!',
    );
  }

  final List<PlayerState> players;
  final int activePlayerIndex;
  final GamePhase phase;
  final int? pendingRoll;
  final Faction? winner;
  final String? message;
  final int round;
  final List<GameEffect> effects;

  PlayerState get activePlayer => players[activePlayerIndex];

  bool get canRoll => phase == GamePhase.awaitingRoll && winner == null;

  bool get isAiming => phase == GamePhase.targeting;

  List<SlotRef> get validTargets {
    if (phase != GamePhase.targeting) return const [];
    final targets = <SlotRef>[];
    for (var p = 0; p < players.length; p++) {
      if (p == activePlayerIndex) continue;
      for (var s = 0; s < players[p].slots.length; s++) {
        if (players[p].slots[s].isTargetable) {
          targets.add(SlotRef(p, s));
        }
      }
    }
    return targets;
  }

  GameState copyWith({
    List<PlayerState>? players,
    int? activePlayerIndex,
    GamePhase? phase,
    int? pendingRoll,
    Faction? winner,
    String? message,
    int? round,
    List<GameEffect>? effects,
  }) {
    return GameState(
      players: players ?? this.players,
      activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
      phase: phase ?? this.phase,
      pendingRoll: pendingRoll ?? this.pendingRoll,
      winner: winner ?? this.winner,
      message: message ?? this.message,
      round: round ?? this.round,
      effects: effects ?? this.effects,
    );
  }

  @override
  List<Object?> get props => [
    players,
    activePlayerIndex,
    phase,
    pendingRoll,
    winner,
    message,
    round,
    effects,
  ];
}
