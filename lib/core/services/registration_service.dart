/// Active membership payment record for a user (Razorpay payment / order ids).
class MembershipSubscription {
  const MembershipSubscription({
    required this.subscriptionId,
    required this.orderId,
    required this.amountInr,
    required this.frequencyUnit,
    required this.startedAt,
  });

  final String subscriptionId;
  final String orderId;
  final String amountInr;
  final String frequencyUnit;
  final DateTime startedAt;
}

/// Tracks whether a signed-in user has finished the in-app registration flow.
///
/// In-memory only for now; replace with backend / local persistence when APIs land.
class RegistrationService {
  RegistrationService._();

  static final RegistrationService instance = RegistrationService._();

  final Set<String> _completedUserIds = {};
  final Map<String, MembershipSubscription> _subscriptionsByUserId = {};

  bool isComplete(String uid) => _completedUserIds.contains(uid);

  MembershipSubscription? subscriptionFor(String uid) =>
      _subscriptionsByUserId[uid];

  void saveSubscription(String uid, MembershipSubscription subscription) {
    _subscriptionsByUserId[uid] = subscription;
  }

  void markComplete(String uid) => _completedUserIds.add(uid);

  void clear(String uid) {
    _completedUserIds.remove(uid);
    _subscriptionsByUserId.remove(uid);
  }
}
