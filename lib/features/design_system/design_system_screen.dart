import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

/// Live gallery of all design-system components from design.html.
class DesignSystemScreen extends StatefulWidget {
  const DesignSystemScreen({super.key});

  @override
  State<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends State<DesignSystemScreen> {
  VcNavTab _navTab = VcNavTab.home;
  String? _selectedCity = 'Bangalore';
  String? _selectedFaith = 'Hindu';
  bool _showMatchOverlay = false;
  bool _showChecking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: VcStatusBar()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('The Vetted', style: AppTypography.display()),
                      Text('Club', style: AppTypography.display()),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Design Language v1.0 — component gallery',
                        style: AppTypography.supporting(),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _section('Colour swatches', _colorSwatches()),
                      _section('Typography', _typography()),
                      _section('Buttons', _buttons()),
                      _section('Cards', _cards()),
                      _section('Chips & badges', _chipsAndBadges()),
                      _section('Selection pills', _selectionPills()),
                      _section('Form inputs', _inputs()),
                      _section('Progress & XP', _progress()),
                      _section('Screen header', _screenHeader()),
                      _section('Profile card', _profileCard()),
                      _section('Overlays', _overlays()),
                      _section('All done', _allDone()),
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showMatchOverlay)
            VcMatchOverlay(
              otherName: 'Priya',
              otherInitial: 'P',
              yourInitial: 'Y',
              onSayHi: () => setState(() => _showMatchOverlay = false),
            ),
        ],
      ),
      bottomNavigationBar: VcBottomNav(
        current: _navTab,
        hasMatchNotification: true,
        onChanged: (tab) => setState(() => _navTab = tab),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppTypography.eyebrow()),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _colorSwatches() {
    const accents = [
      (AppColors.violet, 'Violet'),
      (AppColors.amber, 'Amber'),
      (AppColors.coral, 'Coral'),
      (AppColors.mint, 'Mint'),
    ];
    return Column(
      children: [
        ClipRRect(
          borderRadius: AppRadius.r12,
          child: Row(
            children: [
              for (final (color, name) in accents)
                Expanded(
                  child: Container(
                    height: 72,
                    color: color,
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      name,
                      style: AppTypography.chip(
                        color: color == AppColors.amber
                            ? AppColors.onAmber
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadius.r10,
          child: Row(
            children: [
              AppColors.bg,
              AppColors.s1,
              AppColors.s2,
              AppColors.s3,
              AppColors.s4,
              AppColors.border,
            ]
                .map(
                  (c) => Expanded(
                    child: Container(height: 40, color: c),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _typography() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("You're in.", style: AppTypography.display()),
        const SizedBox(height: AppSpacing.sm),
        Text("It's mutual.", style: AppTypography.headline()),
        const SizedBox(height: AppSpacing.sm),
        Text('Priya M., 25', style: AppTypography.title()),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Good filter coffee at 7am and someone who actually finishes the books they start.',
          style: AppTypography.body(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Product Designer · Flipkart · Bangalore',
          style: AppTypography.supporting(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Daily 5 · Ghar wali baat', style: AppTypography.eyebrow()),
      ],
    );
  }

  Widget _buttons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VcButton(
          label: 'Start membership →',
          onTap: () {},
          expanded: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        VcButton(
          label: "I'm interested →",
          variant: VcButtonVariant.coral,
          onTap: () {},
          expanded: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        VcButton(
          label: 'Begin membership',
          variant: VcButtonVariant.amber,
          onTap: () {},
          expanded: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: VcButton.ghost(
                label: 'Maybe later',
                onTap: () {},
                expanded: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: VcButton.muted(
                label: 'Pass',
                onTap: () {},
                expanded: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        VcActionButtonRow(
          onPass: () {},
          onInterested: () => setState(() => _showMatchOverlay = true),
        ),
      ],
    );
  }

  Widget _cards() {
    return Column(
      children: [
        VcSoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The way to my heart is...',
                style: AppTypography.title().copyWith(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Good filter coffee at 7am and someone who actually finishes the books they start.',
                style: AppTypography.supporting(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
                  Text('14% complete',
                      style: AppTypography.title().copyWith(fontSize: 13)),
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
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (final accent in AccentColor.values)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: accent != AccentColor.mint ? AppSpacing.xs : 0,
                  ),
                  child: VcNeoPopCard(
                    accent: accent,
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      accent.name,
                      style: AppTypography.labelCaps(color: accent.main),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _chipsAndBadges() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            VcChip(
                label: 'Member active',
                variant: VcChipVariant.violet,
                showDot: true),
            VcChip(
                label: 'Identity verified',
                variant: VcChipVariant.mint,
                showDot: true),
            VcChip(label: 'Save 37%', variant: VcChipVariant.amber),
            VcChip(label: 'Matched', variant: VcChipVariant.coral),
            VcChip(label: 'IIM Bangalore', variant: VcChipVariant.muted),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            VcTrustBadge(
                label: 'Highly Trusted', variant: VcTrustBadgeVariant.mint),
            VcTrustBadge(label: 'Trusted', variant: VcTrustBadgeVariant.violet),
            VcTrustBadge(label: 'Elite', variant: VcTrustBadgeVariant.amber),
          ],
        ),
      ],
    );
  }

  Widget _selectionPills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VcSelectionPillGroup(
          options: const ['Bangalore', 'Mumbai', 'Delhi'],
          selected: _selectedCity,
          onChanged: (v) => setState(() => _selectedCity = v),
        ),
        const SizedBox(height: AppSpacing.md),
        VcSelectionPillGroup(
          options: const ['Hindu', 'Muslim', 'Sikh', 'Jain'],
          selected: _selectedFaith,
          variant: VcSelectionPillVariant.amber,
          onChanged: (v) => setState(() => _selectedFaith = v),
        ),
      ],
    );
  }

  Widget _inputs() {
    return const Column(
      children: [
        VcTextInput(placeholder: 'Company / Organisation'),
        SizedBox(height: AppSpacing.sm),
        VcPhoneInput(),
        SizedBox(height: AppSpacing.sm),
        VcOtpInputRow(),
        SizedBox(height: AppSpacing.sm),
        VcTextInput.prompt(
          label: 'The way to my heart is...',
        ),
      ],
    );
  }

  Widget _progress() {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.s2,
            borderRadius: AppRadius.r10,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: VcXpBar(
              label: 'Biodata',
              progress: 0.38,
              showPercentage: true,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.s2,
            borderRadius: AppRadius.r10,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: VcProgressPips(
              title: 'Ghar wali baat',
              total: 5,
              currentIndex: 2,
              showPercentage: true,
              progress: 0.38,
            ),
          ),
        ),
      ],
    );
  }

  Widget _screenHeader() {
    return const VcScreenHeader(
      eyebrow: 'Daily 5',
      title: '2 of 5',
      trustLabel: 'Highly Trusted',
      trustVariant: VcTrustBadgeVariant.violet,
      pipCurrent: 1,
      xpProgress: 0.4,
    );
  }

  Widget _profileCard() {
    return const VcProfileCard(
      name: 'Priya M.',
      age: 25,
      subtitle: 'Product Designer · Flipkart · Bangalore',
      prompts: [
        (
          question: 'The way to my heart is...',
          answer:
              'Good filter coffee at 7am and someone who actually finishes the books they start.',
        ),
      ],
      tags: ['Vegetarian', 'IIM Bangalore'],
    );
  }

  Widget _overlays() {
    return Column(
      children: [
        if (_showChecking)
          const VcCheckingOverlay(
              message: 'Checking if Priya is still looking...')
        else
          VcButton.ghost(
            label: 'Show checking overlay',
            onTap: () => setState(() => _showChecking = true),
            expanded: true,
          ),
        const SizedBox(height: AppSpacing.sm),
        VcButton(
          label: 'Show match overlay',
          variant: VcButtonVariant.coral,
          onTap: () => setState(() => _showMatchOverlay = true),
          expanded: true,
        ),
      ],
    );
  }

  Widget _allDone() {
    return SizedBox(
      height: 280,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.s1,
          borderRadius: AppRadius.r12,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: const VcAllDoneScreen(
          countdownLabel: 'Next batch in 14h 22m',
        ),
      ),
    );
  }
}
