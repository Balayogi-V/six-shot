import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:six_shot/domain/game_state.dart';
import 'package:six_shot/presentation/widgets/game_header.dart';

void main() {
  testWidgets('game header back button invokes its navigation callback', (
    tester,
  ) async {
    var navigatedBack = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameHeader(
            state: GameState.initial(2),
            onBack: () => navigatedBack = true,
          ),
        ),
      ),
    );

    final backButton = find.byIcon(Icons.arrow_back_rounded);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);

    expect(navigatedBack, isTrue);
    expect(tester.takeException(), isNull);
  });
}
