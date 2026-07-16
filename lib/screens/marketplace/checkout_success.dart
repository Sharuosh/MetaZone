import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 Success Glow Animation
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0.4, end: 1.0),
                curve: Curves.easeInOut,
                builder: (context, glow, child) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(glow),
                          blurRadius: 40 * glow,
                          spreadRadius: 10 * glow,
                        ),
                      ],
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(.9),
                          AppColors.primary.withOpacity(.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              Text(
                "Purchase Successful",
                style: AppTextStyles.heading(size: 28),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                "Your AR asset has been securely added to your MetaZone Library.",
                style: AppTextStyles.caption(size: 14),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Fake asset card preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    // asset thumbnail
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hologram Portal", style: AppTextStyles.title(size: 16)),
                          const SizedBox(height: 4),
                          Text("Digital Asset • AR Ready", style: AppTextStyles.caption(size: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 🔥 Buttons
              ElevatedButton(
                onPressed: () {
                  // TODO: go to AR preview
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text("Preview in AR"),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(color: AppColors.primary),
                ),
                child: Text("Go to Library", style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
