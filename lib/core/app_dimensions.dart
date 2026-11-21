class AppDimensions {
  AppDimensions._();

  static const double setupViewportHeightInset = 36;
  static const double lineupMaxTokenSize = 56;
  static const double lineupTokenGap = 8;

  static const int denseBoardPlayerThreshold = 5;
  static const double denseBoardPlayerGap = 4;
  static const double boardPlayerGap = 8;
  static const double denseBoardSlotGap = 4;
  static const double boardSlotGap = 6;
  static const double boardHeaderHeight = 31;
  static const double boardHeaderSlotGap = 4;
  static const double boardMinColumnWidth = 30;
  static const double boardMaxColumnWidth = 92;
  static const double boardHeightInset = 8;
  static const double boardMinUsableHeight = 120;
  static const double boardMaxSlotSize = 88;
  static const double playerBadgeMaxWidth = 46;
  static const double activePlayerIndicatorHeight = 11;
  static const double activePlayerIndicatorGap = 2;
  static const double playerBadgeHeight = 18;
  static const double playerChevronSize = 12;

  static const double slotBorderMinimum = 2;
  static const double slotBorderRatio = 0.055;
  static const double disabledSlotOpacity = 0.45;
  static const double slotShadowOffsetMinimum = 1.5;
  static const double slotShadowOffsetRatio = 0.045;
  static const double destroyedMarkerMinimumSize = 8;
  static const double destroyedMarkerRatio = 0.20;
  static const double slotIndexBadgeMinimumSize = 15;
  static const double slotIndexBadgeRatio = 0.33;
  static const double slotIndexBorderMinimum = 1.2;
  static const double slotIndexBorderRatio = 0.032;
  static const double slotIndexFontMinimum = 7.5;
  static const double slotIndexFontRatio = 0.19;
  static const double destroyedMarkerBorderMinimum = 1.2;
  static const double destroyedMarkerBorderRatio = 0.035;
  static const double targetRingStrokeMinimum = 2.4;
  static const double targetRingStrokeRatio = 0.055;
  static const double targetRingGap = 1.5;
  static const double emptySlotIconRatio = 0.34;
  static const double spawnedSoldierScale = 1.1;
  static const double trainedSoldierScale = 1.1;
  static const double armedSoldierScale = 1.12;
  static const double strikeSoldierScale = 1.12;
  static const double graveSoldierScale = 1.5;

  static double slotBorderWidth(double slotSize) {
    return _atLeast(slotSize * slotBorderRatio, slotBorderMinimum);
  }

  static double slotShadowOffset(double slotSize) {
    return _atLeast(slotSize * slotShadowOffsetRatio, slotShadowOffsetMinimum);
  }

  static double destroyedMarkerSize(double slotSize) {
    return _atLeast(slotSize * destroyedMarkerRatio, destroyedMarkerMinimumSize);
  }

  static double slotIndexBadgeSize(double slotSize) {
    return _atLeast(slotSize * slotIndexBadgeRatio, slotIndexBadgeMinimumSize);
  }

  static double slotIndexBorderWidth(double slotSize) {
    return _atLeast(slotSize * slotIndexBorderRatio, slotIndexBorderMinimum);
  }

  static double slotIndexFontSize(double slotSize) {
    return _atLeast(slotSize * slotIndexFontRatio, slotIndexFontMinimum);
  }

  static double destroyedMarkerBorderWidth(double slotSize) {
    return _atLeast(
      slotSize * destroyedMarkerBorderRatio,
      destroyedMarkerBorderMinimum,
    );
  }

  static double targetRingStrokeWidth(double slotSize) {
    return _atLeast(slotSize * targetRingStrokeRatio, targetRingStrokeMinimum);
  }

  static double targetRingInset(double strokeWidth) {
    return targetRingGap + strokeWidth;
  }

  static double _atLeast(double value, double minimum) {
    return value < minimum ? minimum : value;
  }
}
