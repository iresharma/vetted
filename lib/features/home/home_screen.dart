import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/auth/sign_out.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/home/widgets/home_shell_header.dart';
import 'package:vetted_club_mobile/features/home/widgets/home_tab.dart';
import 'package:vetted_club_mobile/features/home/widgets/member_profile_tab.dart';
import 'package:vetted_club_mobile/features/daily/daily5_tab.dart';
import 'package:vetted_club_mobile/features/home/providers/member_bootstrap_provider.dart';
import 'package:vetted_club_mobile/features/values/providers/values_quiz_gate.dart';
import 'package:vetted_club_mobile/features/trust/screens/trust_report_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.user});

  final User user;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  VcNavTab _navTab = VcNavTab.home;
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;

    setState(() => _signingOut = true);

    final ok = await signOutUser(context);
    if (!ok && mounted) setState(() => _signingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(memberBootstrapProvider);

    final hideHeaderForQuiz =
        _navTab == VcNavTab.daily5 && valuesQuizPending(ref);
    final showDailyHeader = !hideHeaderForQuiz;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const VcStatusBar(),
          if (showDailyHeader)
            HomeShellHeader(tab: _navTab, user: widget.user),
          Expanded(child: _buildTabContent()),
        ],
      ),
      bottomNavigationBar: VcBottomNav(
        current: _navTab,
        onChanged: (tab) => setState(() => _navTab = tab),
      ),
    );
  }

  Widget _buildTabContent() {
    return IndexedStack(
      index: _navTab.index,
      children: [
        HomeTab(onNavigate: (tab) => setState(() => _navTab = tab)),
        const _ChatEmptyTab(),
        Daily5Tab(
          user: widget.user,
          isActive: _navTab == VcNavTab.daily5,
          onNavigate: (tab) => setState(() => _navTab = tab),
        ),
        TrustReportScreen(user: widget.user),
        MemberProfileTab(
          user: widget.user,
          signingOut: _signingOut,
          onSignOut: _signOut,
        ),
      ],
    );
  }
}

class _ChatEmptyTab extends StatelessWidget {
  const _ChatEmptyTab();

  @override
  Widget build(BuildContext context) {
    return const VcEmptyState(
      imageAsset: AppAssets.emptyMailbox,
      title: 'No conversations yet',
      message:
          'When you and someone both show interest, the conversation starts here. '
          'Keep your profile sharp, show up on Daily 5, and your next match could land any day.',
    );
  }
}
