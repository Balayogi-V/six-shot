import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:six_shot/domain/faction.dart';
import 'package:six_shot/presentation/widgets/dice_overlay.dart';

void main() {
  testWidgets('resolves after the dice overlay closes and pauses', (
    tester,
  ) async {
    var closing = false;
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiceOverlay(
            face: 1,
            faction: Faction.red,
            onClosing: () => closing = true,
            onFinished: () => finished = true,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 240));
    await tester.pump(const Duration(milliseconds: 2880));
    expect(closing, isTrue);
    expect(finished, isFalse);

    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 240));
    await tester.pump();
    expect(finished, isFalse);
    await tester.pump(const Duration(milliseconds: 299));
    expect(finished, isFalse);
    await tester.pump(const Duration(milliseconds: 1));
    expect(finished, isTrue);
  });
}
