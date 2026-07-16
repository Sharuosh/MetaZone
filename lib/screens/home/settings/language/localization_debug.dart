import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/localization/localization_setup.dart';
import '../../../../core/localization/app_localizations.dart';

class LocalizationDebugScreen extends StatelessWidget {
  const LocalizationDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    // تأمين عدم حدوث null
    final keys = localization?.allKeys ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Localization Debug"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: keys.map((key) {
          final value = localization?.translate(key) ?? "";
          final isMissing = value == "MISSING" || value.trim().isEmpty;

          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isMissing
                  ? AppColors.danger.withOpacity(.1)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isMissing ? AppColors.danger : AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text("$key = $value",
                      style: AppTextStyles.body()),
                ),
                if (isMissing)
                  Icon(Icons.error, color: AppColors.danger),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
