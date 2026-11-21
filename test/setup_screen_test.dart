import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:six_shot/presentation/setup_screen.dart';

void main() {
  testWidgets('setup screen lays out without intrinsic dimension errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: SetupScreen()));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('setup screen scrolls on a short viewport', (tester) async {
    tester.view.physicalSize = const Size(430, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: SetupScreen()));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
