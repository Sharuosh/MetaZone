// File: lib/screens/home/live_ar_feed_screen.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/theme.dart';

// ⭐ IMPORT شاشة التفاصيل الأصلية هنا
import '../ar/spot_details/ar_spot_details_screen.dart';

class LiveARFeedScreen extends StatefulWidget {
  const LiveARFeedScreen({super.key});

  @override
  State<LiveARFeedScreen> createState() => _LiveARFeedScreenState();
}

enum FeedFilter { nearby, trending, latest }

class _LiveARFeedScreenState extends State<LiveARFeedScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  FeedFilter _filter = FeedFilter.nearby;
  bool _loading = true;
  bool _loadingMore = false;
  bool _showGrid = false;
  String _query = "";
  List<Map<String, dynamic>> _items = [];
  int _page = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchInitial();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchInitial() async {
    setState(() {
      _loading = true;
      _items = [];
      _page = 0;
      _hasMore = true;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    _items = _generateMock(page: 0);
    setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    await _fetchInitial();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading) return;
    if (_scrollCtrl.position.pixels >
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(milliseconds: 900));
    final next = _generateMock(page: ++_page);
    if (next.isEmpty) {
      _hasMore = false;
    } else {
      _items.addAll(next);
    }
    setState(() => _loadingMore = false);
  }

  List<Map<String, dynamic>> _generateMock(
      {int page = 0, int perPage = 6}) {
    if (page > 4) return [];
    final now = DateTime.now();
    final rng = Random(1000 + page);
    return List.generate(perPage, (i) {
      final id = 'obj_${page}_$i';
      final dist = rng.nextInt(2000) + 50;
      final likes = rng.nextInt(900);
      final views = rng.nextInt(4000);
      final rare = rng.nextBool()
          ? "Common"
          : (rng.nextInt(10) > 7 ? "Legendary" : "Rare");
      return {
        "id": id,
        "title": "AR Object #${page * perPage + i + 1}",
        "owner": rng.nextBool() ? "Alice" : "MetaUser",
        "distance": dist,
        "likes": likes,
        "views": views,
        "rarity": rare,
        "timestamp": now.subtract(
            Duration(minutes: rng.nextInt(120))),
        "image": null,
        "liked": false,
      };
    });
  }

  List<Map<String, dynamic>> get _filteredItems {
    final q = _query.trim().toLowerCase();
    var list = List<Map<String, dynamic>>.from(_items);
    if (q.isNotEmpty) {
      list = list
          .where((it) =>
      it['title'].toLowerCase().contains(q) ||
          it['owner'].toLowerCase().contains(q))
          .toList();
    }

    switch (_filter) {
      case FeedFilter.nearby:
        list.sort((a, b) =>
            (a['distance'] as int).compareTo(b['distance'] as int));
        break;
      case FeedFilter.trending:
        list.sort((a, b) =>
            (b['likes'] as int).compareTo(a['likes'] as int));
        break;
      case FeedFilter.latest:
        list.sort((a, b) => (b['timestamp'] as DateTime)
            .compareTo(a['timestamp'] as DateTime));
        break;
    }
    return list;
  }

  void _toggleLike(String id) {
    final idx = _items.indexWhere((e) => e['id'] == id);
    if (idx == -1) return;
    setState(() {
      _items[idx]['liked'] = !(_items[idx]['liked'] as bool);
      if (_items[idx]['liked'] as bool) {
        _items[idx]['likes'] =
            (_items[idx]['likes'] as int) + 1;
      } else {
        _items[idx]['likes'] = max(
            0, (_items[idx]['likes'] as int) - 1);
      }
    });
  }

  // ⭐ فتح شاشة التفاصيل الحقيقيّة
  void _openDetails(Map<String, dynamic> obj) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ARSpotDetailsScreen(spotId: obj["id"]),
      ),
    );
  }

  void _openInfo(Map<String, dynamic> obj) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ObjectInfoPage(data: obj),
      ),
    );
  }

  void _openARViewer(Map<String, dynamic> obj) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _ARViewerPage(id: obj['id'], title: obj['title']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text("Live AR Feed",
            style: AppTextStyles.heading(size: 18)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.map_outlined,
                color: AppColors.text),
          ),
          IconButton(
            onPressed: () => _showFilterSheet(),
            icon: Icon(Icons.filter_list,
                color: AppColors.text),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: Column(
          children: [
            _buildSearchBar(),
            _buildSegmentControl(),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? _buildLoadingPlaceholder()
                  : items.isEmpty
                  ? _buildEmptyState()
                  : _showGrid
                  ? _buildGrid(items)
                  : _buildList(items),
            ),
            if (_loadingMore)
              Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(
                    color: AppColors.primary),
              ),
          ],
        ),
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.add, color: Colors.black),
        label: Text("Create", style: AppTextStyles.body()),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(
                  horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: AppColors.textSoft),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: AppTextStyles.body(),
                      decoration: InputDecoration(
                        hintText:
                        "Search objects, creators...",
                        hintStyle: AppTextStyles.caption(),
                        border: InputBorder.none,
                      ),
                      onChanged: (v) =>
                          setState(() => _query = v),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _query = "");
                      },
                      child: Icon(Icons.close,
                          color: AppColors.textSoft),
                    )
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () =>
                setState(() => _showGrid = !_showGrid),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                  _showGrid
                      ? Icons.view_agenda
                      : Icons.grid_view,
                  color: AppColors.text),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSegmentControl() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _segButton("Nearby", FeedFilter.nearby),
            _segButton("Trending", FeedFilter.trending),
            _segButton("Latest", FeedFilter.latest),
          ],
        ),
      ),
    );
  }

  Widget _segButton(String label, FeedFilter f) {
    final active = _filter == f;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = f),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: active
                ? AppColors.primarySoft.withOpacity(.12)
                : Colors.transparent,
          ),
          child: Text(label,
              style: TextStyle(
                  color: active
                      ? AppColors.primary
                      : AppColors.textLight,
                  fontWeight: active
                      ? FontWeight.w700
                      : FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items) {
    return ListView.separated(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
      const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildCard(items[i]),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildCard(items[i]),
    );
  }

  Widget _buildCard(Map<String, dynamic> obj) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _openDetails(obj),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                gradient: RadialGradient(
                  colors: [
                    AppColors.primarySoft.withOpacity(.18),
                    AppColors.card
                  ],
                  center: Alignment(-0.2, -0.6),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                      child: Icon(Icons.view_in_ar,
                          size: 46,
                          color: AppColors.primary)),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                        BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.border),
                      ),
                      child: Text(obj['rarity'],
                          style: AppTextStyles.caption(
                              size: 12)),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              _toggleLike(obj['id']),
                          icon: Icon(
                              obj['liked']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: obj['liked']
                                  ? AppColors.danger
                                  : AppColors.textLight),
                        ),
                        IconButton(
                          onPressed: () =>
                              _openInfo(obj),
                          icon: Icon(
                              Icons.info_outline,
                              color:
                              AppColors.textLight),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(obj['title'],
                    style: AppTextStyles.title(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text(_timeAgo(obj['timestamp']),
                  style: AppTextStyles.caption()),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.cardSoft,
                  child: Text(obj['owner'][0],
                      style: TextStyle(
                          color: AppColors.primary))),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(obj['owner'],
                      style: AppTextStyles.body(
                          size: 13))),
              const SizedBox(width: 8),
              Icon(Icons.location_on,
                  size: 16,
                  color: AppColors.textSoft),
              const SizedBox(width: 4),
              Text("${obj['distance']} m",
                  style: AppTextStyles.caption()),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                    BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.visibility,
                        size: 16,
                        color: AppColors.textSoft),
                    const SizedBox(width: 6),
                    Text("${obj['views']}",
                        style: AppTextStyles.caption()),
                    const SizedBox(width: 12),
                    Icon(Icons.favorite,
                        size: 16,
                        color: AppColors.textSoft),
                    const SizedBox(width: 6),
                    Text("${obj['likes']}",
                        style: AppTextStyles.caption()),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _openARViewer(obj),
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.primary,
                    foregroundColor:
                    Colors.black),
                child: Row(
                  children: [
                    Icon(Icons.vrpano, size: 16),
                    const SizedBox(width: 8),
                    Text("Enter AR",
                        style: AppTextStyles.body()),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
            child: Icon(Icons.cloud_off,
                size: 64,
                color: AppColors.textSoft)),
        const SizedBox(height: 12),
        Center(
            child: Text("No AR posts found",
                style: AppTextStyles.title())),
        const SizedBox(height: 8),
        Center(
            child: Text(
                "Try changing filter or create the first AR post.",
                style: AppTextStyles.caption())),
      ],
    );
  }

  Widget _buildLoadingPlaceholder() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      itemCount: 5,
      itemBuilder: (_, i) {
        return Container(
          margin:
          const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius:
              BorderRadius.circular(12),
              border:
              Border.all(color: AppColors.border)),
          child: Column(
            children: [
              Container(
                  height: 140,
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                      BorderRadius.circular(8))),
              const SizedBox(height: 8),
              Container(
                  height: 12,
                  width: double.infinity,
                  color: AppColors.surface),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                    height: 10,
                    width: 120,
                    color: AppColors.surface)
              ]),
            ],
          ),
        );
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Feed settings",
                  style: AppTextStyles.title()),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _switchTile("Show nearby",
                          Icons.location_on, true)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _switchTile("Show images",
                          Icons.image, true)),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context),
                child: Text("Save"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _switchTile(
      String title, IconData icon, bool value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
              child:
              Text(title, style: AppTextStyles.body())),
          Switch(value: value, onChanged: (_) {}),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    return "${diff.inDays}d";
  }
}

