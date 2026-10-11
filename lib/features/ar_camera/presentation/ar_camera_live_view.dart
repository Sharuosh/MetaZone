import 'dart:ui';

import 'package:flutter/material.dart';

import 'create_hub_overlay.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import '../widgets/camera-icon/capture_mode_panel.dart';
import '../widgets/camera-icon/camera_bottom_controls.dart';
import '../widgets/layers/layers_panel.dart';
import '../widgets/scan/scan_panel.dart';

/// MetaZone AR Camera — Explore Mode
///
/// Visual direction:
/// - Premium spatial glass
/// - Minimal / Apple-like hierarchy
/// - Meta-like spatial interaction
/// - Unity remains the AR rendering surface
class ARCameraShell extends StatefulWidget {
  const ARCameraShell({super.key});

  @override
  State<ARCameraShell> createState() => _ARCameraShellState();
}

class _ARCameraShellState extends State<ARCameraShell>
    with SingleTickerProviderStateMixin {
  bool _showCreateHub = false;
  bool _showCaptureMode = false;
  bool _showLayersPanel = false;
  bool _showScanPanel = false;
  bool _showRadar = false;
  bool _showAiGuide = false;

  int _captureMode = 0;

  late final AnimationController _reticleController;

  @override
  void initState() {
    super.initState();

    _reticleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _reticleController.dispose();
    super.dispose();
  }

  bool get _mainUiVisible =>
      !_showCaptureMode && !_showLayersPanel && !_showScanPanel;

  void _closeTransientPanels() {
    setState(() {
      _showCaptureMode = false;
      _showLayersPanel = false;
      _showScanPanel = false;
      _showRadar = false;
      _showAiGuide = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------------------------------
          // NATIVE ARCORE WORLD — camera + tracking are now owned by Android.
          Positioned.fill(
            child: EmbedUnity(
              onMessageFromUnity: (message) {
                debugPrint('Unity → Flutter: $message');
              },
            ),
          ),

          // Very subtle cinematic scrim so the glass UI remains readable.
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.18, 0.72, 1.0],
                  colors: [
                    Colors.black.withOpacity(.22),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(.28),
                  ],
                ),
              ),
            ),
          ),

          if (_mainUiVisible) ...[
            // ----------------------------------------------------------
            // TOP BAR
            // ----------------------------------------------------------
            Positioned(
              top: media.padding.top + 12,
              left: 16,
              right: 16,
              child: _TopBar(
                onLocationTap: () {},
                onNearbyTap: () {},
                onVisionToggle: () {},
              ),
            ),

            // ----------------------------------------------------------
            // LEFT SPATIAL TOOL RAIL
            // ----------------------------------------------------------
            Positioned(
              left: 14,
              top: size.height * .31,
              child: _GlassRail(
                children: [
                  _RailButton(
                    icon: Icons.bookmark_border_rounded,
                    tooltip: 'Save',
                    onTap: () {},
                  ),
                  _RailButton(
                    icon: Icons.center_focus_strong_rounded,
                    tooltip: 'Focus',
                    onTap: () {},
                  ),
                  _RailButton(
                    icon: Icons.blur_on_rounded,
                    tooltip: 'Portal',
                    onTap: () {},
                  ),
                  _RailButton(
                    icon: Icons.auto_awesome_rounded,
                    tooltip: 'Pulse',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------------
            // RIGHT SPATIAL TOOL RAIL
            // ----------------------------------------------------------
            Positioned(
              right: 14,
              top: size.height * .31,
              child: _GlassRail(
                children: [
                  _RailButton(
                    icon: Icons.photo_camera_outlined,
                    tooltip: 'Capture',
                    onTap: () {
                      setState(() {
                        _showCaptureMode = true;
                        _showCreateHub = false;
                        _showRadar = false;
                        _showAiGuide = false;
                      });
                    },
                  ),
                  _RailButton(
                    icon: Icons.document_scanner_outlined,
                    tooltip: 'Scan',
                    onTap: () {
                      setState(() {
                        _showScanPanel = true;
                        _showCreateHub = false;
                        _showRadar = false;
                        _showAiGuide = false;
                      });
                    },
                  ),
                  _RailButton(
                    icon: Icons.layers_outlined,
                    tooltip: 'Layers',
                    onTap: () {
                      setState(() {
                        _showLayersPanel = true;
                        _showCreateHub = false;
                        _showRadar = false;
                        _showAiGuide = false;
                      });
                    },
                  ),
                  _RailButton(
                    icon: Icons.radar_rounded,
                    tooltip: 'Radar',
                    onTap: () {
                      setState(() {
                        _showRadar = !_showRadar;
                        _showAiGuide = false;
                      });
                    },
                  ),
                  _RailButton(
                    icon: Icons.auto_awesome_outlined,
                    tooltip: 'AI Guide',
                    onTap: () {
                      setState(() {
                        _showAiGuide = !_showAiGuide;
                        _showRadar = false;
                      });
                    },
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------------
            // CENTER AR RETICLE
            // ----------------------------------------------------------
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: _SpatialReticle(),
                ),
              ),
            ),

            // ----------------------------------------------------------
            // EXPLORE DISCOVERY STRIP
            // ----------------------------------------------------------
            Positioned(
              left: 20,
              right: 20,
              bottom: 124,
              child: _ExploreDiscovery(
                onTap: () {},
              ),
            ),

            // ----------------------------------------------------------
            // RADAR OVERLAY
            // ----------------------------------------------------------
            if (_showRadar)
              Positioned(
                right: 78,
                top: size.height * .40,
                child: _RadarCard(
                  onClose: () => setState(() => _showRadar = false),
                ),
              ),

            // ----------------------------------------------------------
            // AI GUIDE OVERLAY
            // ----------------------------------------------------------
            if (_showAiGuide)
              Positioned(
                right: 78,
                top: size.height * .50,
                child: _AiGuideCard(
                  onClose: () => setState(() => _showAiGuide = false),
                ),
              ),

            // ----------------------------------------------------------
            // BOTTOM NAV
            // ----------------------------------------------------------
            Positioned(
              left: 16,
              right: 16,
              bottom: media.padding.bottom + 16,
              child: _BottomDock(
                createActive: _showCreateHub,
                onExplore: () {},
                onChat: () {},
                onCreate: () {
                  setState(() {
                    _showCreateHub = !_showCreateHub;
                    _showRadar = false;
                    _showAiGuide = false;
                  });
                },
                onPulse: () {},
                onProfile: () {},
              ),
            ),

            // ----------------------------------------------------------
            // CREATE HUB
            // ----------------------------------------------------------
            CreateHubOverlay(
              visible: _showCreateHub,
            ),
          ],

          // ------------------------------------------------------------
          // MODAL MODES
          // ------------------------------------------------------------
          if (_showCaptureMode) ...[
            CaptureModePanel(
              selectedIndex: _captureMode,
              onChanged: (value) {
                setState(() => _captureMode = value);
              },
              onClose: () {
                setState(() => _showCaptureMode = false);
              },
            ),
            CameraBottomControls(
              mode: _captureMode,
              onCapture: () {},
            ),
          ],

          if (_showLayersPanel)
            LayersPanel(
              onClose: () {
                setState(() => _showLayersPanel = false);
              },
            ),

          if (_showScanPanel)
            ScanPanel(
              onClose: () {
                setState(() => _showScanPanel = false);
              },
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// TOP BAR
// ============================================================================

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onLocationTap,
    required this.onNearbyTap,
    required this.onVisionToggle,
  });

  final VoidCallback onLocationTap;
  final VoidCallback onNearbyTap;
  final VoidCallback onVisionToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GlassPill(
          onTap: onLocationTap,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 17,
                color: Color(0xFFEFEFEF),
              ),
              SizedBox(width: 8),
              Text(
                'Downtown Cairo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.1,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: Colors.white54,
              ),
            ],
          ),
        ),
        const Spacer(),
        _GlassPill(
          onTap: onNearbyTap,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LiveDot(),
              SizedBox(width: 7),
              Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6,
                ),
              ),
              SizedBox(width: 9),
              Icon(
                Icons.people_outline_rounded,
                size: 15,
                color: Colors.white60,
              ),
              SizedBox(width: 4),
              Text(
                '2.4K',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _GlassIconButton(
          icon: Icons.phone_iphone_rounded,
          trailingIcon: Icons.visibility_outlined,
          onTap: onVisionToggle,
          semanticLabel: 'Phone and glasses mode',
        ),
      ],
    );
  }
}

