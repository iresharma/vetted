import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';

/// Premium club membership card shown on profile completion.
class VcMembershipCard extends StatefulWidget {
  const VcMembershipCard({
    super.key,
    required this.draft,
    this.memberId,
  });

  final ProfileDraft draft;
  final String? memberId;

  @override
  State<VcMembershipCard> createState() => _VcMembershipCardState();
}

class _VcMembershipCardState extends State<VcMembershipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _v => widget.draft.values;

  @override
  Widget build(BuildContext context) {
    final name = _fullName();
    final tagline = _tagline();
    final detailLines = _detailLines();
    final photoUrl = _photoUrl();

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.amber.withValues(alpha: 0.55),
              AppColors.violet.withValues(alpha: 0.45),
              AppColors.amber.withValues(alpha: 0.25),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.violet.withValues(alpha: 0.22),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: AppColors.amber.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(1.2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.s1,
                      AppColors.bg,
                      const Color(0xFF12101A),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: -30,
                top: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.amber.withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -40,
                bottom: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.violet.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VETTED CLUB',
                                style: AppTypography.labelCaps(
                                  color: AppColors.amber,
                                ).copyWith(letterSpacing: 2.4),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Founding member',
                                style: AppTypography.supporting(
                                  color: AppColors.textSecondary,
                                ).copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        _MemberPhoto(url: photoUrl, name: name),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: AppTypography.display().copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tagline.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        tagline,
                        style: AppTypography.body(color: AppColors.textSecondary)
                            .copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      height: 0.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.amber.withValues(alpha: 0.05),
                            AppColors.amber.withValues(alpha: 0.45),
                            AppColors.amber.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final line in detailLines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          line,
                          style: AppTypography.supporting(
                            color: AppColors.textPrimary,
                          ).copyWith(
                            fontSize: 11,
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.sealCheck,
                          size: 13,
                          color: AppColors.mint,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'DigiLocker verified',
                            style: AppTypography.supporting(
                              color: AppColors.textMuted,
                            ).copyWith(fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.memberId != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            widget.memberId!,
                            style: AppTypography.labelCaps(
                              color: AppColors.textMuted,
                            ).copyWith(letterSpacing: 1.2, fontSize: 9),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _CardShimmerPainter(animation: _shimmer),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fullName() => widget.draft.preferredName;

  String _tagline() {
    final parts = <String>[];
    if (widget.draft.verifiedAge != null) {
      parts.add('${widget.draft.verifiedAge}');
    }
    final city = _str('city');
    if (city != null) parts.add(city);
    final photos = _photoCount();
    if (photos > 0) parts.add('$photos photo${photos == 1 ? '' : 's'}');
    return parts.join(' · ');
  }

  List<String> _detailLines() {
    final lines = <String>[];

    final career = [
      _str('job_title'),
      _str('field_of_work'),
    ].whereType<String>().toList();
    if (career.isNotEmpty) lines.add(career.join(' · '));

    final values = [
      _str('faith'),
      _str('diet'),
    ].whereType<String>().toList();
    if (values.isNotEmpty) lines.add(values.join(' · '));

    final timeline = _str('marriage_timeline');
    if (timeline != null) lines.add('$timeline · Daily 5 unlocked');

    return lines.take(2).toList();
  }

  String? _photoUrl() {
    final urls = _list('photo_urls');
    return urls.isNotEmpty ? urls.first : null;
  }

  int _photoCount() => _list('photo_urls').length;

  String? _str(String key) {
    final raw = _v[key];
    if (raw == null) return null;
    final s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  List<String> _list(String key) {
    final raw = _v[key];
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }
}

class _CardShimmerPainter extends CustomPainter {
  _CardShimmerPainter({required Animation<double> animation})
      : _animation = animation,
        super(repaint: animation);

  final Animation<double> _animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = _animation.value;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.4 + 2.8 * t, -0.8),
        end: Alignment(-0.2 + 2.8 * t, 0.8),
        colors: [
          Colors.transparent,
          AppColors.amber.withValues(alpha: 0.04),
          Colors.white.withValues(alpha: 0.1),
          AppColors.violet.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.38, 0.5, 0.62, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _CardShimmerPainter oldDelegate) => true;
}

class _MemberPhoto extends StatelessWidget {
  const _MemberPhoto({this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    const size = 46.0;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'V';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.amber.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.amber.withValues(alpha: 0.15),
            blurRadius: 12,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initial(initial),
            )
          : _initial(initial),
    );
  }

  Widget _initial(String letter) {
    return ColoredBox(
      color: AppColors.s3,
      child: Center(
        child: Text(
          letter,
          style: AppTypography.title(color: AppColors.amber).copyWith(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
