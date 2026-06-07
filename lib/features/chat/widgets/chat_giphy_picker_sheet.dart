import 'dart:async';

import 'package:flutter/material.dart';
import 'package:giphy_flutter_sdk/dto/giphy_content_request.dart';
import 'package:giphy_flutter_sdk/dto/giphy_media.dart';
import 'package:giphy_flutter_sdk/dto/giphy_media_type.dart';
import 'package:giphy_flutter_sdk/dto/giphy_rating.dart';
import 'package:giphy_flutter_sdk/dto/giphy_theme.dart';
import 'package:giphy_flutter_sdk/giphy_grid_view.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/config/giphy_bootstrap.dart';
import 'package:vetted_club_mobile/core/config/giphy_config.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

class ChatGiphyPickerSheet extends StatefulWidget {
  const ChatGiphyPickerSheet({
    super.key,
    required this.onMediaSelect,
  });

  final ValueChanged<GiphyMedia> onMediaSelect;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<GiphyMedia> onMediaSelect,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChatGiphyPickerSheet(onMediaSelect: onMediaSelect),
    );
  }

  @override
  State<ChatGiphyPickerSheet> createState() => _ChatGiphyPickerSheetState();
}

class _ChatGiphyPickerSheetState extends State<ChatGiphyPickerSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _focused = false;

  static const _rating = GiphyRating.pg;

  GiphyContentRequest get _contentRequest {
    final query = _query.trim();
    if (query.isEmpty) {
      return GiphyContentRequest.trendingGifs(rating: _rating);
    }
    return GiphyContentRequest.search(
      mediaType: GiphyMediaType.gif,
      rating: _rating,
      searchQuery: query,
    );
  }

  GiphyTheme get _theme => GiphyTheme.fromPreset(
        preset: GiphyThemePreset.dark,
        backgroundColor: AppColors.bg,
        defaultTextColor: AppColors.textPrimary,
        searchBarBackgroundColor: AppColors.s1,
        searchPlaceholderTextColor: AppColors.textMuted,
        searchTextColor: AppColors.textPrimary,
      );

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _query = _searchController.text);
    });
  }

  void _handleMediaSelect(GiphyMedia media) {
    Navigator.of(context).pop();
    widget.onMediaSelect(media);
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.72;

    return SafeArea(
      child: SizedBox(
        height: sheetHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
              ),
              child: Text(
                'Send a GIF',
                style: AppTypography.compactTitle(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.s1,
                  borderRadius: AppRadius.r12,
                  border: Border.all(
                    color: _focused
                        ? AppColors.coral.withValues(alpha: 0.45)
                        : AppColors.border,
                    width: 0.5,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onTap: () => setState(() => _focused = true),
                  onTapOutside: (_) => setState(() => _focused = false),
                  style: AppTypography.body(),
                  cursorColor: AppColors.coral,
                  decoration: InputDecoration(
                    hintText: 'Search GIPHY',
                    hintStyle: AppTypography.body(color: AppColors.textMuted),
                    prefixIcon: Icon(
                      PhosphorIconsRegular.magnifyingGlass,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 2,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _buildGrid()),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.xs,
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
              ),
              child: Text(
                'Powered by GIPHY',
                textAlign: TextAlign.center,
                style: AppTypography.statCaption(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    if (!GiphyConfig.isAvailable || !GiphyBootstrap.isConfigured) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Text(
            'GIF search is not configured. Add GIPHY_ANDROID_API_KEY and '
            'GIPHY_IOS_API_KEY to your .env file.',
            textAlign: TextAlign.center,
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return GiphyGridView(
      key: ValueKey('giphy-${_query.trim()}'),
      content: _contentRequest,
      theme: _theme,
      cellPadding: 4,
      spanCount: 2,
      onMediaSelect: _handleMediaSelect,
    );
  }
}