class _ARViewerPage extends StatelessWidget {
  final String id;
  final String title;
  const _ARViewerPage(
      {required this.id, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text("AR Viewer"),
          backgroundColor: AppColors.surface),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.vrpano,
                size: 90, color: AppColors.primary),
            const SizedBox(height: 12),
            Text("Entering AR: $title",
                style: AppTextStyles.title()),
            const SizedBox(height: 6),
            Text("ID: $id",
                style: AppTextStyles.caption()),
            const SizedBox(height: 18),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Exit"))
          ],
        ),
      ),
    );
  }
}

class _ObjectInfoPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ObjectInfoPage(
      {required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text("Object Info"),
          backgroundColor: AppColors.surface),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(data['title'],
                style: AppTextStyles.heading()),
            const SizedBox(height: 8),
            Text("Owner: ${data['owner']}",
                style: AppTextStyles.body()),
            const SizedBox(height: 8),
            Text(
                "Distance: ${data['distance']} m • Likes: ${data['likes']}",
                style: AppTextStyles.caption()),
            const SizedBox(height: 12),
            Text(data['description'] ??
                "No description",
                style: AppTextStyles.body()),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context),
                child: Text("Close"))
          ],
        ),
      ),
    );
  }
}

class _ObjectDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ObjectDetailsPage(
      {required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text("Object Details"),
          backgroundColor: AppColors.surface),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(12),
                color: AppColors.card,
              ),
              child: Center(
                child: Icon(Icons.view_in_ar,
                    size: 74,
                    color: AppColors.primary),
              )),
          const SizedBox(height: 12),
          Text(data['title'],
              style: AppTextStyles.heading()),
          const SizedBox(height: 6),
          Text("By ${data['owner']} • ${data['rarity']}",
              style: AppTextStyles.caption()),
          const SizedBox(height: 12),
          Text("Views: ${data['views']}  •  Likes: ${data['likes']}",
              style: AppTextStyles.body()),
          const SizedBox(height: 12),
          Text(
              data['description'] ??
                  "Detailed info not available.",
              style: AppTextStyles.body()),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back"))
        ],
      ),
    );
  }
}
