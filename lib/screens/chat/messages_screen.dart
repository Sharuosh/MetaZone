import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Messages", style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: Text("Chat system coming soon...",
            style: TextStyle(color: AppColors.textLight)),
      ),
    );
  }
}
