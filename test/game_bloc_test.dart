import 'dart:collection';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:six_shot/domain/faction.dart';
import 'package:six_shot/domain/game_bloc.dart';
import 'package:six_shot/domain/game_effect.dart';
import 'package:six_shot/domain/game_event.dart';
import 'package:six_shot/domain/game_state.dart';
import 'package:six_shot/domain/player_state.dart';
import 'package:six_shot/domain/slot_state.dart';
import 'package:six_shot/domain/soldier_stage.dart';

DiceRoller _dice(List<int> values) {
  final queue = Queue<int>.of(values);
  return () {
    if (queue.isEmpty) {
      throw StateError('Dice sequence exhausted');
    }
    return queue.removeFirst();
  };
}

PlayerState _player(
  Faction faction, {
  Map<int, SlotState> slots = const {},
  int kills = 0,
}) {
  return PlayerState(
    faction: faction,
    kills: kills,
    slots: List<SlotState>.generate(
      6,
      (index) => slots[index] ?? const SlotState.empty(),
    ),
  );
}

GameState _state({
  required List<PlayerState> players,
  int activePlayerIndex = 0,
  GamePhase phase = GamePhase.awaitingRoll,
  int? pendingRoll,
}) {
  return GameState(
    players: players,
    activePlayerIndex: activePlayerIndex,
    phase: phase,
    pendingRoll: pendingRoll,
    effects: const [],
    message: 'TEST',
  );
}

Future<void> _takeTurn(GameBloc bloc) async {
  bloc.add(const RollDice());
  bloc.add(const ResolveRoll());
  await pumpEventQueue();
}

Future<GameBloc> _strikeReadyRedVersusArmedGreen() async {
  final bloc = GameBloc(
    playerCount: 2,
    diceRoller: _dice(List<int>.filled(20, 1)),
  );
  for (var i = 0; i < 7; i++) {
    await _takeTurn(bloc);
  }
  return bloc;
}

