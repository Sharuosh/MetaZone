import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class KnownIssuesScreen extends StatelessWidget {
  const KnownIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final issues = [
      "• بعض أجهزة Android القديمة تواجه صعوبة في تتبع الـ AR planes.",
      "• بطء بسيط عند تحميل المجسمات الكبيرة في وضع High Performance.",
      "• مشكلة نادرة: فشل الاتصال بالخريطة عند ضعف الشبكة.",
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Known Issues"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: issues.length,
        itemBuilder: (_, i) => Card(
          color: AppColors.card,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              issues[i],
              style: AppTextStyles.body(),
            ),
          ),
        ),
      ),
    );
  }
}
