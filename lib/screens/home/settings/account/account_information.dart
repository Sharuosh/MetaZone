import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

import 'linked_accounts.dart';
import 'login_history.dart';
import 'identity_verification.dart';
import 'account_status.dart';
import 'data_download.dart';

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  State<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  final _displayName = TextEditingController(text: "Abdelrahman Sharuosh");
  final _username = TextEditingController(text: "meta_user");
  final _email = TextEditingController(text: "user@metazone.app");
  final _phone = TextEditingController(text: "+201234567890");
  final _bio = TextEditingController(text: "AR Explorer • MetaZone");

  final String userId = "MZ-8F21-991A"; // مثال

  @override
  void dispose() {
    _displayName.dispose();
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Saved (demo)")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Account Information", style: AppTextStyles.heading()),
      ),

      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [

          // ============================
          // Profile Picture
          // ============================
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withOpacity(.2),
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text("Change Photo"),
              )
            ],
          ),
          const SizedBox(height: 18),

          // ============================
          // Quick User Info
          // ============================
          Card(
            color: AppColors.card,
            child: ListTile(
              title: Text("User ID", style: AppTextStyles.body()),
              subtitle: Text(userId, style: AppTextStyles.caption()),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Copied User ID")));
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ============================
          // Editable Fields
          // ============================
          _field("Display Name", _displayName),
          _field("Username", _username),
          _field("Bio", _bio, maxLines: 3),
          _field("Email", _email),
          _field("Phone Number", _phone),

          // ============================
          // Preferred Username Formatting
          // ============================
          Card(
            color: AppColors.card,
            child: ListTile(
              leading: Icon(Icons.text_fields, color: AppColors.primary),
              title: const Text("Preferred username formatting"),
              subtitle: const Text("Lowercase only / Keep symbols / Clean formatting"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 16),

          // ============================
          // Linked Section
          // ============================
          Card(
            color: AppColors.card,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.link, color: AppColors.primary),
                  title: const Text("Linked Accounts"),
                  subtitle: const Text("Google • Facebook • Apple"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LinkedAccountsScreen()),
                  ),
                ),

                ListTile(
                  leading: Icon(Icons.history, color: AppColors.primary),
                  title: const Text("Login History"),
                  subtitle: const Text("Sessions • Devices • Locations"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginHistoryScreen()),
                  ),
                ),

                ListTile(
                  leading: Icon(Icons.verified_user, color: AppColors.primary),
                  title: const Text("Identity Verification"),
                  subtitle: const Text("Government ID • Status • Flags"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IdentityVerificationScreen()),
                  ),
                ),

                ListTile(
                  leading: Icon(Icons.shield, color: AppColors.primary),
                  title: const Text("Account Status & Flags"),
                  subtitle: const Text("Restrictions • Warnings • Level"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountStatusScreen()),
                  ),
                ),

                ListTile(
                  leading: Icon(Icons.download, color: AppColors.primary),
                  title: const Text("Download my data"),
                  subtitle: const Text("AR spots • Chats • Profile • Settings"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DataDownloadScreen()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ============================
          // Save Button
          // ============================
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body()),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
