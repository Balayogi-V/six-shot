enum Faction {
  red('Red', 'red'),
  green('Green', 'green'),
  yellow('Yellow', 'yellow'),
  blue('Blue', 'blue'),
  purple('Purple', 'purple'),
  orange('Orange', 'orange');

  const Faction(this.label, this.assetKey);

  final String label;
  final String assetKey;

  String get shortLabel => label.toUpperCase();
}
