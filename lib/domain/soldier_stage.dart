import 'faction.dart';

enum SoldierStage {
  spawned(1, 'spawned_smile', '1_spawned_smile_retro.wav'),
  trained(2, 'helmet_stare', '2_helmet_stare_retro.wav'),
  armed(3, 'helmet_gun_evil_smile', '3_helmet_gun_evil_smile_retro.wav'),
  strike(4, 'helmet_gun_grin', '4_helmet_gun_grin_retro.wav'),
  grave(5, 'death_grave', '5_death_grave_retro.wav');

  const SoldierStage(this.level, this.assetName, this.soundFile);

  final int level;
  final String assetName;
  final String soundFile;

  bool get hasSoldier => level >= 1 && level <= 4;

  bool get isTargetable => level >= 2 && level <= 4;

  SoldierStage? get nextCombatStage => level < 4 ? values[level] : null;

  String assetPath(Faction faction) {
    return 'assets/characters/${faction.assetKey}/'
        '${faction.assetKey}_${level}_$assetName.png';
  }
}
