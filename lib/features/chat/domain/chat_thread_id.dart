/// Deterministic 1:1 thread id — same two users always resolve to the same doc.
String buildThreadId(String uidA, String uidB) {
  final ids = [uidA, uidB]..sort();
  return ids.join('_');
}
