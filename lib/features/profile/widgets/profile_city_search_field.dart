import 'package:countrify/countrify.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Searchable Indian city picker backed by countrify's offline geo dataset.
class ProfileCitySearchField extends StatefulWidget {
  const ProfileCitySearchField({
    super.key,
    required this.value,
    required this.onChanged,
    this.accent = AccentColor.violet,
    this.placeholder = 'Search city in India',
    this.helperText = 'Search from thousands of cities across India',
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final AccentColor accent;
  final String placeholder;
  final String helperText;

  @override
  State<ProfileCitySearchField> createState() => _ProfileCitySearchFieldState();
}

class _ProfileCitySearchFieldState extends State<ProfileCitySearchField> {
  String? _stateName;

  @override
  void initState() {
    super.initState();
    _resolveStateName(widget.value);
  }

  @override
  void didUpdateWidget(ProfileCitySearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _resolveStateName(widget.value);
    }
  }

  Future<void> _resolveStateName(String? cityName) async {
    if (cityName == null || cityName.trim().isEmpty) {
      if (_stateName != null && mounted) setState(() => _stateName = null);
      return;
    }

    final results = await GeoRepository.instance.searchCities(
      countryIso2: 'IN',
      query: cityName.trim(),
    );
    if (!mounted) return;

    CitySearchResult? match;
    for (final result in results) {
      if (result.city.name.toLowerCase() == cityName.trim().toLowerCase()) {
        match = result;
        break;
      }
    }
    match ??= results.isNotEmpty ? results.first : null;

    if (match != null && match.state.name != _stateName) {
      setState(() => _stateName = match!.state.name);
    }
  }

  CountrifyFieldStyle _fieldStyle() {
    final radius = BorderRadius.circular(12);
    return CountrifyFieldStyle(
      fieldBorderRadius: radius,
      filled: true,
      fillColor: AppColors.s2,
      focusedFillColor: AppColors.s3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      counterText: '',
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: widget.accent.main, width: 1.5),
      ),
      hintStyle: AppTypography.body(color: AppColors.textMuted),
      selectedCountryTextStyle:
          AppTypography.body(color: AppColors.textPrimary),
      cursorColor: widget.accent.main,
      prefixIcon: Icon(
        PhosphorIconsRegular.magnifyingGlass,
        size: 18,
        color: AppColors.textSecondary,
      ),
      focusedBoxShadow: [
        BoxShadow(
          color: widget.accent.main.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  GeoPickerTheme _pickerTheme() {
    return GeoPickerTheme(
      backgroundColor: AppColors.s2,
      borderColor: AppColors.border,
      borderRadius: BorderRadius.circular(12),
      shadowColor: Colors.black.withValues(alpha: 0.35),
      elevation: 8,
      itemBackgroundColor: Colors.transparent,
      itemSelectedColor: widget.accent.dim,
      itemSelectedBorderColor: widget.accent.main,
      itemBorderRadius: BorderRadius.circular(10),
      itemContentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemNameTextStyle:
          AppTypography.body(color: AppColors.textPrimary).copyWith(
        fontSize: 14,
      ),
      itemSelectedNameTextStyle:
          AppTypography.body(color: widget.accent.main).copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      itemSubtitleTextStyle:
          AppTypography.supporting(color: AppColors.textSecondary),
      emptyStateTextStyle:
          AppTypography.body(color: AppColors.textSecondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CitySearchField(
          countryIso2: 'IN',
          initialCityName: widget.value,
          placeholder: widget.placeholder,
          emptyPlaceholder: 'No city found — try another spelling',
          style: _fieldStyle(),
          pickerTheme: _pickerTheme(),
          pickerConfig: GeoPickerConfig(
            searchDebounce: const Duration(milliseconds: 200),
            dropdownMaxHeight: keyboardOpen ? 160 : 280,
            accentInsensitiveSearch: true,
          ),
          onChanged: (result) {
            if (result == null) {
              setState(() => _stateName = null);
              widget.onChanged('');
              return;
            }
            setState(() => _stateName = result.state.name);
            widget.onChanged(result.city.name);
          },
        ),
        if (_stateName != null && (widget.value?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.mapPin,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _stateName!,
                  style: AppTypography.supporting(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            widget.helperText,
            style: AppTypography.supporting(color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}
