import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_section_loading_body.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_step_header.dart';

/// Full-screen loading state while draft data hydrates into a section.
class ProfileSectionLoadingScaffold extends StatelessWidget {
  const ProfileSectionLoadingScaffold({
    super.key,
    required this.stepIndex,
  });

  final int stepIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileStepHeader(stepIndex: stepIndex),
            const Expanded(child: ProfileSectionLoadingBody()),
          ],
        ),
      ),
    );
  }
}
