import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/auth/sign_out.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});

  final User user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  VcNavTab _navTab = VcNavTab.home;
  bool _signingOut = false;

  String get _displayPhone {
    final phone = widget.user.phoneNumber;
    if (phone == null || phone.length < 4) return 'Verified member';
    if (phone.length <= 8) return phone;
    return '${phone.substring(0, phone.length - 6)}****${phone.substring(phone.length - 2)}';
  }

  Future<void> _signOut() async {
    if (_signingOut) return;

    setState(() => _signingOut = true);

    final ok = await signOutUser(context);
    if (!ok && mounted) setState(() => _signingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const VcStatusBar(),
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
    return switch (_navTab) {
      VcNavTab.home => _HomeTab(phone: _displayPhone),
      VcNavTab.discover => const _PlaceholderTab(
          title: 'Discover',
          subtitle: 'Your daily picks will show up here.',
        ),
      VcNavTab.matches => const _PlaceholderTab(
          title: 'Matches',
          subtitle: 'Mutual interest lives here.',
        ),
      VcNavTab.profile => _ProfileTab(
          phone: _displayPhone,
          signingOut: _signingOut,
          onSignOut: _signOut,
        ),
    };
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text("You're in.", style: AppTypography.display()),
          const SizedBox(height: AppSpacing.sm),
          Text(
            phone,
            style: AppTypography.supporting(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          VcNeoPopCard(
            accent: AccentColor.violet,
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Biodata', style: AppTypography.labelCaps()),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '14% complete',
                      style: AppTypography.title().copyWith(fontSize: 13),
                    ),
                    Text(
                      'tap to fill',
                      style: AppTypography.chip(color: AppColors.amber),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const VcXpBar(progress: 0.14, animateOnMount: true),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          VcButton(
            label: 'Start membership →',
            expanded: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.phone,
    required this.signingOut,
    required this.onSignOut,
  });

  final String phone;
  final bool signingOut;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Profile', style: AppTypography.display()),
          const SizedBox(height: AppSpacing.sm),
          Text(
            phone,
            style: AppTypography.supporting(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          VcSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account', style: AppTypography.title().copyWith(fontSize: 14)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Signed in with phone verification.',
                  style: AppTypography.supporting(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          VcButton.ghost(
            label: signingOut ? 'Signing out…' : 'Sign out',
            expanded: true,
            enabled: !signingOut,
            onTap: signingOut ? null : onSignOut,
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTypography.display()),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
