import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class LiveARFeedScreen extends StatelessWidget {
  const LiveARFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Live AR Feed", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 12),

          _post("Ahmed", "Uploaded a 3D Portal near Nile River"),
          _post("Sara", "Created a floating hologram"),
          _post("MetaUser12", "Shared AR creature model"),
        ],
      ),
    );
  }

  Widget _post(String user, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text("$user\n$text",
                style: AppTextStyles.body(size: 14)),
          ),
        ],
      ),
    );
  }
}
