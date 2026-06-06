/// Maps backend trust tier ids to display labels.
abstract final class TrustTierLabels {
  static String label(String? tier) => switch (tier) {
        'elite' => 'Elite',
        'highly_trusted' => 'Highly trusted',
        'trusted' => 'Trusted',
        _ => 'Trusted',
      };

  static String badgeVariant(String? tier) => tier ?? 'trusted';
}