void main() {
  group('setup', () {
    test('initial state has empty slots and the first player active', () {
      final bloc = GameBloc(playerCount: 3, diceRoller: _dice([1]));
      addTearDown(bloc.close);

      expect(bloc.state.players.length, 3);
      expect(bloc.state.activePlayer.faction, Faction.red);
      expect(bloc.state.phase, GamePhase.awaitingRoll);
      expect(bloc.state.round, 1);
      expect(bloc.state.canRoll, isTrue);
      for (final player in bloc.state.players) {
        expect(player.slots.every((slot) => slot.isEmpty), isTrue);
      }
    });

    blocTest<GameBloc, GameState>(
      'rolling enters the rolling phase with the rolled face',
      build: () => GameBloc(playerCount: 2, diceRoller: _dice([4])),
      act: (bloc) => bloc.add(const RollDice()),
      expect: () => [
        isA<GameState>()
            .having((state) => state.phase, 'phase', GamePhase.rolling)
            .having((state) => state.pendingRoll, 'pendingRoll', 4),
      ],
    );
  });

  group('spawn and evolution', () {
    test('rolling an empty slot spawns a recruit and advances turn', () async {
      final bloc = GameBloc(playerCount: 2, diceRoller: _dice([2]));
      addTearDown(bloc.close);

      await _takeTurn(bloc);

      final red = bloc.state.players[0];
      expect(red.slots[1].stage, SoldierStage.spawned);
      expect(bloc.state.activePlayerIndex, 1);
      expect(bloc.state.phase, GamePhase.awaitingRoll);
      expect(bloc.state.round, 2);
      expect(bloc.state.effects.last.type, GameEffectType.spawn);
      expect(bloc.state.message, contains('NEW RECRUIT IN SLOT 2'));
    });

    test('soldiers evolve and strike-ready enters targeting', () async {
      final bloc = await _strikeReadyRedVersusArmedGreen();
      addTearDown(bloc.close);

      expect(bloc.state.players[0].slots[0].stage, SoldierStage.strike);
      expect(bloc.state.phase, GamePhase.targeting);
      expect(bloc.state.activePlayerIndex, 0);
      expect(bloc.state.validTargets, contains(const SlotRef(1, 0)));
      expect(bloc.state.isAiming, isTrue);
    });

    test('strike-ready with no trained enemies wastes the bullet', () async {
      final bloc = GameBloc(
        playerCount: 2,
        diceRoller: _dice([1, 1, 1, 2, 1, 3, 1]),
      );
      addTearDown(bloc.close);

      for (var i = 0; i < 7; i++) {
        await _takeTurn(bloc);
      }

      expect(bloc.state.players[0].slots[0].stage, SoldierStage.armed);
      expect(bloc.state.phase, GamePhase.awaitingRoll);
      expect(bloc.state.activePlayerIndex, 1);
      expect(bloc.state.message, contains('BULLET WASTED'));
      expect(
        bloc.state.effects.any(
          (effect) => effect.type == GameEffectType.wasted,
        ),
        isTrue,
      );
    });

    test('rolling an existing strike-ready soldier fires again', () async {
      final players = [
        _player(
          Faction.red,
          slots: const {0: SlotState(stage: SoldierStage.strike)},
        ),
        _player(
          Faction.green,
          slots: const {0: SlotState(stage: SoldierStage.armed)},
        ),
      ];
      final bloc = GameBloc.fromState(
        initialState: _state(players: players),
        diceRoller: _dice([1]),
      );
      addTearDown(bloc.close);

      await _takeTurn(bloc);

      expect(bloc.state.phase, GamePhase.targeting);
      expect(bloc.state.players[0].slots[0].stage, SoldierStage.strike);
      expect(bloc.state.message, contains('FIRES'));
    });

    test(
      'existing strike-ready soldier returns to armed when no target exists',
      () async {
        final players = [
          _player(
            Faction.red,
            slots: const {0: SlotState(stage: SoldierStage.strike)},
          ),
          _player(Faction.green),
        ];
        final bloc = GameBloc.fromState(
          initialState: _state(players: players),
          diceRoller: _dice([1]),
        );
        addTearDown(bloc.close);

        await _takeTurn(bloc);

        expect(bloc.state.players[0].slots[0].stage, SoldierStage.armed);
        expect(bloc.state.phase, GamePhase.awaitingRoll);
        expect(bloc.state.message, contains('BULLET WASTED'));
      },
    );
  });

  group('bullets and kills', () {
    test(
      'eliminating a trained target awards a kill and locks the slot',
      () async {
        final bloc = await _strikeReadyRedVersusArmedGreen();
        addTearDown(bloc.close);

        bloc.add(const SelectTarget(SlotRef(1, 0)));
        await pumpEventQueue();

        final green = bloc.state.players[1];
        expect(bloc.state.players[0].kills, 1);
        expect(green.slots[0].isDestroyed, isTrue);
        expect(green.slots[0].killedBy, Faction.red);
        expect(bloc.state.phase, GamePhase.awaitingRoll);
        expect(bloc.state.activePlayerIndex, 1);
        expect(bloc.state.players[0].slots[0].stage, SoldierStage.armed);
        expect(bloc.state.effects.last.type, GameEffectType.kill);
      },
    );

    test('untrained and friendly slots cannot be targeted', () async {
      final bloc = await _strikeReadyRedVersusArmedGreen();
      addTearDown(bloc.close);
      final before = bloc.state;

      bloc.add(const SelectTarget(SlotRef(1, 1)));
      bloc.add(const SelectTarget(SlotRef(0, 0)));
      await pumpEventQueue();

      expect(bloc.state, before);
      expect(bloc.state.players[0].kills, 0);
    });

    test('rolling a destroyed slot wastes the turn', () async {
      final players = [
        _player(Faction.red),
        _player(
          Faction.green,
          slots: {
            0: const SlotState(
              stage: SoldierStage.grave,
              killedBy: Faction.red,
            ),
          },
        ),
      ];
      final bloc = GameBloc.fromState(
        initialState: _state(players: players, activePlayerIndex: 1),
        diceRoller: _dice([1]),
      );
      addTearDown(bloc.close);

      await _takeTurn(bloc);

      expect(bloc.state.players[1].slots[0].isDestroyed, isTrue);
      expect(bloc.state.activePlayerIndex, 0);
      expect(bloc.state.message, contains('ROLL WASTED'));
      expect(bloc.state.effects.last.type, GameEffectType.wasted);
    });

    test('eliminating the last live slot wins the game', () async {
      final players = [
        _player(
          Faction.red,
          slots: const {0: SlotState(stage: SoldierStage.strike)},
          kills: 2,
        ),
        _player(
          Faction.green,
          slots: {
            0: const SlotState(
              stage: SoldierStage.grave,
              killedBy: Faction.red,
            ),
            1: const SlotState(
              stage: SoldierStage.grave,
              killedBy: Faction.red,
            ),
            2: const SlotState(
              stage: SoldierStage.grave,
              killedBy: Faction.red,
            ),
            3: const SlotState(
              stage: SoldierStage.grave,
              killedBy: Faction.red,
            ),
            4: const SlotState(
              stage: SoldierStage.grave,
              killedBy: Faction.red,
            ),
            5: const SlotState(stage: SoldierStage.armed),
          },
        ),
      ];
      final bloc = GameBloc.fromState(
        initialState: _state(
          players: players,
          phase: GamePhase.targeting,
          pendingRoll: 1,
        ),
        diceRoller: _dice([1]),
      );
      addTearDown(bloc.close);

      bloc.add(const SelectTarget(SlotRef(1, 5)));
      await pumpEventQueue();

      expect(bloc.state.phase, GamePhase.gameOver);
      expect(bloc.state.winner, Faction.red);
      expect(bloc.state.players[1].isOut, isTrue);
      expect(bloc.state.players[0].kills, 3);
      expect(
        bloc.state.effects.map((effect) => effect.type),
        containsAll([GameEffectType.kill, GameEffectType.victory]),
      );
      expect(bloc.state.effects.last.type, GameEffectType.victory);
    });
  });

  group('turn order and restart', () {
    test('eliminated players are skipped in turn order', () async {
      final deadSlots = {
        for (var i = 0; i < 6; i++)
          i: const SlotState(stage: SoldierStage.grave, killedBy: Faction.red),
      };
      final players = [
        _player(Faction.red),
        _player(Faction.green, slots: deadSlots),
        _player(Faction.yellow),
      ];
      final bloc = GameBloc.fromState(
        initialState: _state(players: players),
        diceRoller: _dice([1]),
      );
      addTearDown(bloc.close);

      await _takeTurn(bloc);

      expect(bloc.state.activePlayerIndex, 2);
      expect(bloc.state.activePlayer.faction, Faction.yellow);
    });

    test('restarting resets the whole match', () async {
      final players = [
        _player(Faction.red, kills: 3),
        _player(
          Faction.green,
          slots: {
            2: const SlotState(
              stage: SoldierStage.grave,
              killedBy: Faction.red,
            ),
          },
        ),
      ];
      final bloc = GameBloc.fromState(
        initialState: _state(players: players, activePlayerIndex: 1),
        diceRoller: _dice([1]),
      );
      addTearDown(bloc.close);

      bloc.add(const RestartGame());
      await pumpEventQueue();

      expect(bloc.state, GameState.initial(2));
      expect(bloc.state.players[0].kills, 0);
      expect(
        bloc.state.players.every(
          (player) => player.slots.every((slot) => slot.isEmpty),
        ),
        isTrue,
      );
    });
  });
}
