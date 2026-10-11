import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

class HomeLoading extends StatelessWidget {
  const HomeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.public_rounded,
            size: 56,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Nothing to show yet',
            style: AppTextStyles.title(
              size: 18,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try moving to a nearby area or search for a place.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmallStyle(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeErrorState extends StatelessWidget {
  const HomeErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 52,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
