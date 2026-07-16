import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  bool _ob1 = true, _ob2 = true, _ob3 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Change password", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _field("Current password", _old, _ob1, () => setState(() => _ob1 = !_ob1)),
          const SizedBox(height: 12),
          _field("New password", _new, _ob2, () => setState(() => _ob2 = !_ob2)),
          const SizedBox(height: 12),
          _field("Confirm password", _confirm, _ob3, () => setState(() => _ob3 = !_ob3)),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, bool ob, VoidCallback toggle) {
    return TextField(
      controller: c,
      obscureText: ob,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.cardSoft,
        suffixIcon: IconButton(
          icon: Icon(ob ? Icons.visibility_off : Icons.visibility,
              color: AppColors.primary),
          onPressed: toggle,
        ),
      ),
    );
  }
}
