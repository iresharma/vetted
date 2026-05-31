import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetted_club_mobile/app.dart';
import 'package:vetted_club_mobile/firebase_options.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
  });

  testWidgets('Unauthenticated users see onboarding splash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const VettedClubApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1100));

    expect(find.text('The Vetted Club'), findsOneWidget);
    expect(find.text('MEMBERS ONLY'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1600));
  });
}
