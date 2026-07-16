import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class AIAssistantBar extends StatelessWidget {
  const AIAssistantBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/ask_mz_ai");
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.neonGradient,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.black,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ask MetaZone AI", style: AppTextStyles.title(size: 16)),
                  const SizedBox(height: 4),
                  Text(
                    "Ask anything about AR, spots, portals & more.",
                    style: AppTextStyles.caption(size: 12),
                  ),
                ],
              ),
            ),

            /// ❌ كان هنا const Icon ← غلط
            /// ✅ ده الصح:
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSoft,
            ),
          ],
        ),
      ),
    );
  }
}
