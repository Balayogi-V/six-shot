import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../core/app_dimensions.dart';
import '../core/faction_ui.dart';
import '../core/widgets/brawler_button.dart';
import '../core/widgets/game_icons.dart';
import '../core/widgets/sound_toggle.dart';
import '../core/widgets/sparkle.dart';
import '../core/widgets/starburst.dart';
import '../domain/faction.dart';
import '../domain/soldier_stage.dart';
import 'game_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _playerCount = 4;

  void _startGame() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(GameScreen.route(_playerCount));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/images/game_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          const Positioned(
            top: 74,
            right: 26,
            child: IgnorePointer(
              child: Sparkle(size: 20, color: Color(0xFFFFE3A0)),
            ),
          ),
          const Positioned(
            top: 224,
            left: 16,
            child: IgnorePointer(
              child: Sparkle(size: 13, color: Color(0xFFFFEBC0)),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight >
                              AppDimensions.setupViewportHeightInset
                          ? constraints.maxHeight -
                                AppDimensions.setupViewportHeightInset
                          : 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _TopBar(),
                        const SizedBox(height: 20),
                        _LineupCard(playerCount: _playerCount),
                        const SizedBox(height: 18),
                        _PlayerCountSelector(
                          playerCount: _playerCount,
                          onChanged: (count) {
                            HapticFeedback.selectionClick();
                            setState(() => _playerCount = count);
                          },
                        ),
                        const SizedBox(height: 18),
                        const _RulesCard(),
                        const SizedBox(height: 24),
                        BrawlerButton(
                          label: 'START BATTLE',
                          color: AppColors.green,
                          height: 72,
                          fontSize: 30,
                          icon: const DiceGlyph(size: 28),
                          semanticLabel: 'Start a $_playerCount player battle',
                          onPressed: _startGame,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'PASS & PLAY  •  2–6 PLAYERS  •  LAST SQUAD STANDING',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppText.body,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.ink, width: 3),
            boxShadow: const [
              BoxShadow(
                color: AppColors.ink,
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/app_icon_small.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'TACTICAL SLOT SHOOTER',
                style: TextStyle(
                  fontFamily: AppText.body,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.1,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const SoundToggle(),
      ],
    );
  }
}

class _LineupCard extends StatelessWidget {
  const _LineupCard({required this.playerCount});

  final int playerCount;

  @override
  Widget build(BuildContext context) {
    final colors = Faction.values.map((faction) => faction.color).toList();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.ink, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.16),
            offset: const Offset(0, 7),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: Starburst(colors: colors, opacity: 0.13)),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text(
                      'THE LINEUP',
                      style: TextStyle(
                        fontFamily: AppText.display,
                        fontSize: 21,
                        height: 1,
                        color: AppColors.ink,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.ink, width: 2),
                      ),
                      child: const Text(
                        'PASS & PLAY',
                        style: TextStyle(
                          fontFamily: AppText.body,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final tokenSize = math.min(
                      AppDimensions.lineupMaxTokenSize,
                      (constraints.maxWidth -
                              (Faction.values.length - 1) *
                                  AppDimensions.lineupTokenGap) /
                          Faction.values.length,
                    );
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < Faction.values.length; i++)
                          _FactionPreview(
                            faction: Faction.values[i],
                            index: i,
                            size: tokenSize,
                            active: i < playerCount,
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 9),
                Text(
                  '$playerCount PLAYERS READY',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppText.body,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FactionPreview extends StatelessWidget {
  const _FactionPreview({
    required this.faction,
    required this.index,
    required this.size,
    required this.active,
  });

  final Faction faction;
  final int index;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: active ? 1 : 0.24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: faction.soft,
              border: Border.all(color: AppColors.ink, width: 2.4),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: faction.ring.withValues(alpha: 0.35),
                        offset: const Offset(0, 2.5),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.all(size * 0.06),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: faction.ring, width: size * 0.05),
                ),
                child: ClipOval(
                  child: Transform.scale(
                    scale: 1.12,
                    child: Image.asset(
                      SoldierStage.armed.assetPath(faction),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 15,
            child: active
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: faction.color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'P${index + 1}',
                      style: TextStyle(
                        fontFamily: AppText.display,
                        fontSize: 9,
                        height: 1.15,
                        color: faction.onColor,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _PlayerCountSelector extends StatelessWidget {
  const _PlayerCountSelector({
    required this.playerCount,
    required this.onChanged,
  });

  final int playerCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: const [
            Text(
              'PLAYERS',
              style: TextStyle(
                fontFamily: AppText.body,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
                color: AppColors.ink,
              ),
            ),
            Spacer(),
            Text(
              'CHOOSE 2–6',
              style: TextStyle(
                fontFamily: AppText.body,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var count = 2; count <= 6; count++) ...[
              Expanded(
                child: _CountChip(
                  count: count,
                  selected: count == playerCount,
                  onTap: () => onChanged(count),
                ),
              ),
              if (count != 6) const SizedBox(width: 7),
            ],
          ],
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final faction = Faction.values[count - 1];
    return Semantics(
      button: true,
      selected: selected,
      label: '$count players',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutBack,
          scale: selected ? 1.05 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 48,
            decoration: BoxDecoration(
              color: selected ? faction.color : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.ink,
                width: selected ? 3 : 2.2,
              ),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: AppColors.ink,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: AppText.display,
                  fontSize: selected ? 24 : 20,
                  height: 1,
                  color: selected ? faction.onColor : AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard();

  static const _rules = [
    'Roll the dice. Fill the matching slot or evolve its soldier.',
    'Reach Strike-Ready, then tap a dotted trained enemy to eliminate it.',
    'Destroyed slots stay locked. Rolling one wastes your turn.',
    'Be the last squad with a live slot to win the battle.',
  ];

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.red,
      AppColors.yellow,
      AppColors.blue,
      AppColors.green,
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.ink, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.10),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'HOW TO PLAY',
            style: TextStyle(
              fontFamily: AppText.display,
              fontSize: 19,
              height: 1,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 11),
          for (var i = 0; i < _rules.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 21,
                  height: 21,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[i],
                    border: Border.all(color: AppColors.ink, width: 1.8),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontFamily: AppText.display,
                        fontSize: 11,
                        height: 1,
                        color: i == 1 ? AppColors.ink : AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _rules[i],
                    style: const TextStyle(
                      fontFamily: AppText.body,
                      fontSize: 12.5,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            if (i != _rules.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
