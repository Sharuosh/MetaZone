// File: lib/screens/ar/global_search/search_screen.dart
// GlobalSearchScreen — Full MetaZone version with tabs:
// 1) All (merged results)
// 2) Creators
// 3) Portals
// 4) AR Spots
// 5) AI Smart Suggestions (placeholder — hook your AI later)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../ar/create/ar_portal_viewer.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtl = TextEditingController();
  late TabController _tabs;
  String _query = '';

  final List<Map<String, dynamic>> _objects = [
    {"id": "obj_01", "title": "Nebula Gate", "type": "AR Object", "creator": "MetaUser", "icon": Icons.auto_awesome, "distance": "120m", "likes": 320, "views": 1200},
    {"id": "obj_02", "title": "Crystal Lamp", "type": "3D Asset", "creator": "Lina", "icon": Icons.light_mode, "distance": "1.2km", "likes": 90, "views": 820},
    {"id": "obj_03", "title": "Portal Gate", "type": "AR Portal", "creator": "ARMaster", "icon": Icons.door_front_door, "distance": "340m", "likes": 210, "views": 5400},
    {"id": "obj_04", "title": "Floating Orb", "type": "AR Object", "creator": "Hadi", "icon": Icons.blur_circular, "distance": "800m", "likes": 150, "views": 2600},
  ];

  final List<Map<String, dynamic>> _creators = [
    {"id": "u1", "name": "MetaUser", "bio": "AR artist & builder", "items": 24},
    {"id": "u2", "name": "Lina", "bio": "3D designer", "items": 12},
    {"id": "u3", "name": "ARMaster", "bio": "Portal maker", "items": 41},
  ];

  final List<Map<String, dynamic>> _portals = [
    {"id": "p1", "title": "Gateway Plaza", "creator": "MetaUser", "distance": "220m"},
    {"id": "p2", "title": "Moonwalk Portal", "creator": "Lina", "distance": "1.8km"},
  ];

  // AI suggestions (placeholder)
  List<String> _aiSuggestions = [
    "Try 'Nebula' — trending portal",
    "Explore creators near you",
    "Drop a portal at a landmark",
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    setState(() => _query = v.trim().toLowerCase());
  }

  List<Map<String, dynamic>> _filterObjects() {
    if (_query.isEmpty) return List.from(_objects);
    return _objects.where((o) {
      final t = o['title'].toString().toLowerCase();
      final c = o['creator'].toString().toLowerCase();
      final ty = o['type'].toString().toLowerCase();
      return t.contains(_query) || c.contains(_query) || ty.contains(_query);
    }).toList();
  }

  List<Map<String, dynamic>> _filterCreators() {
    if (_query.isEmpty) return List.from(_creators);
    return _creators.where((c) => c['name'].toString().toLowerCase().contains(_query) || c['bio'].toString().toLowerCase().contains(_query)).toList();
  }

  List<Map<String, dynamic>> _filterPortals() {
    if (_query.isEmpty) return List.from(_portals);
    return _portals.where((p) => p['title'].toString().toLowerCase().contains(_query) || p['creator'].toString().toLowerCase().contains(_query)).toList();
  }

  // ----------------- UI pieces -----------------
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchCtl,
        onChanged: _onSearchChanged,
        style: TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.cardSoft,
          hintText: "Search AR objects, creators, portals...",
          hintStyle: TextStyle(color: AppColors.textLight),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          suffixIcon: _query.isNotEmpty
              ? GestureDetector(
            onTap: () {
              _searchCtl.clear();
              _onSearchChanged('');
            },
            child: Icon(Icons.close, color: AppColors.textLight),
          )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _allTab() {
    final items = _filterObjects();
    return _resultsList(items);
  }

  Widget _resultsList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return Center(child: Text('No results', style: AppTextStyles.caption()));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final it = items[i];
        return GestureDetector(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                Icon(it['icon'], color: AppColors.primary, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(it['title'], style: AppTextStyles.title()),
                    const SizedBox(height: 6),
                    Text('${it['type']} • ${it['distance']}', style: AppTextStyles.caption()),
                  ]),
                ),
                Column(children: [Text('${it['likes']}', style: AppTextStyles.body()), const SizedBox(height: 4), Icon(Icons.favorite, size: 16, color: AppColors.primary)]),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _creatorsTab() {
    final items = _filterCreators();
    if (items.isEmpty) return Center(child: Text('No creators found', style: AppTextStyles.caption()));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final c = items[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            CircleAvatar(radius: 26, backgroundColor: AppColors.surface, child: Text(c['name'][0], style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c['name'], style: AppTextStyles.title()), const SizedBox(height: 4), Text(c['bio'], style: AppTextStyles.caption())])),
            Column(children: [Text('${c['items']}', style: AppTextStyles.title()), const SizedBox(height: 4), Text('Items', style: AppTextStyles.caption())]),
          ]),
        );
      },
    );
  }

  Widget _portalsTab() {
    final items = _filterPortals();
    if (items.isEmpty) return Center(child: Text('No portals', style: AppTextStyles.caption()));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final p = items[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            Icon(Icons.vrpano, color: AppColors.primary, size: 36),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p['title'], style: AppTextStyles.title()), const SizedBox(height: 6), Text('By ${p['creator']} • ${p['distance']}', style: AppTextStyles.caption())])),
            ElevatedButton(onPressed: () => _openPortal(p), child: const Text('Open'))
          ]),
        );
      },
    );
  }

  void _openPortal(Map<String, dynamic> p) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ARPortalViewerScreen(spotId: p['id'], title: p['title'], owner: p['creator'])));
  }

  Widget _spotsTab() {
    // For now reuse objects list but could be map/list hybrid
    final items = _filterObjects();
    return _resultsList(items);
  }

  Widget _aiTab() {
    final suggestions = _aiSuggestions.where((s) => _query.isEmpty ? true : s.toLowerCase().contains(_query)).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('AI Smart Suggestions', style: AppTextStyles.title()),
      const SizedBox(height: 12),
      for (final s in suggestions)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Row(children: [Expanded(child: Text(s, style: AppTextStyles.body())), IconButton(onPressed: () { _searchCtl.text = s; _onSearchChanged(s); _tabs.animateTo(0); }, icon: Icon(Icons.search))]),
        ),
      const SizedBox(height: 20),
      Text('Actions', style: AppTextStyles.caption()),
      const SizedBox(height: 8),
      ElevatedButton.icon(onPressed: () { /* trigger AI refresh */ }, icon: Icon(Icons.refresh), label: Text('Refresh Suggestions'))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Global AR Search', style: AppTextStyles.heading()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textLight,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Creators'),
                Tab(text: 'Portals'),
                Tab(text: 'AR Spots'),
                Tab(text: 'AI'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _allTab(),
                _creatorsTab(),
                _portalsTab(),
                _spotsTab(),
                _aiTab(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
