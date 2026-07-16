import 'package:flutter/material.dart';

import 'create_category_card.dart';
import 'create_center_ring.dart';

class CreateHub extends StatelessWidget {
  const CreateHub({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// CENTER RING
          const Positioned(
            top: 175,
            child: CreateCenterRing(),
          ),

          /// OBJECT
          Positioned(
            top: 40,
            child: CreateCategoryCard(
              title: 'Object',
              subtitle: 'Place 3D objects',
              icon: Icons.view_in_ar,
              glowColor: const Color(0xff00D4FF),
              onTap: () {},
            ),
          ),

          /// MESSAGE
          Positioned(
            top: 115,
            left: 55,
            child: CreateCategoryCard(
              title: 'Message',
              subtitle: 'Voice • Video',
              icon: Icons.message_outlined,
              glowColor: const Color(0xff52FFE0),
              onTap: () {},
            ),
          ),

          /// PORTAL
          Positioned(
            top: 115,
            right: 55,
            child: CreateCategoryCard(
              title: 'Portal',
              subtitle: 'AR Gateway',
              icon: Icons.radio_button_checked,
              glowColor: const Color(0xffD16BFF),
              onTap: () {},
            ),
          ),

          /// EVENT
          Positioned(
            top: 230,
            left: 55,
            child: CreateCategoryCard(
              title: 'Event',
              subtitle: 'AR Events',
              icon: Icons.event_outlined,
              glowColor: const Color(0xffFFB357),
              onTap: () {},
            ),
          ),

          /// GHOST ECHO
          Positioned(
            top: 230,
            right: 55,
            child: CreateCategoryCard(
              title: 'Ghost Echo',
              subtitle: 'Digital Echo',
              icon: Icons.blur_on,
              glowColor: const Color(0xffB26DFF),
              onTap: () {},
            ),
          ),

          /// AI ASSISTANT
          Positioned(
            top: 345,
            child: CreateCategoryCard(
              title: 'AI Assistant',
              subtitle: 'AI Companion',
              icon: Icons.smart_toy_outlined,
              glowColor: const Color(0xff5AB8FF),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}