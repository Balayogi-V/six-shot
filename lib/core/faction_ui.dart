import 'package:flutter/material.dart';

import '../domain/faction.dart';
import 'app_colors.dart';

extension FactionUi on Faction {
  Color get color => switch (this) {
    Faction.red => const Color(0xFFE05243),
    Faction.green => const Color(0xFF58A83B),
    Faction.yellow => const Color(0xFFF0C43C),
    Faction.blue => const Color(0xFF4C92C3),
    Faction.purple => const Color(0xFF9165BC),
    Faction.orange => const Color(0xFFEE8B3A),
  };

  Color get ring => switch (this) {
    Faction.red => const Color(0xFFB53A2E),
    Faction.green => const Color(0xFF3E7E28),
    Faction.yellow => const Color(0xFFC29A1B),
    Faction.blue => const Color(0xFF356F99),
    Faction.purple => const Color(0xFF6B448F),
    Faction.orange => const Color(0xFFC56C22),
  };

  Color get soft => switch (this) {
    Faction.red => const Color(0xFFF9DFDA),
    Faction.green => const Color(0xFFE1F0D5),
    Faction.yellow => const Color(0xFFFBF0C4),
    Faction.blue => const Color(0xFFDDEDF6),
    Faction.purple => const Color(0xFFEADFF4),
    Faction.orange => const Color(0xFFFCE6D2),
  };

  Color get onColor => this == Faction.yellow ? AppColors.ink : AppColors.white;
}
