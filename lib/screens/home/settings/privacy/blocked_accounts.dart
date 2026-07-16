import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class BlockedAccountsScreen extends StatefulWidget {
  const BlockedAccountsScreen({super.key});

  @override
  State<BlockedAccountsScreen> createState() => _BlockedAccountsScreenState();
}

class _BlockedAccountsScreenState extends State<BlockedAccountsScreen> {
  final List<String> _blocked = [
    "user_203",
    "meta_shadow",
    "ar_creator_55",
  ];

  void _unblock(String u) {
    setState(() => _blocked.remove(u));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$u has been unblocked")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Blocked Accounts"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _blocked.length,
        itemBuilder: (_, i) {
          final user = _blocked[i];
          return Card(
            color: AppColors.card,
            child: ListTile(
              title: Text(user),
              trailing: TextButton(
                onPressed: () => _unblock(user),
                child: const Text("Unblock"),
              ),
            ),
          );
        },
      ),
    );
  }
}
