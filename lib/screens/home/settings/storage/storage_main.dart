import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

import 'clear_world_cache.dart';
import 'clear_mesh_cache.dart';
import 'rebuild_database.dart';
import 'reset_defaults.dart'; // ★ تمت إضافتها

class StorageMainScreen extends StatelessWidget {
  const StorageMainScreen({super.key});

  Widget _item(BuildContext c, IconData icon, String title, String sub, Widget page) {
    return Card(
      color: AppColors.card,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.body()),
        subtitle: Text(sub, style: AppTextStyles.caption()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Storage", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _item(
            context,
            Icons.map,
            "World Map Cache",
            "Clear AR world mapping cache",
            const ClearWorldCacheScreen(),
          ),

          _item(
            context,
            Icons.grid_3x3,
            "Mesh Cache",
            "Remove plane/mesh detection data",
            const ClearMeshCacheScreen(),
          ),

          _item(
            context,
            Icons.storage_rounded,
            "Rebuild Database",
            "Fix corrupted tables & regenerate indexes",
            const RebuildDatabaseScreen(),
          ),

          _item(
            context,
            Icons.settings_backup_restore,
            "Reset Defaults",
            "Restore all MetaZone settings to default",
            const ResetDefaultsScreen(),
          ),
        ],
      ),
    );
  }
}
