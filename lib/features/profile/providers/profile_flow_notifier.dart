import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ProfileFlowStep {
  intro,
  youAndPhotos,
  interests,
  career,
  cultural,
  complete,
}

final profileFlowProvider =
    NotifierProvider<ProfileFlowNotifier, ProfileFlowStep>(
  ProfileFlowNotifier.new,
);

class ProfileFlowNotifier extends Notifier<ProfileFlowStep> {
  @override
  ProfileFlowStep build() => ProfileFlowStep.intro;

  void goTo(ProfileFlowStep step) => state = step;

  void reset() => state = ProfileFlowStep.intro;

  void nextFrom(ProfileFlowStep current) {
    state = switch (current) {
      ProfileFlowStep.intro => ProfileFlowStep.youAndPhotos,
      ProfileFlowStep.youAndPhotos => ProfileFlowStep.interests,
      ProfileFlowStep.interests => ProfileFlowStep.career,
      ProfileFlowStep.career => ProfileFlowStep.cultural,
      ProfileFlowStep.cultural => ProfileFlowStep.complete,
      ProfileFlowStep.complete => ProfileFlowStep.complete,
    };
  }

  int get stepIndex => switch (state) {
        ProfileFlowStep.intro => -1,
        ProfileFlowStep.youAndPhotos => 0,
        ProfileFlowStep.interests => 1,
        ProfileFlowStep.career => 2,
        ProfileFlowStep.cultural => 3,
        ProfileFlowStep.complete => 4,
      };
}
