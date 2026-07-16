import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class DataDownloadScreen extends StatefulWidget {
  const DataDownloadScreen({super.key});

  @override
  State<DataDownloadScreen> createState() => _DataDownloadScreenState();
}

class _DataDownloadScreenState extends State<DataDownloadScreen> {
  bool _includeArObjects = true;
  bool _includeProfile = true;
  bool _includeMessages = false;
  bool _includeLocations = true;
  bool _requestInProgress = false;

  void _requestDownload() async {
    setState(() => _requestInProgress = true);

    // TODO: backend request for data packaging
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _requestInProgress = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Your data export request has been submitted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Download My Data"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            "You can request a downloadable copy of your MetaZone data.\n"
                "Your export file will include JSON + media files (AR objects, profile assets, etc).",
            style: AppTextStyles.body(),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            value: _includeProfile,
            title: const Text("Profile information"),
            subtitle: const Text("Username, bio, avatar, linked accounts"),
            onChanged: (v) => setState(() => _includeProfile = v),
          ),

          SwitchListTile(
            value: _includeArObjects,
            title: const Text("AR Objects & Spots"),
            subtitle: const Text("All AR assets you created across the world"),
            onChanged: (v) => setState(() => _includeArObjects = v),
          ),

          SwitchListTile(
            value: _includeLocations,
            title: const Text("Location history"),
            subtitle: const Text("Your AR spot placements & visited areas"),
            onChanged: (v) => setState(() => _includeLocations = v),
          ),

          SwitchListTile(
            value: _includeMessages,
            title: const Text("Messages & interactions"),
            subtitle: const Text("Direct messages, comments, likes"),
            onChanged: (v) => setState(() => _includeMessages = v),
          ),

          const SizedBox(height: 20),

          _requestInProgress
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : ElevatedButton.icon(
            onPressed: _requestDownload,
            icon: const Icon(Icons.download),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            label: const Text("Request Data Export"),
          ),

          const SizedBox(height: 10),

          Text(
            "Note: Preparing your file may take up to 48 hours depending on data size.",
            style: AppTextStyles.caption(),
          ),
        ],
      ),
    );
  }
}
