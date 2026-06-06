/// Tracks optional manual back-navigation within a micro-flow while keeping
/// the default step derived from saved field values.
class ProfileMicroStepController {
  int? _override;

  int step({
    required int derived,
    required int min,
    required int max,
  }) {
    final step = _override ?? derived;
    if (step < min) return min;
    if (step > max) return max;
    return step;
  }

  void goBack(int current) {
    _override = current > 0 ? current - 1 : 0;
  }

  /// After moving forward manually, snap back to derived once caught up.
  void goForward(int current, int derived) {
    if (_override == null) return;
    final next = current + 1;
    if (next >= derived) {
      _override = null;
    } else {
      _override = next;
    }
  }

  void clearOverride() => _override = null;

  bool get hasOverride => _override != null;
}
