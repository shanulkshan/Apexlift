extension TitleCase on String {
  /// "barbell bench press" -> "Barbell Bench Press"
  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
