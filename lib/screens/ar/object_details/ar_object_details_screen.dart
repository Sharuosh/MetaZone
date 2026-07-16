import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class ARObjectDetailsScreen extends StatelessWidget {
  final String objectId;
  final String objectName;

  const ARObjectDetailsScreen({
    super.key,
    required this.objectId,
    required this.objectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(objectName),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Object Summary
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Object Memory Layer",
                    style: AppTextStyles.title()),
                const SizedBox(height: 8),
                Text(
                  "All comments & interactions tied to this physical location.",
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Center(
              child: Text(
                "History / Threads will appear here",
                style: AppTextStyles.caption(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {},
              child: const Text("View in AR"),
            ),
          )
        ],
      ),
    );
  }
}
