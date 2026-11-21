import 'package:flutter_test/flutter_test.dart';
import 'package:six_shot/core/audio_service.dart';

void main() {
  test('background music is disabled by the feature flag', () {
    expect(AudioService.backgroundMusicEnabled, isFalse);
  });
}