// ============================================================================
// LEFT / RIGHT RAIL
// ============================================================================

class _GlassRail extends StatelessWidget {
  const _GlassRail({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      radius: 24,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Container(
                height: 1,
                width: 20,
                color: Colors.white.withOpacity(.075),
              ),
          ],
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: 50,
            height: 52,
            child: Icon(
              icon,
              size: 21,
              color: Colors.white.withOpacity(.88),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// RETICLE
// ============================================================================

class _SpatialReticle extends StatelessWidget {
  const _SpatialReticle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(.72),
                width: 1,
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: _ReticleLine(vertical: true),
          ),
          Positioned(
            bottom: 0,
            child: _ReticleLine(vertical: true),
          ),
          Positioned(
            left: 0,
            child: _ReticleLine(vertical: false),
          ),
          Positioned(
            right: 0,
            child: _ReticleLine(vertical: false),
          ),
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReticleLine extends StatelessWidget {
  const _ReticleLine({required this.vertical});

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: vertical ? 1 : 10,
      height: vertical ? 10 : 1,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.8),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ============================================================================
// EXPLORE
// ============================================================================

class _ExploreDiscovery extends StatelessWidget {
  const _ExploreDiscovery({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassSurface(
        radius: 24,
        padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
        child: Row(
          children: [
            const _DiscoveryOrb(),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore MetaZone',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '3 new experiences are nearby',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Colors.white.withOpacity(.55),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryOrb extends StatelessWidget {
  const _DiscoveryOrb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFECE9FF),
            Color(0xFFB7B0FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB7B0FF).withOpacity(.20),
            blurRadius: 18,
          ),
        ],
      ),
      child: const Icon(
        Icons.explore_outlined,
        size: 18,
        color: Color(0xFF25213D),
      ),
    );
  }
}

// ============================================================================
// RADAR / AI
// ============================================================================

class _RadarCard extends StatelessWidget {
  const _RadarCard({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return _FloatingPanel(
      width: 250,
      title: 'Nearby',
      subtitle: 'Spatial radar',
      icon: Icons.radar_rounded,
      onClose: onClose,
      child: Column(
        children: const [
          _RadarItem(
            icon: Icons.blur_on_rounded,
            title: 'Portal',
            distance: '120 m',
          ),
          _RadarItem(
            icon: Icons.event_outlined,
            title: 'Live Event',
            distance: '180 m',
          ),
          _RadarItem(
            icon: Icons.auto_awesome_outlined,
            title: 'Experience',
            distance: '240 m',
          ),
        ],
      ),
    );
  }
}

class _RadarItem extends StatelessWidget {
  const _RadarItem({
    required this.icon,
    required this.title,
    required this.distance,
  });

  final IconData icon;
  final String title;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 17, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            distance,
            style:  TextStyle(
              color: Colors.white.withOpacity(.45),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiGuideCard extends StatelessWidget {
  const _AiGuideCard({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return _FloatingPanel(
      width: 270,
      title: 'MetaZone AI',
      subtitle: 'Ask about what you see',
      icon: Icons.auto_awesome_outlined,
      onClose: onClose,
      child: Column(
        children: [
          const _Suggestion(text: 'What is interesting nearby?'),
          const _Suggestion(text: 'What am I looking at?'),
          const _Suggestion(text: 'Find an experience for me'),
          const SizedBox(height: 6),
          _AiInput(),
        ],
      ),
    );
  }
}

class _Suggestion extends StatelessWidget {
  const _Suggestion({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.055),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AiInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Row(
        children: const [
          Expanded(
            child: Text(
              'Ask MetaZone AI…',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ),
          Icon(
            Icons.mic_none_rounded,
            size: 18,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BOTTOM DOCK
// ============================================================================

class _BottomDock extends StatelessWidget {
  const _BottomDock({
    required this.createActive,
    required this.onExplore,
    required this.onChat,
    required this.onCreate,
    required this.onPulse,
    required this.onProfile,
  });

  final bool createActive;
  final VoidCallback onExplore;
  final VoidCallback onChat;
  final VoidCallback onCreate;
  final VoidCallback onPulse;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      radius: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: SizedBox(
        height: 58,
        child: Row(
          children: [
            _DockItem(
              icon: Icons.explore_outlined,
              label: 'Explore',
              active: true,
              onTap: onExplore,
            ),
            _DockItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat',
              onTap: onChat,
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: onCreate,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: createActive ? 52 : 48,
                    height: createActive ? 52 : 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: createActive
                          ? Colors.white
                          : Colors.white.withOpacity(.12),
                      border: Border.all(
                        color: Colors.white.withOpacity(.20),
                      ),
                      boxShadow: createActive
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(.16),
                                blurRadius: 24,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      createActive
                          ? Icons.close_rounded
                          : Icons.add_rounded,
                      color: createActive ? Colors.black : Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
            _DockItem(
              icon: Icons.auto_awesome_outlined,
              label: 'Pulse',
              onTap: onPulse,
            ),
            _DockItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: onProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: active ? 22 : 20,
              color: active
                  ? Colors.white
                  : Colors.white.withOpacity(.56),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : Colors.white.withOpacity(.48),
                fontSize: 9.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GLASS PRIMITIVES
// ============================================================================

class _GlassPill extends StatelessWidget {
  const _GlassPill({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassSurface(
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: child,
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.trailingIcon,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final IconData trailingIcon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: _GlassSurface(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white70),
              const SizedBox(width: 5),
              Container(
                width: 1,
                height: 15,
                color: Colors.white.withOpacity(.10),
              ),
              const SizedBox(width: 5),
              Icon(trailingIcon, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassSurface extends StatelessWidget {
  const _GlassSurface({
    required this.child,
    this.radius = 20,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.22),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(.11),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.20),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FloatingPanel extends StatelessWidget {
  const _FloatingPanel({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onClose,
    required this.child,
  });

  final double width;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      radius: 22,
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style:  TextStyle(
                          color: Colors.white.withOpacity(.45),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 17,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF8DFFB5),
      ),
    );
  }
}
