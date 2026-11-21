import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/audio_service.dart';
import '../core/widgets/sparkle.dart';
import '../domain/game_bloc.dart';
import '../domain/game_effect.dart';
import '../domain/game_event.dart';
import '../domain/game_state.dart';
import '../domain/soldier_stage.dart';
import 'widgets/dice_overlay.dart';
import 'widgets/game_board.dart';
import 'widgets/game_header.dart';
import 'widgets/roll_bar.dart';
import 'widgets/status_banner.dart';
import 'widgets/win_overlay.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.playerCount});

  final int playerCount;

  static Route<void> route(int playerCount) {
    return MaterialPageRoute<void>(
      builder: (_) => GameScreen(playerCount: playerCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc(playerCount: playerCount),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatefulWidget {
  const _GameView();

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  int _lastEffectId = 0;
  bool _diceSettling = false;

  @override
  void initState() {
    super.initState();
    AudioService.instance.startMusic();
  }

  @override
  void dispose() {
    AudioService.instance.stopMusic();
    super.dispose();
  }

  void _playEffects(BuildContext _, GameState state) {
    final fresh = state.effects
        .where((effect) => effect.id > _lastEffectId)
        .toList();
    if (fresh.isEmpty) return;
    _lastEffectId = fresh.last.id;

    for (final effect in fresh) {
      switch (effect.type) {
        case GameEffectType.spawn:
          _playStage(effect.stage);
          HapticFeedback.lightImpact();
        case GameEffectType.evolve:
          _playStage(effect.stage);
          HapticFeedback.mediumImpact();
        case GameEffectType.kill:
          _playStage(effect.stage);
          HapticFeedback.heavyImpact();
        case GameEffectType.wasted:
          HapticFeedback.selectionClick();
        case GameEffectType.victory:
          AudioService.instance.playVictory(
            delay: const Duration(milliseconds: 650),
          );
          HapticFeedback.vibrate();
      }
    }
  }

  void _playStage(SoldierStage? stage) {
    if (stage == null) return;
    AudioService.instance.playStage(stage);
  }

  bool _hasNewEffects(GameState previous, GameState current) {
    if (current.effects.isEmpty) return false;
    final previousId = previous.effects.isEmpty ? 0 : previous.effects.last.id;
    return current.effects.last.id > previousId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
      listenWhen: _hasNewEffects,
      listener: _playEffects,
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          final rolling = state.phase == GamePhase.rolling;
          final boardRolling = rolling && !_diceSettling;
          final gameOver = state.phase == GamePhase.gameOver;
          final activeFaction = state.activePlayer.faction;

          return Scaffold(
            body: Stack(
              children: [
                const Positioned.fill(child: _GameBackdrop()),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Column(
                      children: [
                        GameHeader(
                          state: state,
                          onBack: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 220),
                            opacity: boardRolling ? 0.32 : 1,
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 220),
                              scale: boardRolling ? 0.985 : 1,
                              child: GameBoard(
                                state: state,
                                onTargetSelected: (target) {
                                  HapticFeedback.selectionClick();
                                  context.read<GameBloc>().add(
                                    SelectTarget(target),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        StatusBanner(state: state),
                        const SizedBox(height: 10),
                        RollBar(
                          state: state,
                          onRoll: () {
                            HapticFeedback.mediumImpact();
                            setState(() => _diceSettling = false);
                            AudioService.instance.playDiceRoll();
                            context.read<GameBloc>().add(const RollDice());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (rolling && state.pendingRoll != null)
                  Positioned.fill(
                    child: DiceOverlay(
                      face: state.pendingRoll!,
                      faction: activeFaction,
                      onClosing: () {
                        if (!mounted) return;
                        setState(() => _diceSettling = true);
                      },
                      onFinished: () {
                        if (!mounted) return;
                        context.read<GameBloc>().add(const ResolveRoll());
                      },
                    ),
                  ),
                if (gameOver && state.winner != null)
                  Positioned.fill(
                    child: WinOverlay(
                      state: state,
                      onPlayAgain: () {
                        AudioService.instance.stopVictory();
                        HapticFeedback.mediumImpact();
                        context.read<GameBloc>().add(const RestartGame());
                      },
                      onHome: () {
                        AudioService.instance.stopVictory();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GameBackdrop extends StatelessWidget {
  const _GameBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: Image(
            image: AssetImage('assets/images/game_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        const Positioned(
          top: 92,
          left: 18,
          child: IgnorePointer(
            child: Sparkle(size: 14, color: Color(0xFFFFEBC0)),
          ),
        ),
        const Positioned(
          bottom: 152,
          right: 22,
          child: IgnorePointer(
            child: Sparkle(size: 18, color: Color(0xFFFFE3A0)),
          ),
        ),
      ],
    );
  }
}
