import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Discover", style: TextStyle(color: AppColors.primary)),
      ),
      body: Center(
        child: Text("Discover Meta Worlds",
            style: TextStyle(color: AppColors.textLight)),
      ),
    );
  }
}
