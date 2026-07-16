// lib/screens/ar/anchors/anchors_manager_screen.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../models/anchor_model.dart';
import 'anchor_details_screen.dart';




class AnchorsManagerScreen extends StatefulWidget {
  const AnchorsManagerScreen({super.key});

  @override
  State<AnchorsManagerScreen> createState() => _AnchorsManagerScreenState();
}

class _AnchorsManagerScreenState extends State<AnchorsManagerScreen> {
  final List<AnchorModel> _anchors = [];
  bool _isSyncing = false;
  String _filter = 'all'; // all / pinned / recent / unstable
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadDemoAnchors();
  }

  void _loadDemoAnchors() {
    _anchors.addAll([
      AnchorModel(
        id: 'a1',
        title: 'Floating Hologram',
        description: 'Interactive sculpture near the cafe.',
        lat: 30.0444,
        lng: 31.2357,
        pinned: true,
        owner: 'Abdel',
        stability: 0.92,
        distanceMeters: 120,
      ),
      AnchorModel(
        id: 'a2',
        title: 'Portal Room #4',
        description: 'Cinematic portal inside the mall.',
        lat: 30.0450,
        lng: 31.2365,
        pinned: false,
        owner: 'CreatorX',
        stability: 0.68,
        distanceMeters: 640,
      ),
      AnchorModel(
        id: 'a3',
        title: 'Graffiti AR Wall',
        description: 'Hidden street art augmented mural.',
        lat: 30.0462,
        lng: 31.2349,
        pinned: false,
        owner: 'StreetAR',
        stability: 0.83,
        distanceMeters: 340,
      ),
    ]);
  }

  List<AnchorModel> get _visibleAnchors {
    final byFilter = _anchors.where((a) {
      if (_filter == 'pinned') return a.pinned;
      if (_filter == 'recent') {
        final cutoff = DateTime.now().subtract(const Duration(days: 7));
        return a.createdAt.isAfter(cutoff);
      }
      if (_filter == 'unstable') return a.stability < 0.7;
      return true;
    }).toList();

    if (_query.trim().isEmpty) return byFilter;
    final q = _query.toLowerCase();
    return byFilter.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.description.toLowerCase().contains(q) ||
          a.owner.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _syncWithCloud() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    // TODO: Integrate with Firestore / backend to sync anchors
    setState(() => _isSyncing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anchors synced with cloud (demo)')),
      );
    }
  }

  void _openDetails(AnchorModel a) async {
    // open details and catch possible updates
    final changed = await Navigator.push<AnchorModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => AnchorDetailsScreen(anchor: a),
      ),
    );

    if (changed != null) {
      setState(() {
        final index = _anchors.indexWhere((x) => x.id == changed.id);
        if (index >= 0) _anchors[index] = changed;
      });
    }
  }

  void _deleteAnchor(AnchorModel a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Anchor?', style: AppTextStyles.title()),
        content: Text('Permanently remove "${a.title}"?', style: AppTextStyles.body()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _anchors.removeWhere((x) => x.id == a.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anchor deleted (demo)')));
            },
            child: Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _createAnchor() {
    final id = 'a_${DateTime.now().millisecondsSinceEpoch}';
    final newA = AnchorModel(
      id: id,
      title: 'New Anchor ${_anchors.length + 1}',
      lat: 30.044 + Random().nextDouble() * 0.01,
      lng: 31.235 + Random().nextDouble() * 0.01,
      stability: 0.7 + Random().nextDouble() * 0.25,
      distanceMeters: 50.0 + Random().nextDouble() * 800.0,
    );
    setState(() => _anchors.insert(0, newA));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anchor created (demo)')));
  }

  void _exportAll() {
    final jsonList = _anchors.map((a) => a.toJson()).toList();
    final encoded = const JsonEncoder.withIndent('  ').convert(jsonList);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Export Anchors (JSON)', style: AppTextStyles.title()),
        content: SizedBox(width: double.maxFinite, child: SingleChildScrollView(child: Text(encoded, style: AppTextStyles.caption()))),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        const Icon(Icons.search, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            decoration: const InputDecoration.collapsed(hintText: 'Search anchors, owner, description...'),
            onChanged: (v) => setState(() => _query = v),
            style: AppTextStyles.body(),
          ),
        ),
        PopupMenuButton<String>(
          color: AppColors.surface,
          onSelected: (v) => setState(() => _filter = v),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'all', child: Text('All')),
            PopupMenuItem(value: 'pinned', child: Text('Pinned')),
            PopupMenuItem(value: 'recent', child: Text('Recent (7d)')),
            PopupMenuItem(value: 'unstable', child: Text('Unstable (<70%)')),
          ],
          child: Row(children: [Text(_filter.toUpperCase(), style: AppTextStyles.caption(size: 12)), const Icon(Icons.arrow_drop_down)]),
        )
      ]),
    );
  }

  Widget _anchorCard(AnchorModel a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: a.pinned ? AppColors.primary.withOpacity(.2) : AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: a.pinned ? AppColors.primary : AppColors.surface,
          child: Text(a.title[0].toUpperCase(), style: TextStyle(color: a.pinned ? Colors.black : AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(a.title, style: AppTextStyles.title()),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text('${a.owner} • ${a.distanceMeters.toInt()}m away', style: AppTextStyles.caption(size: 12)),
          const SizedBox(height: 4),
          Row(children: [_stabilityBadge(a.stability), const SizedBox(width: 8), Text(a.createdAt.toLocal().toString().split('.').first, style: AppTextStyles.caption(size: 11))]),
        ]),
        trailing: PopupMenuButton<String>(
          color: AppColors.surface,
          onSelected: (k) {
            if (k == 'open') _openDetails(a);
            if (k == 'toggle') setState(() => a.pinned = !a.pinned);
            if (k == 'export') _exportSingle(a);
            if (k == 'delete') _deleteAnchor(a);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'open', child: Text('Open')),
            PopupMenuItem(value: 'toggle', child: Text(a.pinned ? 'Unpin' : 'Pin')),
            const PopupMenuItem(value: 'export', child: Text('Export (JSON)')),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.redAccent))),
          ],
        ),
        onTap: () => _openDetails(a),
      ),
    );
  }

  Widget _stabilityBadge(double value) {
    Color color;
    String label;
    if (value >= 0.85) {
      color = Colors.greenAccent;
      label = 'Stable';
    } else if (value >= 0.7) {
      color = Colors.orangeAccent;
      label = 'OK';
    } else {
      color = AppColors.danger;
      label = 'Unstable';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(.25))),
      child: Row(children: [Text(label, style: AppTextStyles.caption()), const SizedBox(width: 6), Text('${(value * 100).toInt()}%', style: AppTextStyles.caption())]),
    );
  }

  void _exportSingle(AnchorModel a) {
    final encoded = const JsonEncoder.withIndent('  ').convert(a.toJson());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Anchor JSON', style: AppTextStyles.title()),
        content: SizedBox(width: double.maxFinite, child: SingleChildScrollView(child: Text(encoded, style: AppTextStyles.caption()))),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _mapPreview() {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Stack(children: [
        Center(child: Text('Map / AR Scene Preview (placeholder)', style: AppTextStyles.caption())),
        Positioned(
          right: 10,
          top: 10,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              // TODO: open full map / AR view and center on selected anchor
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open full map (demo)')));
            },
            icon: const Icon(Icons.map),
            label: const Text('Open Map'),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Anchors Manager', style: AppTextStyles.heading()),
        actions: [
          IconButton(
            onPressed: _isSyncing ? null : _syncWithCloud,
            icon: _isSyncing ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync),
          ),
          IconButton(onPressed: _exportAll, icon: const Icon(Icons.download)),
        ],
      ),
      body: Column(children: [
        const SizedBox(height: 10),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _searchBar()),
        const SizedBox(height: 8),
        _mapPreview(),
        const SizedBox(height: 6),
        Expanded(
          child: _visibleAnchors.isEmpty
              ? Center(child: Text('No anchors found', style: AppTextStyles.caption()))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _visibleAnchors.length,
            itemBuilder: (_, i) => _anchorCard(_visibleAnchors[i]),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createAnchor,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('New Anchor'),
      ),
    );
  }
}
