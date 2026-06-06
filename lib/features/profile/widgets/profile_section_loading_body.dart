import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

/// Shown while a profile section merges saved draft data into form state.
class ProfileSectionLoadingBody extends StatelessWidget {
  const ProfileSectionLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: VcLoadingIndicator(),
      ),
    );
  }
}
