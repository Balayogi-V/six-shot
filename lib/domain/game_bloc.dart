import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'faction.dart';
import 'game_effect.dart';
import 'game_event.dart';
import 'game_state.dart';
import 'player_state.dart';
import 'slot_state.dart';
import 'soldier_stage.dart';

typedef DiceRoller = int Function();

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc({required int playerCount, DiceRoller? diceRoller})
    : _playerCount = playerCount,
      _diceRoller = diceRoller ?? _randomRoll,
      _nextEffectId = 1,
      super(GameState.initial(playerCount)) {
    _registerHandlers();
  }

  GameBloc.fromState({required GameState initialState, DiceRoller? diceRoller})
    : _playerCount = initialState.players.length,
      _diceRoller = diceRoller ?? _randomRoll,
      _nextEffectId = initialState.effects.isEmpty
          ? 1
          : initialState.effects.map((effect) => effect.id).reduce(max) + 1,
      super(initialState) {
    _registerHandlers();
  }

  final int _playerCount;
  final DiceRoller _diceRoller;
  int _nextEffectId;

  static int _randomRoll() => Random().nextInt(6) + 1;

  void _registerHandlers() {
    on<RollDice>(_onRollDice);
    on<ResolveRoll>(_onResolveRoll);
    on<SelectTarget>(_onSelectTarget);
    on<RestartGame>(_onRestartGame);
  }

  void _onRollDice(RollDice event, Emitter<GameState> emit) {
    if (!state.canRoll) return;
    final raw = _diceRoller();
    final face = raw < 1 ? 1 : (raw > 6 ? 6 : raw);
    emit(
      state.copyWith(
        phase: GamePhase.rolling,
        pendingRoll: face,
        message: '${state.activePlayer.faction.shortLabel} ROLLS THE DICE...',
      ),
    );
  }

  void _onResolveRoll(ResolveRoll event, Emitter<GameState> emit) {
    if (state.phase != GamePhase.rolling || state.pendingRoll == null) return;

    final playerIndex = state.activePlayerIndex;
    final active = state.players[playerIndex];
    final slotIndex = state.pendingRoll! - 1;
    final slot = active.slots[slotIndex];
    final players = List<PlayerState>.of(state.players);
    final faction = active.faction;

    if (slot.isDestroyed) {
      final wasted = _newEffect(GameEffectType.wasted);
      final message =
          '${faction.shortLabel} SLOT ${slotIndex + 1} IS DESTROYED. '
          'ROLL WASTED.';
      emit(
        _advanceTurn(
          _withEffect(
            state.copyWith(message: message, phase: GamePhase.awaitingRoll),
            wasted,
          ),
        ),
      );
      return;
    }

    if (slot.isEmpty) {
      players[playerIndex] = active.withSlot(
        slotIndex,
        const SlotState(stage: SoldierStage.spawned),
      );
      final effect = _newEffect(
        GameEffectType.spawn,
        stage: SoldierStage.spawned,
        faction: faction,
        playerIndex: playerIndex,
        slotIndex: slotIndex,
      );
      final message =
          '${faction.shortLabel} ROLLED ${state.pendingRoll} — '
          'NEW RECRUIT IN SLOT ${slotIndex + 1}!';
      emit(
        _advanceTurn(
          _withEffect(
            state.copyWith(
              players: players,
              message: message,
              phase: GamePhase.awaitingRoll,
            ),
            effect,
          ),
        ),
      );
      return;
    }

    final nextStage = slot.stage!.nextCombatStage;

    if (nextStage != null) {
      players[playerIndex] = active.withSlot(
        slotIndex,
        slot.copyWith(stage: nextStage),
      );
      final effect = _newEffect(
        GameEffectType.evolve,
        stage: nextStage,
        faction: faction,
        playerIndex: playerIndex,
        slotIndex: slotIndex,
      );

      if (nextStage == SoldierStage.strike) {
        if (_hasEnemyTargets(players, playerIndex)) {
          final message =
              '${faction.shortLabel} SLOT ${slotIndex + 1} IS STRIKE-READY — '
              'PICK A DOTTED TARGET!';
          emit(
            _withEffect(
              state.copyWith(
                players: players,
                phase: GamePhase.targeting,
                message: message,
              ),
              effect,
            ),
          );
          return;
        }

        final message =
            '${faction.shortLabel} SLOT ${slotIndex + 1} IS STRIKE-READY — '
            'NO TRAINED TARGETS. BULLET WASTED.';
        players[playerIndex] = players[playerIndex].withSlot(
          slotIndex,
          slot.copyWith(stage: SoldierStage.armed),
        );
        emit(
          _advanceTurn(
            _withEffect(
              _withEffect(
                state.copyWith(
                  players: players,
                  phase: GamePhase.awaitingRoll,
                  message: message,
                ),
                effect,
              ),
              _newEffect(GameEffectType.wasted),
            ),
          ),
        );
        return;
      }

      final label = switch (nextStage) {
        SoldierStage.trained => 'TRAINED',
        SoldierStage.armed => 'ARMED',
        _ => 'READY',
      };
      final message =
          '${faction.shortLabel} SLOT ${slotIndex + 1} EVOLVED — $label!';
      emit(
        _advanceTurn(
          _withEffect(
            state.copyWith(
              players: players,
              message: message,
              phase: GamePhase.awaitingRoll,
            ),
            effect,
          ),
        ),
      );
      return;
    }

    if (_hasEnemyTargets(players, playerIndex)) {
      final message =
          '${faction.shortLabel} SLOT ${slotIndex + 1} FIRES — '
          'PICK A DOTTED TARGET!';
      emit(
        _withEffect(
          state.copyWith(
            players: players,
            phase: GamePhase.targeting,
            message: message,
          ),
          _newEffect(
            GameEffectType.evolve,
            stage: SoldierStage.strike,
            faction: faction,
            playerIndex: playerIndex,
            slotIndex: slotIndex,
          ),
        ),
      );
      return;
    }

    final message =
        '${faction.shortLabel} SLOT ${slotIndex + 1} FIRES — '
        'NO TRAINED TARGETS. BULLET WASTED.';
    players[playerIndex] = active.withSlot(
      slotIndex,
      slot.copyWith(stage: SoldierStage.armed),
    );
    emit(
      _advanceTurn(
        _withEffect(
          state.copyWith(
            players: players,
            phase: GamePhase.awaitingRoll,
            message: message,
          ),
          _newEffect(GameEffectType.wasted),
        ),
      ),
    );
  }

  void _onSelectTarget(SelectTarget event, Emitter<GameState> emit) {
    if (state.phase != GamePhase.targeting) return;

    final target = event.target;
    if (target.playerIndex < 0 ||
        target.playerIndex >= state.players.length ||
        target.slotIndex < 0 ||
        target.slotIndex >= 6 ||
        target.playerIndex == state.activePlayerIndex) {
      return;
    }

    final victim = state.players[target.playerIndex];
    final targetSlot = victim.slots[target.slotIndex];
    if (!targetSlot.isTargetable) return;

    final killerIndex = state.activePlayerIndex;
    final killer = state.players[killerIndex];
    final players = List<PlayerState>.of(state.players);
    final firingSlotIndex = state.pendingRoll! - 1;
    final firingSlot = killer.slots[firingSlotIndex];

    players[target.playerIndex] = victim.withSlot(
      target.slotIndex,
      targetSlot.copyWith(stage: SoldierStage.grave, killedBy: killer.faction),
    );
    players[killerIndex] = killer
        .withSlot(
          firingSlotIndex,
          firingSlot.copyWith(stage: SoldierStage.armed),
        )
        .withKill();

    final updatedVictim = players[target.playerIndex];
    var message =
        '${killer.faction.shortLabel} ELIMINATED '
        '${victim.faction.shortLabel} SLOT ${target.slotIndex + 1}!';
    if (updatedVictim.isOut) {
      message += ' ${victim.faction.shortLabel} IS OUT!';
    }

    final effect = _newEffect(
      GameEffectType.kill,
      stage: SoldierStage.grave,
      faction: killer.faction,
      playerIndex: target.playerIndex,
      slotIndex: target.slotIndex,
    );

    emit(
      _advanceTurn(
        _withEffect(
          state.copyWith(
            players: players,
            phase: GamePhase.awaitingRoll,
            message: message,
          ),
          effect,
        ),
      ),
    );
  }

  void _onRestartGame(RestartGame event, Emitter<GameState> emit) {
    emit(GameState.initial(_playerCount));
  }

  bool _hasEnemyTargets(List<PlayerState> players, int activeIndex) {
    for (var p = 0; p < players.length; p++) {
      if (p == activeIndex) continue;
      for (final slot in players[p].slots) {
        if (slot.isTargetable) return true;
      }
    }
    return false;
  }

  GameState _advanceTurn(GameState state) {
    final alive = state.players.where((player) => !player.isOut).toList();

    if (alive.length <= 1) {
      final winner = alive.isEmpty
          ? state.activePlayer.faction
          : alive.first.faction;
      final message = '${winner.shortLabel} WINS THE BATTLE!';
      var result = state.copyWith(
        phase: GamePhase.gameOver,
        winner: winner,
        message: message,
      );
      result = _withEffect(
        result,
        _newEffect(GameEffectType.victory, faction: winner),
      );
      return result;
    }

    var next = (state.activePlayerIndex + 1) % state.players.length;
    var guard = 0;
    while (state.players[next].isOut && guard < state.players.length) {
      next = (next + 1) % state.players.length;
      guard++;
    }

    return state.copyWith(
      activePlayerIndex: next,
      phase: GamePhase.awaitingRoll,
      round: state.round + 1,
    );
  }

  GameEffect _newEffect(
    GameEffectType type, {
    SoldierStage? stage,
    Faction? faction,
    int? playerIndex,
    int? slotIndex,
  }) {
    return GameEffect(
      id: _nextEffectId++,
      type: type,
      stage: stage,
      faction: faction,
      playerIndex: playerIndex,
      slotIndex: slotIndex,
    );
  }

  GameState _withEffect(GameState state, GameEffect effect) {
    final effects = List<GameEffect>.of(state.effects)..add(effect);
    if (effects.length > 12) {
      effects.removeRange(0, effects.length - 12);
    }
    return state.copyWith(effects: effects);
  }
}
