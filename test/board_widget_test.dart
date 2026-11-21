import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:six_shot/domain/faction.dart';
import 'package:six_shot/domain/game_state.dart';
import 'package:six_shot/domain/player_state.dart';
import 'package:six_shot/domain/slot_state.dart';
import 'package:six_shot/domain/soldier_stage.dart';
import 'package:six_shot/presentation/widgets/game_board.dart';
import 'package:six_shot/presentation/widgets/dotted_target_ring.dart';
import 'package:six_shot/presentation/widgets/slot_circle.dart';

void main() {
  testWidgets('six player board lays out without overflow', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final players = [
      for (var p = 0; p < 6; p++)
        PlayerState(
          faction: Faction.values[p],
          kills: p,
          slots: List<SlotState>.generate(6, (index) {
            if (index == 5 && p == 2) {
              return const SlotState(
                stage: SoldierStage.grave,
                killedBy: Faction.red,
              );
            }
            if (index < p + 1) {
              return SlotState(stage: SoldierStage.values[index % 4]);
            }
            return const SlotState.empty();
          }),
        ),
    ];

    final state = GameState(
      players: players,
      activePlayerIndex: 1,
      phase: GamePhase.awaitingRoll,
      effects: const [],
      message: 'GREEN STARTS - ROLL THE DICE!',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: 390,
            height: 560,
            child: GameBoard(state: state, onTargetSelected: (_) {}),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byType(SlotCircle), findsNWidgets(36));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('target ring sits outside the slot border and leaves its index', (
    tester,
  ) async {
    final players = [
      PlayerState.newPlayer(
        Faction.red,
      ).withSlot(0, const SlotState(stage: SoldierStage.strike)),
      PlayerState.newPlayer(
        Faction.green,
      ).withSlot(0, const SlotState(stage: SoldierStage.armed)),
    ];
    final state = GameState(
      players: players,
      activePlayerIndex: 0,
      phase: GamePhase.targeting,
      pendingRoll: 1,
      effects: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 560,
            child: GameBoard(state: state, onTargetSelected: (_) {}),
          ),
        ),
      ),
    );

    final targetSlot = find.byType(SlotCircle).at(6);
    final ring = find.byType(DottedTargetRing);
    final slotTopLeft = tester.getTopLeft(targetSlot);
    final slotSize = tester.getSize(targetSlot);
    final ringTopLeft = tester.getTopLeft(ring);
    final ringSize = tester.getSize(ring);

    expect(ringSize.width, greaterThan(slotSize.width));
    expect(ringTopLeft.dx, lessThan(slotTopLeft.dx));
    expect(ringTopLeft.dy, lessThan(slotTopLeft.dy));
    expect(find.text('1'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('destroyed slot looks disabled and cannot be tapped', (
    tester,
  ) async {
    var tapped = false;
    const slotKey = ValueKey('destroyed-slot');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SlotCircle(
              key: slotKey,
              faction: Faction.green,
              playerIndex: 1,
              slotIndex: 2,
              slot: const SlotState(
                stage: SoldierStage.grave,
                killedBy: Faction.red,
              ),
              size: 60,
              highlightFaction: Faction.red,
              isTargeting: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    final slot = find.byKey(slotKey);
    final opacity = find.descendant(of: slot, matching: find.byType(Opacity));
    expect(opacity, findsOneWidget);
    expect(tester.widget<Opacity>(opacity).opacity, lessThan(1));
    expect(find.text('3'), findsOneWidget);

    await tester.tap(slot);
    expect(tapped, isFalse);
    expect(tester.takeException(), isNull);
  });
}
