import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ARVisibilityScreen extends StatefulWidget {
  const ARVisibilityScreen({super.key});

  @override
  State<ARVisibilityScreen> createState() => _ARVisibilityScreenState();
}

class _ARVisibilityScreenState extends State<ARVisibilityScreen> {
  String _visibility = "Followers"; // Default

  @override
  Widget build(BuildContext context) {
    final opts = ["Everyone", "Followers", "Only me"];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("AR Spots visibility"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: opts.map((o) {
          return Card(
            color: AppColors.card,
            child: RadioListTile<String>(
              value: o,
              groupValue: _visibility,
              onChanged: (v) => setState(() => _visibility = v!),
              title: Text(o, style: AppTextStyles.body()),
            ),
          );
        }).toList(),
      ),
    );
  }
}
