import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class InterestCategory {
  const InterestCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.interests,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> interests;
}

/// Eight browse buckets for the interests micro-flow (maps to profile.json options).
abstract final class InterestCategories {
  static const all = [
    InterestCategory(
      id: 'create',
      label: 'Create',
      icon: PhosphorIconsRegular.palette,
      color: Color(0xFFE8706A),
      interests: [
        'Art',
        'Photography',
        'Design',
        'Fashion',
        'Film & cinema',
        'Dance',
      ],
    ),
    InterestCategory(
      id: 'sound',
      label: 'Sound & stage',
      icon: PhosphorIconsRegular.musicNotes,
      color: Color(0xFF7C6AF5),
      interests: [
        'Music',
        'Playing an instrument',
        'Theatre',
        'Stand-up comedy',
      ],
    ),
    InterestCategory(
      id: 'food',
      label: 'Food & drink',
      icon: PhosphorIconsRegular.forkKnife,
      color: Color(0xFFE8A945),
      interests: [
        'Cooking',
        'Baking',
        'Coffee',
        'Food & restaurants',
      ],
    ),
    InterestCategory(
      id: 'outdoors',
      label: 'Outdoors',
      icon: PhosphorIconsRegular.mountains,
      color: Color(0xFF4AE0A0),
      interests: [
        'Travel',
        'Hiking',
        'Trekking',
        'Camping',
        'Nature & environment',
      ],
    ),
    InterestCategory(
      id: 'move',
      label: 'Move',
      icon: PhosphorIconsRegular.personSimpleRun,
      color: Color(0xFF3498DB),
      interests: [
        'Fitness',
        'Running',
        'Cycling',
        'Yoga',
        'Sports',
      ],
    ),
    InterestCategory(
      id: 'mind',
      label: 'Mind',
      icon: PhosphorIconsRegular.bookOpen,
      color: Color(0xFF9B59B6),
      interests: [
        'Reading',
        'Writing',
        'Spirituality',
        'Meditation',
        'Politics & policy',
      ],
    ),
    InterestCategory(
      id: 'play',
      label: 'Play & tech',
      icon: PhosphorIconsRegular.gameController,
      color: Color(0xFF1ABC9C),
      interests: [
        'Gaming',
        'Anime',
        'Tech & gadgets',
        'Investing',
        'Startups & entrepreneurship',
      ],
    ),
    InterestCategory(
      id: 'connect',
      label: 'Connect',
      icon: PhosphorIconsRegular.handHeart,
      color: Color(0xFFE67E22),
      interests: [
        'Volunteering',
        'Pets',
      ],
    ),
  ];

  static InterestCategory? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
