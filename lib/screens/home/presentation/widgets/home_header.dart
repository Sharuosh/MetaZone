import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.locationName,
    this.backgroundAsset,
    this.backgroundUrl,
    this.temperature,
    this.weatherLabel,
    this.weatherIcon,
    this.onNotificationsTap,
    this.onProfileTap,
    this.onLocationTap,
    super.key,
  });

  final String locationName;

  final String? backgroundAsset;
  final String? backgroundUrl;

  final String? temperature;
  final String? weatherLabel;
  final IconData? weatherIcon;

  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLocationTap;

  // Governorate images are 1536x768 (2:1).
  static const double headerHeight = 205;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      width: double.infinity,
      height: headerHeight,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ================================================================
            // GOVERNORATE BACKGROUND
            // ================================================================

            _buildBackground(),

            // ================================================================
            // TOP READABILITY GRADIENT
            // ================================================================

            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 95,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x90000000),
                      Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),

            // ================================================================
            // BOTTOM READABILITY GRADIENT
            // ================================================================

            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 82,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xD8000000),
                      Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),

            // ================================================================
            // HEADER CONTENT
            // ================================================================

            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                topInset + 5,
                16,
                10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),

                  const Spacer(),

                  _buildLocationWeather(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BACKGROUND
  // ==========================================================================

  Widget _buildBackground() {
    const Widget fallback = ColoredBox(
      color: Color(0xFF07101F),
    );

    // ------------------------------------------------------------------------
    // LOCAL GOVERNORATE IMAGE
    // ------------------------------------------------------------------------

    if (backgroundAsset != null &&
        backgroundAsset!.trim().isNotEmpty) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: Container(
          key: ValueKey(backgroundAsset!),
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF07101F),
          alignment: Alignment.center,
          child: Image.asset(
            backgroundAsset!,
            width: double.infinity,
            height: double.infinity,

            // Governorate images are 1536x768 = 2:1.
            // fitWidth keeps the image visible without the
            // aggressive crop caused by BoxFit.cover.
            fit: BoxFit.fitWidth,

            alignment: Alignment.center,
            errorBuilder: (_, __, ___) {
              return fallback;
            },
          ),
        ),
      );
    }

    // ------------------------------------------------------------------------
    // NETWORK BACKGROUND
    // ------------------------------------------------------------------------

    if (backgroundUrl != null &&
        backgroundUrl!.trim().isNotEmpty) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: Container(
          key: ValueKey(backgroundUrl!),
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF07101F),
          alignment: Alignment.center,
          child: Image.network(
            backgroundUrl!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fitWidth,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) {
              return fallback;
            },
          ),
        ),
      );
    }

    return fallback;
  }

  // ==========================================================================
  // TOP BAR
  // ==========================================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        // ----------------------------------------------------------------------
        // METAZONE BRAND
        // No planet/globe icon.
        // ----------------------------------------------------------------------

        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFF4F2FF),
                    Color(0xFFD9C8FF),
                    Color(0xFF8E5CFF),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: const Text(
                'MetaZone',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.9,
                  height: 1,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // ----------------------------------------------------------------------
        // NOTIFICATIONS
        // ----------------------------------------------------------------------

        _GlassCircleButton(
          icon: Icons.notifications_none_rounded,
          onTap: onNotificationsTap,
        ),

        const SizedBox(width: 7),

        // ----------------------------------------------------------------------
        // PROFILE
        // ----------------------------------------------------------------------

        _GlassCircleButton(
          icon: Icons.person_outline_rounded,
          onTap: onProfileTap,
        ),
      ],
    );
  }

  // ==========================================================================
  // LOCATION + WEATHER
  // ==========================================================================

  Widget _buildLocationWeather() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----------------------------------------------------------------------
        // AROUND YOU
        // ----------------------------------------------------------------------

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 14,
              color: Colors.white,
            ),

            const SizedBox(width: 4),

            Text(
              'Around you',
              style: TextStyle(
                color: Colors.white.withValues(
                  alpha: 0.78,
                ),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 3),

        // ----------------------------------------------------------------------
        // GOVERNORATE + WEATHER
        //
        // Both are now on the same horizontal line.
        // ----------------------------------------------------------------------

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ------------------------------------------------------------------
            // GOVERNORATE NAME
            // ------------------------------------------------------------------

            Expanded(
              child: GestureDetector(
                onTap: onLocationTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        locationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1,
                        ),
                      ),
                    ),

                    const SizedBox(width: 3),

                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ------------------------------------------------------------------
            // WEATHER
            // ------------------------------------------------------------------

            _WeatherCard(
              temperature: temperature ?? '--',
              label: weatherLabel ?? 'Weather',
              icon: weatherIcon ?? Icons.cloud_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// GLASS CIRCLE BUTTON
// ============================================================================

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(
              alpha: 0.13,
            ),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.21,
              ),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WEATHER CARD
// ============================================================================

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.temperature,
    required this.label,
    required this.icon,
  });

  final String temperature;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 102,
      height: 46,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.24,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.14,
          ),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Weather icon:
          // intentionally reduced for a lighter visual weight.
          Icon(
            icon,
            color: Colors.white,
            size: 17,
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temperature,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.65,
                    ),
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    height: 1,
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