import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../domain/soldier_stage.dart';

class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();
  static const bool backgroundMusicEnabled = false;

  final ValueNotifier<bool> muted = ValueNotifier<bool>(false);

  final AudioPlayer _sfx = AudioPlayer(playerId: 'six-shot-sfx');
  final AudioPlayer _dice = AudioPlayer(playerId: 'six-shot-dice');
  final AudioPlayer _victory = AudioPlayer(playerId: 'six-shot-victory');
  final AudioPlayer _music = AudioPlayer(playerId: 'six-shot-music');

  int _victoryToken = 0;
  bool _musicRequested = false;

  Future<void> playDiceRoll() {
    return _play(_dice, 'audio/dice_roll.wav', volume: 0.9);
  }

  Future<void> stopDice() async {
    try {
      await _dice.stop();
    } catch (error) {
      debugPrint('Dice audio stop failed: $error');
    }
  }

  Future<void> playStage(SoldierStage stage) {
    return _play(_sfx, 'audio/${stage.soundFile}', volume: 0.85);
  }

  Future<void> playVictory({Duration delay = Duration.zero}) async {
    final token = ++_victoryToken;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (token != _victoryToken) return;
    await _play(_victory, 'audio/victory.wav', volume: 1);
  }

  Future<void> stopVictory() async {
    _victoryToken++;
    try {
      await _victory.stop();
    } catch (error) {
      debugPrint('Victory audio stop failed: $error');
    }
  }

  Future<void> startMusic() async {
    if (!backgroundMusicEnabled) return;
    _musicRequested = true;
    if (muted.value) return;
    try {
      await _music.stop();
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.play(AssetSource('audio/game_music.wav'), volume: 0.2);
    } catch (error) {
      debugPrint('Music playback failed: $error');
    }
  }

  Future<void> stopMusic() async {
    _musicRequested = false;
    try {
      await _music.stop();
    } catch (error) {
      debugPrint('Music stop failed: $error');
    }
  }

  void toggleMuted() {
    muted.value = !muted.value;
    if (muted.value) {
      _victoryToken++;
      _sfx.stop();
      _dice.stop();
      _victory.stop();
      _music.stop();
    } else if (_musicRequested) {
      startMusic();
    }
  }

  Future<void> _play(
    AudioPlayer player,
    String asset, {
    required double volume,
  }) async {
    if (muted.value) return;
    try {
      await player.stop();
      if (muted.value) return;
      await player.play(AssetSource(asset), volume: volume);
    } catch (error) {
      debugPrint('Audio playback failed for $asset: $error');
    }
  }

  Future<void> dispose() async {
    await _sfx.dispose();
    await _dice.dispose();
    await _victory.dispose();
    await _music.dispose();
  }
}
