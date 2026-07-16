import 'dart:ui';

import 'package:flutter/material.dart';

import '../widgets/create/create_hub.dart';

class CreateHubOverlay extends StatefulWidget {
  final bool visible;

  const CreateHubOverlay({
    super.key,
    required this.visible,
  });

  @override
  State<CreateHubOverlay> createState() => _CreateHubOverlayState();
}

class _CreateHubOverlayState extends State<CreateHubOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> blurAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    blurAnimation = Tween<double>(
      begin: 0,
      end: 14,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    scaleAnimation = Tween<double>(
      begin: .90,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant CreateHubOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox();
    }

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Stack(
            children: [

              /// BACKDROP
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurAnimation.value,
                  sigmaY: blurAnimation.value,
                ),
                child: Container(
                  color: Colors.black.withOpacity(.18),
                ),
              ),

              /// CONTENT
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Opacity(
                    opacity: fadeAnimation.value,
                    child: Transform.scale(
                      scale: scaleAnimation.value,
                      child: Column(
                        children: [

                          const SizedBox(height: 0),


                          const SizedBox(height: 10),

                          /// HUB
                          const CreateHub(),

                          const SizedBox(height: 8),

                          /// QUICK CREATE
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                const Text(
                                  'Quick Create',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [

                                      _quickChip(
                                        Icons.text_fields,
                                        'Text',
                                      ),

                                      _quickChip(
                                        Icons.image_outlined,
                                        'Image',
                                      ),

                                      _quickChip(
                                        Icons.mic_none,
                                        'Voice',
                                      ),

                                      _quickChip(
                                        Icons.video_call_outlined,
                                        'Video',
                                      ),

                                      _quickChip(
                                        Icons.qr_code,
                                        'QR',
                                      ),

                                      _quickChip(
                                        Icons.draw_outlined,
                                        'Draw',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          /// RECENT
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                const Text(
                                  'Recent Creations',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                SizedBox(
                                  height: 95,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [

                                      _recentCard(
                                        'Ancient Statue',
                                        Icons.view_in_ar,
                                      ),

                                      _recentCard(
                                        'City Portal',
                                        Icons.public,
                                      ),

                                      _recentCard(
                                        'Welcome Message',
                                        Icons.message,
                                      ),

                                      _recentCard(
                                        'AI Guide',
                                        Icons.smart_toy,
                                      ),

                                      _recentCard(
                                        'AR Event',
                                        Icons.event,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _quickChip(
      IconData icon,
      String title,
      ) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(.04),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xff00D4FF),
            size: 18,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentCard(
      String title,
      IconData icon,
      ) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(.04),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.05),
            ),
            child: Icon(
              icon,
              color: const Color(0xff00D4FF),
              size: 16,
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}