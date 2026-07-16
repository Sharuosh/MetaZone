import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class FinalDeleteConfirmScreen extends StatefulWidget {
  const FinalDeleteConfirmScreen({super.key});

  @override
  State<FinalDeleteConfirmScreen> createState() => _FinalDeleteConfirmScreenState();
}

class _FinalDeleteConfirmScreenState extends State<FinalDeleteConfirmScreen> {
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Confirm Deletion", style: AppTextStyles.heading()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you absolutely sure?",
              style: AppTextStyles.title(size: 20).copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: 14),

            Text(
              "Deleting your account will permanently remove:",
              style: AppTextStyles.body(),
            ),

            const SizedBox(height: 10),
            _point("• All AR Spots you created"),
            _point("• Your chats & social interactions"),
            _point("• Your profile & followers"),
            _point("• Stored world data & AR anchors"),
            _point("• All device sessions & history"),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Text(
                    "This action cannot be undone.",
                    style: AppTextStyles.title(size: 16)
                        .copyWith(color: AppColors.danger),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Please enter your password to confirm:",
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: AppColors.cardSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _loading ? null : () => _handleDelete(context),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Delete My Account Permanently"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _point(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: AppTextStyles.body()),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    if (_passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your password")),
      );
      return;
    }

    setState(() => _loading = true);

    await Future.delayed(const Duration(seconds: 2)); // simulate backend

    setState(() => _loading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FinalDeleteSuccessScreen()),
    );
  }
}


// ------------------------------------------------------
//              FINAL SUCCESS SCREEN (NEW)
// ------------------------------------------------------

class FinalDeleteSuccessScreen extends StatelessWidget {
  const FinalDeleteSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.danger, size: 80),
              const SizedBox(height: 20),

              Text(
                "Account Deleted",
                style: AppTextStyles.heading(size: 26)
                    .copyWith(color: AppColors.danger),
              ),
              const SizedBox(height: 10),

              Text(
                "Your MetaZone account has been permanently removed.",
                textAlign: TextAlign.center,
                style: AppTextStyles.body(),
              ),

              const SizedBox(height: 35),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
