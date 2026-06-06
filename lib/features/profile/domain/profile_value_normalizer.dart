/// Normalizes saved draft values to match current schema option strings.
abstract final class ProfileValueNormalizer {
  static List<String> canonicalizeWeekendVibes({
    required List<String> saved,
    required List<String> options,
  }) {
    if (saved.isEmpty || options.isEmpty) return saved;
    return [
      for (final item in saved) matchSelectOption(item, options) ?? item,
    ];
  }

  /// Maps a saved label to the full schema option when prefixes differ.
  static String? matchSelectOption(String saved, List<String> options) {
    if (options.contains(saved)) return saved;

    final savedShort = saved.split('—').first.trim();
    for (final option in options) {
      if (option.startsWith(savedShort) || saved.startsWith(option)) {
        return option;
      }
    }
    return null;
  }
}
