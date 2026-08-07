import 'package:flutter/material.dart';

import 'glass/glass_section.dart';

import 'models/create_type.dart';

import 'widgets/ai_banner.dart';
import 'widgets/ai_generate_card.dart';
import 'widgets/create_header.dart';
import 'widgets/create_type_card.dart';
import 'widgets/hero_object_card.dart';
import 'widgets/quick_create_bar.dart';
import 'widgets/recent_projects.dart';
import 'widgets/section_title.dart';
import 'widgets/trending_templates.dart';

class CreateHub extends StatelessWidget {
  const CreateHub({
    super.key,
  });

  static const EdgeInsets _pagePadding =
  EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff090B14),

      body: Stack(
        children: [
          const _Background(),

          SafeArea(
            child: LayoutBuilder(
              builder: (_, constraints) {
                final width = constraints.maxWidth;

                final isDesktop = width >= 1300;
                final isTablet = width >= 760;

                final maxWidth = isDesktop
                    ? 1320.0
                    : isTablet
                    ? 940.0
                    : double.infinity;

                return Align(
                  alignment: Alignment.topCenter,

                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                    ),

                    child: SingleChildScrollView(
                      physics:
                      const BouncingScrollPhysics(),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          const CreateHeader(
                            userName: "Abdelrahman",
                          ),

                          const SizedBox(height: 28),

                          const _HeroSection(),

                          const SizedBox(height: 34),

                          const _QuickCreateSection(),

                          const SizedBox(height: 34),

                          const _AISection(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return HeroObjectCard(
      title: "Cyber City",

      subtitle:
      "Continue building your futuristic AR experience.",

      progress: .74,

      status: "Draft",

      lastEdited: "2 hours ago",

      fileSize: "126 MB",

      objects: 42,

      creator: "You",

      likes: 284,

      views: 1823,

      collaborators: 4,

      featured: true,

      onContinue: () {},

      onPreview: () {},

      onDelete: () {},
    );
  }
}

class _QuickCreateSection extends StatelessWidget {
  const _QuickCreateSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionTitle(
          title: "Quick Create",

          subtitle:
          "Start creating instantly using powerful shortcuts.",
        ),

        QuickCreateBar(
          items: [
            QuickCreateItem(
              title: "Camera",

              subtitle: "Live AR",

              hero: true,

              badge: "NEW",

              icon: Icons.camera_alt_rounded,
            ),

            QuickCreateItem(
              title: "AI",

              subtitle: "Generate",

              badge: "HOT",

              icon: Icons.auto_awesome,
            ),

            QuickCreateItem(
              title: "Template",

              subtitle: "Ready",

              icon: Icons.dashboard_customize,
            ),

            QuickCreateItem(
              title: "Portal",

              subtitle: "Reality",

              icon: Icons.travel_explore,
            ),

            QuickCreateItem(
              title: "Import",

              subtitle: "GLB",

              icon: Icons.file_upload_outlined,
            ),

            QuickCreateItem(
              title: "World",

              subtitle: "Global",

              icon: Icons.public,
            ),
          ],
        ),
      ],
    );
  }
}

class _AISection extends StatelessWidget {
  const _AISection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassSection(
          title: "AI Generator",

          subtitle:
          "Generate complete AR experiences using MetaZone AI.",

          child: AIGenerateCard(
            onGenerate: () {},
          ),
        ),

        const SizedBox(height: 26),

        const Padding(
          padding: CreateHubLayout.pagePadding,

          child: AIBanner(
            models: "18 Models",

            generations: "42K+",

            speed: "<4 sec",

            activeUsers: "5.3K",

            aiVersion: "Meta AI V2",

            online: true,
          ),
        ),
      ],
    );
  }
}

class CreateHubLayout {
  static const pagePadding =
  EdgeInsets.symmetric(horizontal: 20);

  static const sectionSpacing = 36.0;

  static const largeSpacing = 44.0;

  static const radius = 28.0;
}
class _CreateTypesSection extends StatelessWidget {
  const _CreateTypesSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final crossAxisCount = width >= 1200
        ? 3
        : width >= 700
        ? 2
        : 2;

    final types = <CreateType>[
      CreateType(
        id: "world",
        title: "AR World",
        subtitle: "Large immersive experiences",
        icon: Icons.public,
        variant: CreateTypeVariant.scene,
        recommended: true,
        featureCount: "24 Components",
      ),

      CreateType(
        id: "object",
        title: "3D Object",
        subtitle: "Interactive models",
        icon: Icons.view_in_ar,
        featureCount: "18 Assets",
      ),

      CreateType(
        id: "portal",
        title: "Portal",
        subtitle: "Teleport users",
        icon: Icons.travel_explore,
        variant: CreateTypeVariant.portal,
        featureCount: "12 Templates",
      ),

      CreateType(
        id: "place",
        title: "AR Place",
        subtitle: "Location based",
        icon: Icons.place,
        featureCount: "GPS Ready",
      ),

      CreateType(
        id: "effect",
        title: "Effects",
        subtitle: "Particles & FX",
        icon: Icons.auto_fix_high,
        featureCount: "70 Effects",
      ),

      CreateType(
        id: "template",
        title: "Template",
        subtitle: "Ready to use",
        icon: Icons.dashboard_customize,
        featureCount: "300+",
      ),
    ];

