import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import 'ask_screen.dart';
import 'compare_screen.dart';
import 'guide_screen.dart';
import 'share_screen.dart';
import 'vision_screen.dart';

/// MetaZone Sense V1
///
/// Independent entry point for MetaZone's five Sense capabilities:
/// Vision, Ask, Compare, Guide and Share.
///
/// This file owns the Sense hub presentation/navigation only.
/// Real AI, spatial understanding and networking remain integration points
/// inside the individual feature modules.
class SenseScreen extends StatelessWidget {
  const SenseScreen({super.key});

  static const List<_SenseFeature> _features = [
    _SenseFeature(
      title: 'Vision',
      subtitle: 'See & understand',
      description: 'Recognize what is around you and turn the scene into useful context.',
      icon: Icons.visibility_rounded,
      tag: 'SEE',
      accent: Color(0xFF67B7FF),
    ),
    _SenseFeature(
      title: 'Ask',
      subtitle: 'Talk to what you see',
      description: 'Ask questions about an object, scene or detail in front of you.',
      icon: Icons.chat_bubble_rounded,
      tag: 'ASK',
      accent: Color(0xFF57DFC0),
    ),
    _SenseFeature(
      title: 'Compare',
      subtitle: 'Compare real things',
      description: 'Select two or more things and compare the properties that matter.',
      icon: Icons.compare_arrows_rounded,
      tag: 'COMPARE',
      accent: Color(0xFFFFB764),
    ),
    _SenseFeature(
      title: 'Guide',
      subtitle: 'Step-by-step help',
      description: 'Follow contextual AR guidance while you work through a task.',
      icon: Icons.navigation_rounded,
      tag: 'GUIDE',
      accent: Color(0xFFB986FF),
    ),
    _SenseFeature(
      title: 'Share',
      subtitle: 'Share what you see',
      description: 'Bring another person into your view to help, explain or collaborate.',
      icon: Icons.people_alt_rounded,
      tag: 'SHARE',
      accent: Color(0xFFFF72AB),
    ),
  ];

  void _openFeature(BuildContext context, _SenseFeature feature) {
    final Widget screen;

    switch (feature.title) {
      case 'Vision':
        screen = const VisionScreen();
        break;
      case 'Ask':
        screen = const AskScreen();
        break;
      case 'Compare':
        screen = const CompareScreen();
        break;
      case 'Guide':
        screen = const GuideScreen();
        break;
      case 'Share':
        screen = const ShareScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: _SenseBackground()),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                  sliver: SliverToBoxAdapter(
                    child: _Header(
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                  sliver: SliverToBoxAdapter(
                    child: _HeroCard(
                      onStart: () => _openFeature(context, _features.first),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text('Sense tools', style: AppTextStyles.title(size: 16)),
                        const Spacer(),
                        Text(
                          '5 capabilities',
                          style: AppTextStyles.caption(
                            size: 11,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  sliver: SliverList.separated(
                    itemCount: _features.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final feature = _features[index];
                      return _FeatureCard(
                        feature: feature,
                        onTap: () => _openFeature(context, feature),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 26)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                  sliver: SliverToBoxAdapter(
                    child: _BottomNote(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SenseFeature {
  const _SenseFeature({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.tag,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String tag;
  final Color accent;
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GlassButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sense', style: AppTextStyles.heading(size: 23)),
              const SizedBox(height: 2),
              Text(
                'See • Understand • Interact',
                style: AppTextStyles.caption(
                  size: 11,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(.82),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(.24)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(.55),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'READY',
                style: AppTextStyles.caption(size: 10).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withOpacity(.97),
            AppColors.card.withOpacity(.94),
          ],
        ),
        border: Border.all(color: AppColors.primary.withOpacity(.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.10),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.primary.withOpacity(.18)),
                      ),
                      child: Text(
                        'META INTELLIGENCE',
                        style: AppTextStyles.caption(size: 9).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Let MetaZone\nunderstand what you see.',
                      style: AppTextStyles.heading(size: 23).copyWith(
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'One place for seeing, asking, comparing, guiding and sharing around you.',
                      style: AppTextStyles.caption(size: 12).copyWith(
                        color: AppColors.textSoft,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const _SenseOrb(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onStart,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: BorderSide(color: AppColors.primary.withOpacity(.38)),
                    foregroundColor: AppColors.text,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_rounded, size: 19),
                  label: const Text('Start with Vision'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SenseOrb extends StatelessWidget {
  const _SenseOrb();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(.05),
              border: Border.all(color: AppColors.primary.withOpacity(.16)),
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.neonGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.28),
                  blurRadius: 24,
                ),
              ],
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: Colors.black,
              size: 34,
            ),
          ),
          Positioned(
            top: 5,
            right: 7,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.92),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.feature,
    required this.onTap,
  });

  final _SenseFeature feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(.84),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(.46)),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      feature.accent.withOpacity(.88),
                      feature.accent.withOpacity(.50),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: feature.accent.withOpacity(.14),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Icon(feature.icon, color: Colors.black, size: 27),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(feature.title, style: AppTextStyles.title(size: 15)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: feature.accent.withOpacity(.10),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: feature.accent.withOpacity(.16)),
                          ),
                          child: Text(
                            feature.tag,
                            style: AppTextStyles.caption(size: 8).copyWith(
                              color: feature.accent,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .7,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      feature.subtitle,
                      style: AppTextStyles.caption(size: 11, color: feature.accent),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      feature.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(size: 10).copyWith(
                        color: AppColors.textSoft,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: AppColors.textSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.72),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border.withOpacity(.38)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sense is an independent MetaZone feature. Each tool will connect to its real AI, AR or networking service as we implement it.',
              style: AppTextStyles.caption(size: 10).copyWith(
                color: AppColors.textSoft,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(.80),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border.withOpacity(.45)),
          ),
          child: Icon(icon, size: 20, color: AppColors.text),
        ),
      ),
    );
  }
}

class _SenseBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SenseBackgroundPainter(),
      ),
    );
  }
}

class _SenseBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width * .82, size.height * .12);

    for (int i = 0; i < 5; i++) {
      final radius = 60.0 + (i * 34);
      paint.color = Colors.white.withOpacity(.025 - (i * .003));
      canvas.drawCircle(center, radius, paint);
    }

    final path = Path();
    path.moveTo(0, size.height * .78);
    path.quadraticBezierTo(
      size.width * .35,
      size.height * .70,
      size.width * .62,
      size.height * .80,
    );
    path.quadraticBezierTo(
      size.width * .82,
      size.height * .88,
      size.width,
      size.height * .74,
    );

    paint.color = Colors.white.withOpacity(.018);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
