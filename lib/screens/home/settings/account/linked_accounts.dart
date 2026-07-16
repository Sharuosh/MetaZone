import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class LinkedAccountsScreen extends StatefulWidget {
  const LinkedAccountsScreen({super.key});

  @override
  State<LinkedAccountsScreen> createState() => _LinkedAccountsScreenState();
}

class _LinkedAccountsScreenState extends State<LinkedAccountsScreen> {
  bool google = true;
  bool facebook = false;
  bool apple = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Linked Accounts"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _switch("Google", google, (v) => setState(() => google = v)),
          _switch("Facebook", facebook, (v) => setState(() => facebook = v)),
          _switch("Sign in with Apple", apple, (v) => setState(() => apple = v)),
        ],
      ),
    );
  }

  Widget _switch(String title, bool value, Function(bool) onChanged) {
    return Card(
      color: AppColors.card,
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