    return Column(
      children: [
        const SectionTitle(
          title: "Choose Creation Type",
          subtitle:
          "Everything you can build inside MetaZone.",
        ),

        Padding(
          padding: CreateHubLayout.pagePadding,

          child: GridView.builder(
            shrinkWrap: true,

            physics:
            const NeverScrollableScrollPhysics(),

            itemCount: types.length,

            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,

              crossAxisSpacing: 18,

              mainAxisSpacing: 18,

              childAspectRatio:
              crossAxisCount == 3
                  ? 1.15
                  : .90,
            ),

            itemBuilder: (_, index) {
              final item = types[index];

              return CreateTypeCard(
                title: item.title,

                subtitle: item.subtitle,

                icon: item.icon,

                variant: item.variant,

                recommended:
                item.recommended,

                featureCount:
                item.featureCount,

                accentColor:
                item.accentColor,

                selected: index == 0,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentProjectsSection extends StatelessWidget {
  const _RecentProjectsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionTitle(
          title: "Recent Projects",

          subtitle:
          "Continue from where you stopped.",
        ),

        RecentProjects(
          projects: const [
            RecentProjectItem(
              title: "Cyber City",

              lastEdited: "2 hours ago",

              progress: .74,

              creator: "You",

              objects: 42,

              collaborators: 4,

              color: Color(0xff5B8CFF),

              favorite: true,
            ),

            RecentProjectItem(
              title: "Virtual Museum",

              lastEdited: "Yesterday",

              progress: .53,

              creator: "You",

              objects: 19,

              collaborators: 2,

              color: Color(0xff8D67FF),
            ),

            RecentProjectItem(
              title: "Magic Portal",

              lastEdited: "3 days ago",

              progress: .91,

              creator: "You",

              objects: 66,

              collaborators: 7,

              color: Color(0xff22D39C),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrendingTemplatesSection
    extends StatelessWidget {
  const _TrendingTemplatesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionTitle(
          title: "Trending Templates",

          subtitle:
          "Community favorites this week.",
        ),

        TrendingTemplates(
          templates: const [
            TrendingTemplateItem(
              title: "Neo Tokyo",

              category: "Environment",

              creator: "Meta Creator",

              rating: 4.9,

              downloads: 18200,

              likes: 5400,

              usedBy: 9300,

              trending: true,

              aiReady: true,

              featured: true,

              premium: true,
            ),

            TrendingTemplateItem(
              title: "Fantasy Forest",

              category: "World",

              creator: "Luna",

              rating: 4.8,

              downloads: 12100,

              likes: 3100,

              usedBy: 7400,

              color: Color(0xff24D39C),

              trending: true,
            ),

            TrendingTemplateItem(
              title: "Sci-Fi Portal",

              category: "Portal",

              creator: "Meta Labs",

              rating: 4.7,

              downloads: 9600,

              likes: 2600,

              usedBy: 5800,

              color: Color(0xff845CFF),

              aiReady: true,
            ),
          ],
        ),
      ],
    );
  }
}
class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff060811),
            Color(0xff0B1220),
            Color(0xff0F172A),
            Color(0xff090B14),
          ],
          stops: [
            .0,
            .35,
            .72,
            1,
          ],
        ),
      ),

      child: Stack(
        children: [
          _glow(
            top: -220,
            right: -140,
            size: 420,
            color: const Color(0xff5B8CFF),
            opacity: .14,
          ),

          _glow(
            top: 220,
            left: -180,
            size: 360,
            color: const Color(0xff845CFF),
            opacity: .10,
          ),

          _glow(
            bottom: -160,
            right: -100,
            size: 340,
            color: const Color(0xff22D39C),
            opacity: .08,
          ),

          IgnorePointer(
            child: CustomPaint(
              painter: _NoisePainter(),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(
            alpha: opacity,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(
                alpha: opacity,
              ),
              blurRadius: 180,
              spreadRadius: 55,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(
        alpha: .015,
      );

    const gap = 26.0;

    for (double x = 0; x < size.width; x += gap) {
      for (double y = 0; y < size.height; y += gap) {
        canvas.drawCircle(
          Offset(x, y),
          .7,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}

class CreateHubSpacing {
  static const xs = 8.0;

  static const sm = 12.0;

  static const md = 20.0;

  static const lg = 28.0;

  static const xl = 40.0;

  static const xxl = 56.0;
}

class CreateHubRadius {
  static const small =
  BorderRadius.all(
    Radius.circular(18),
  );

  static const medium =
  BorderRadius.all(
    Radius.circular(24),
  );

  static const large =
  BorderRadius.all(
    Radius.circular(32),
  );
}

extension CreateHubContext
on BuildContext {
  bool get isMobile =>
      MediaQuery.of(this).size.width < 700;

  bool get isTablet =>
      MediaQuery.of(this).size.width >= 700 &&
          MediaQuery.of(this).size.width < 1200;

  bool get isDesktop =>
      MediaQuery.of(this).size.width >= 1200;

  EdgeInsets get pagePadding =>
      const EdgeInsets.symmetric(
        horizontal: 20,
      );

  double get contentWidth {
    final width =
        MediaQuery.of(this).size.width;

    if (width >= 1300) {
      return 1320;
    }

    if (width >= 760) {
      return 940;
    }

    return width;
  }
}