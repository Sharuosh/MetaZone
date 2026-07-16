import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class CommentPermissionsScreen extends StatefulWidget {
  const CommentPermissionsScreen({super.key});

  @override
  State<CommentPermissionsScreen> createState() => _CommentPermissionsScreenState();
}

class _CommentPermissionsScreenState extends State<CommentPermissionsScreen> {
  String _permission = "Everyone";

  @override
  Widget build(BuildContext context) {
    final opts = ["Everyone", "Followers", "No one"];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Comment permissions"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: opts.map((o) {
          return Card(
            color: AppColors.card,
            child: RadioListTile<String>(
              value: o,
              groupValue: _permission,
              onChanged: (v) => setState(() => _permission = v!),
              title: Text(o, style: AppTextStyles.body()),
            ),
          );
        }).toList(),
      ),
    );
  }
}
