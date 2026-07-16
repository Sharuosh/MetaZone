// lib/screens/ar/anchors/anchor_details_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../models/anchor_model.dart';
import 'dart:convert';


class AnchorDetailsScreen extends StatefulWidget {
  final AnchorModel anchor;
  const AnchorDetailsScreen({super.key, required this.anchor});

  @override
  State<AnchorDetailsScreen> createState() => _AnchorDetailsScreenState();
}

class _AnchorDetailsScreenState extends State<AnchorDetailsScreen> {
  late AnchorModel anchor;
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  bool _isCalibrating = false;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    anchor = widget.anchor;
    _titleCtrl = TextEditingController(text: anchor.title);
    _descCtrl = TextEditingController(text: anchor.description);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      anchor.title = _titleCtrl.text.trim().isEmpty ? anchor.title : _titleCtrl.text.trim();
      anchor.description = _descCtrl.text.trim();
    });
    // return updated anchor to previous screen
    Navigator.pop(context, anchor);
  }

  Future<void> _recalibrate() async {
    setState(() => _isCalibrating = true);
    await Future.delayed(const Duration(seconds: 2));
    // demo: randomly improve stability
    final improved = (anchor.stability + 0.08).clamp(0.0, 1.0);
    setState(() {
      anchor.stability = improved;
      _isCalibrating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recalibration complete (demo)')));
  }

  Future<void> _resync() async {
    setState(() => anchor = anchor..stability = (anchor.stability + 0.02).clamp(0.0, 1.0));
    await Future.delayed(const Duration(milliseconds: 600));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anchor resynced (demo)')));
  }

  void _deleteAnchor() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Anchor', style: AppTextStyles.title()),
        content: Text('Remove "${anchor.title}" permanently?', style: AppTextStyles.body()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context, anchor..title = '__DELETE__'); // signal deletion (caller should remove)
            },
            child: Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Widget _stabilityWidget() {
    final v = anchor.stability;
    String label;
    Color color;
    if (v >= 0.85) {
      label = 'Excellent';
      color = Colors.greenAccent;
    } else if (v >= 0.7) {
      label = 'Good';
      color = Colors.orangeAccent;
    } else {
      label = 'Poor';
      color = AppColors.danger;
    }

    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Stability', style: AppTextStyles.caption()),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: AppColors.surfaceSoft, valueColor: AlwaysStoppedAnimation(color)),
          const SizedBox(height: 6),
          Text('$label • ${(v * 100).toInt()}%', style: AppTextStyles.body()),
        ]),
      ),
      const SizedBox(width: 12),
      Icon(Icons.scatter_plot, color: color),
    ]);
  }

  Widget _mini3DPreview() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.view_in_ar, size: 46, color: AppColors.primary),
          const SizedBox(height: 8),
          Text('3D Preview (placeholder)', style: AppTextStyles.caption()),
        ]),
      ),
    );
  }

  Widget _metaInfoRow(String title, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: AppTextStyles.caption()),
      const SizedBox(width: 8),
      Expanded(child: Text(value, textAlign: TextAlign.right, style: AppTextStyles.body())),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Anchor Details', style: AppTextStyles.heading()),
        actions: [
          IconButton(onPressed: _resync, icon: const Icon(Icons.sync)),
          IconButton(onPressed: _deleteAnchor, icon: const Icon(Icons.delete_forever)),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _mini3DPreview(),
        const SizedBox(height: 14),

        TextField(
          controller: _titleCtrl,
          decoration: InputDecoration(labelText: 'Title', filled: true, fillColor: AppColors.cardSoft, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: _descCtrl,
          maxLines: 4,
          decoration: InputDecoration(labelText: 'Description', filled: true, fillColor: AppColors.cardSoft, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),

        const SizedBox(height: 12),
        _stabilityWidget(),
        const SizedBox(height: 14),

        Card(
          color: AppColors.card,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              _metaInfoRow('Owner', anchor.owner),
              const SizedBox(height: 8),
              _metaInfoRow('Location', '${anchor.lat.toStringAsFixed(4)}, ${anchor.lng.toStringAsFixed(4)}'),
              const SizedBox(height: 8),
              _metaInfoRow('Distance', '${anchor.distanceMeters.toInt()} m'),
              const SizedBox(height: 8),
              _metaInfoRow('Created', anchor.createdAt.toLocal().toString().split('.').first),
              const SizedBox(height: 8),
              _metaInfoRow('Pinned', anchor.pinned ? 'Yes' : 'No'),
            ]),
          ),
        ),

        const SizedBox(height: 12),

        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isCalibrating ? null : _recalibrate,
              icon: _isCalibrating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.settings_backup_restore),
              label: const Text('Recalibrate'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() => anchor.pinned = !anchor.pinned);
              },
              icon: Icon(anchor.pinned ? Icons.push_pin : Icons.push_pin_outlined),
              label: Text(anchor.pinned ? 'Unpin' : 'Pin'),
            ),
          ),
        ]),

        const SizedBox(height: 12),

        ExpansionTile(
          backgroundColor: AppColors.card,
          title: Text('Advanced', style: AppTextStyles.body()),
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('View on Map'),
              onTap: () {
                // TODO: open map or pass to AR view
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open map (demo)')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy Deep Link'),
              onTap: () {
                // TODO: build deep link
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deep link copied (demo)')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Export Anchor JSON'),
              onTap: () {
                final encoded = const JsonEncoder.withIndent('  ').convert(anchor.toJson());
                showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: AppColors.surface, title: Text('Anchor JSON', style: AppTextStyles.title()), content: SingleChildScrollView(child: Text(encoded, style: AppTextStyles.caption())), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
              },
            ),
          ],
        ),

        const SizedBox(height: 18),

        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(48)),
          child: const Text('Save Changes'),
        ),

        const SizedBox(height: 20),
      ]),
    );
  }
}
