import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ProfileFlowMode {
  onboarding,
  edit,
}

final profileFlowModeProvider =
    NotifierProvider<ProfileFlowModeNotifier, ProfileFlowMode>(
  ProfileFlowModeNotifier.new,
);

class ProfileFlowModeNotifier extends Notifier<ProfileFlowMode> {
  @override
  ProfileFlowMode build() => ProfileFlowMode.onboarding;

  void set(ProfileFlowMode mode) => state = mode;
}
