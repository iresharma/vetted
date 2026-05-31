import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vetted_club_mobile/core/auth/auth_gate.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

class VettedClubApp extends StatelessWidget {
  const VettedClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Vetted Club',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: AppColors.s1,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AuthGate(),
    );
  }
}
