import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

import 'supported_locales.dart';
import 'language_controller.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _current;

  @override
  void initState() {
    super.initState();
    _current = LanguageController.currentLanguageCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Language", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: SupportedLocales.locales.map((locale) {
          final code = locale.languageCode;

          return Card(
            color: AppColors.card,
            child: RadioListTile(
              activeColor: AppColors.primary,
              value: code,
              groupValue: _current,
              title: Text(code.toUpperCase(), style: AppTextStyles.title()),
              subtitle: Text(locale.toString(), style: AppTextStyles.caption()),
              onChanged: (v) async {
                if (v == null) return;

                setState(() => _current = v);

                await LanguageController.changeLanguage(v);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Language changed to $v"),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
