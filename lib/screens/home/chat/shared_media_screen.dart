// lib/screens/home/chat/shared_media_screen.dart
// MetaZone — Shared Media (Final Polished Version)

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class SharedMediaScreen extends StatelessWidget {
  final String username;
  final String userId;

  const SharedMediaScreen({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // لاحقاً → Firestore fetch
    final dummy = List.generate(20, (i) => "https://picsum.photos/seed/m$i/900");

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface.withOpacity(.7),
        title: Text(
          "Shared Media — $username",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: dummy.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (_, i) {
          final url = dummy[i];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: false,
                  transitionDuration: const Duration(milliseconds: 260),
                  pageBuilder: (_, __, ___) =>
                      _MediaViewer(url: url, username: username),
                ),
              );
            },
            child: Hero(
              tag: url,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(
                    image: NetworkImage(url),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primarySoft.withOpacity(.25),
                      blurRadius: 12,
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===============================================================
// FULLSCREEN VIEWER
// ===============================================================

class _MediaViewer extends StatelessWidget {
  final String url;
  final String username;

  const _MediaViewer({required this.url, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(.85),
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: url,
              child: InteractiveViewer(
                maxScale: 4,
                minScale: .7,
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
          ),

          // Top Controls Glass
          Positioned(
            top: 28,
            left: 14,
            right: 14,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: Colors.white.withOpacity(.08),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.white, size: 20),
                      ),
                      Text(
                        username,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Shadow
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black54],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
