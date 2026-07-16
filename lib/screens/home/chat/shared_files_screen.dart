import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class SharedFilesScreen extends StatelessWidget {
  final String userId;
  final String username;

  const SharedFilesScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final dummy = List.generate(12, (i) {
      return {
        "name": "File_${i + 1}.pdf",
        "size": "${(2.1 + i).toStringAsFixed(1)} MB",
        "type": "pdf",
      };
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          "Shared Files — $username",
          style: TextStyle(color: AppColors.text),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: dummy.length,
        itemBuilder: (_, i) => _fileTile(dummy[i]),
      ),
    );
  }

  Widget _fileTile(Map f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, color: AppColors.primary, size: 30),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f["name"],
                    style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(f["size"],
                    style: TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 12,
                    )),
              ],
            ),
          ),

          Icon(Icons.download, color: AppColors.primary),
        ],
      ),
    );
  }
}
