// trending_ar_screen.dart
// شاشة "Trending AR" كاملة ومتكاملة لتطبيق MetaZone
// تحتوي على: شريط ترشيح/ترتيب، كاردز ترند، شبكة ديناميكية، شريط أفقي للعناصر المميزة، واجهة معاينة AR (placeholder)، تفاصيل عنصر مع انيميشن، حفظ/مشاركة/لايك، ووحدات جاهزة للربط مع Firestore و Unity.
// متوافقة مع Flutter (Material3) — استخدم textTheme: titleLarge, bodyMedium, titleMedium

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ======================
// نموذج بيانات: Trending AR Item
// ======================
class TrendingARItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final int likes;
  final int views;
  final DateTime createdAt;
  final double rating; // 0..5
  final bool isFeatured;

  TrendingARItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.likes,
    required this.views,
    required this.createdAt,
    required this.rating,
    this.isFeatured = false,
  });
}

// Mock data
List<TrendingARItem> _mockTrending = List.generate(14, (i) {
  final r = Random();
  return TrendingARItem(
    id: 't_$i',
    title: 'MetaSpot ${i + 1}',
    subtitle: 'Creator ${r.nextInt(20) + 1}',
    description: 'An immersive AR piece that blends reality with creativity. Place, explore & interact!',
    imageUrl: 'https://picsum.photos/seed/trend$i/800/600',
    likes: r.nextInt(1200),
    views: r.nextInt(20000),
    createdAt: DateTime.now().subtract(Duration(days: r.nextInt(90))),
    rating: (r.nextDouble() * 5).clamp(1.0, 5.0),
    isFeatured: r.nextBool() && i.isEven,
  );
});

// ======================
// Trending AR Screen
// ======================
class TrendingARScreen extends StatefulWidget {
  const TrendingARScreen({Key? key}) : super(key: key);

  @override
  State<TrendingARScreen> createState() => _TrendingARScreenState();
}

class _TrendingARScreenState extends State<TrendingARScreen>
    with SingleTickerProviderStateMixin {
  // UI state
  List<TrendingARItem> items = [];
  bool _loading = true;
  String _query = '';
  String _sortBy = 'Trending'; // Trending, New, Top
  bool _showOnlyFeatured = false;
  late AnimationController _listAnimController;

  // Pagination
  final ScrollController _scrollController = ScrollController();
  int _loadedPages = 1;
  final int _perPage = 8;

  @override
  void initState() {
    super.initState();
    items = [];
    _listAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fetchInitial();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 300) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _listAnimController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitial() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      items = _mockTrending.take(_perPage).toList();
      _loading = false;
    });
    _listAnimController.forward();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() {
      _loadedPages = 1;
      items = _mockTrending.take(_perPage).toList();
      _loading = false;
    });
    _listAnimController.forward(from: 0);
  }

  void _loadMore() async {
    if (_loading) return;
    final total = _mockTrending.length;
    final nextItems = _mockTrending.skip(_loadedPages * _perPage).take(_perPage).toList();
    if (nextItems.isEmpty) return;
    setState(() {
      _loading = true;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      items.addAll(nextItems);
      _loadedPages += 1;
      _loading = false;
    });
  }

  List<TrendingARItem> _applyFilters(List<TrendingARItem> source) {
    var list = List<TrendingARItem>.from(source);
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((i) => i.title.toLowerCase().contains(q) || i.subtitle.toLowerCase().contains(q) || i.description.toLowerCase().contains(q)).toList();
    }
    if (_showOnlyFeatured) {
      list = list.where((i) => i.isFeatured).toList();
    }
    if (_sortBy == 'New') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortBy == 'Top') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      // Trending: mix of likes & views
      list.sort((a, b) => (b.likes + (b.views ~/ 20)).compareTo(a.likes + (a.views ~/ 20)));
    }
    return list;
  }

  // Launch AR preview (placeholder) — hook for Unity/AR integration
  void _openARPreview(TrendingARItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ARPreviewSheet(item: item),
    );
  }

  void _openDetails(TrendingARItem item) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TrendingDetailScreen(item: item)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _applyFilters(items);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trending AR', style: theme.textTheme.titleLarge),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(width: 10),
                  _buildSortMenu(),
                ],
              ),
            ),
            _buildFeaturedStrip(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: _loading && items.isEmpty
                    ? _buildShimmerGrid()
                    : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: filtered.length + (_loading ? 2 : 0),
                  itemBuilder: (ctx, idx) {
                    if (idx >= filtered.length) return _buildLoadingCard();
                    final item = filtered[idx];
                    return _buildGridCard(item);
                  },
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Create new Trending AR spot
          _openCreateSpotSheet();
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search trending spots, creators, tags...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
          onPressed: () {
            setState(() {
              _query = '';
            });
          },
          icon: const Icon(Icons.close),
        )
            : null,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      onChanged: (v) {
        setState(() {
          _query = v;
        });
      },
    );
  }

  Widget _buildSortMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          PopupMenuButton<String>(
            tooltip: 'Sort',
            itemBuilder: (_) => ['Trending', 'New', 'Top']
                .map((e) => PopupMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onSelected: (v) {
              setState(() {
                _sortBy = v;
              });
            },
            child: Row(
              children: [
                const Icon(Icons.swap_vert),
                const SizedBox(width: 6),
                Text(_sortBy),
                const SizedBox(width: 6),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Featured only',
            onPressed: () => setState(() => _showOnlyFeatured = !_showOnlyFeatured),
            icon: Icon(_showOnlyFeatured ? Icons.star : Icons.star_outline),
          )
        ],
      ),
    );
  }

  Widget _buildFeaturedStrip() {
    final featured = _mockTrending.where((e) => e.isFeatured).take(6).toList();
    if (featured.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 120,
      margin: const EdgeInsets.only(top: 6, bottom: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _openARPreview(featured[i]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  featured[i].imageUrl,
                  width: 160,
                  height: 90,
                  fit: BoxFit.cover,
                )
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 160,
                child: Text(featured[i].title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
              )
            ],
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: featured.length,
      ),
    );
  }

  Widget _buildGridCard(TrendingARItem item) {
    return GestureDetector(
      onTap: () => _openDetails(item),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child:Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                      )
                    ),
                  ),
                  if (item.isFeatured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [const Icon(Icons.star, size: 14, color: Colors.yellow), const SizedBox(width: 6), Text('Featured', style: Theme.of(context).textTheme.bodySmall)]),
                      ),
                    ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: InkWell(
                      onTap: () {
                        // like action
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Liked (demo)')));
                      },
                      child: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.favorite_border, size: 18)),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(child: Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall)),
                      const SizedBox(width: 6),
                      Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${item.views}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(color: Colors.white),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.78),
      itemCount: 6,
      itemBuilder: (_, __) => _buildLoadingCard(),
    );
  }

  void _openCreateSpotSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SizedBox(height: MediaQuery.of(ctx).size.height * 0.85, child: _CreateTrendingSpotSheet(onSave: (item) {
          setState(() {
            _mockTrending.insert(0, item);
            items.insert(0, item);
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Created (demo).')));
        })),
      ),
    );
  }
}

// ======================
// Detail screen
// ======================
class TrendingDetailScreen extends StatelessWidget {
  final TrendingARItem item;
  const TrendingDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title, style: Theme.of(context).textTheme.titleLarge)),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child:Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
            )
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold))),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined))
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(item.rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: 12),
                  Icon(Icons.remove_red_eye_outlined),
                  const SizedBox(width: 6),
                  Text('${item.views} views', style: Theme.of(context).textTheme.bodyMedium),
                ]),
                const SizedBox(height: 12),
                Text(item.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Launch AR for this specific item
                    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => _ARPreviewSheet(item: item));
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Open AR Preview'),
                ),
                const SizedBox(height: 18),
                const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: const Text('UserOne'), subtitle: const Text('Amazing idea!')),
                ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: const Text('ARFan'), subtitle: const Text('Loved it')),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ======================
// AR preview sheet (placeholder for UnityWidget / ARCore integration)
// ======================
class _ARPreviewSheet extends StatelessWidget {
  final TrendingARItem item;
  const _ARPreviewSheet({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.98,
      builder: (ctx, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 60, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)))),
            const SizedBox(height: 12),
            Text('AR Preview — ${item.title}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.vrpano_outlined, size: 88),
                    const SizedBox(height: 12),
                    Text('Unity/AR scene placeholder', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Replace with actual UnityWidget call
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Launching Unity/AR (placeholder)')));
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play AR Scene'),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ======================
// Create Trending Spot sheet
// ======================
class _CreateTrendingSpotSheet extends StatefulWidget {
  final void Function(TrendingARItem) onSave;
  const _CreateTrendingSpotSheet({Key? key, required this.onSave}) : super(key: key);

  @override
  State<_CreateTrendingSpotSheet> createState() => _CreateTrendingSpotSheetState();
}

class _CreateTrendingSpotSheetState extends State<_CreateTrendingSpotSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _subtitle = TextEditingController();
  final _desc = TextEditingController();
  final _image = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _desc.dispose();
    _image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Container(width: 60, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 12),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text('Create Trending AR Spot', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                  const SizedBox(height: 8),
                  TextFormField(controller: _subtitle, decoration: const InputDecoration(labelText: 'Subtitle / Creator')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _desc, maxLines: 4, decoration: const InputDecoration(labelText: 'Description'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                  const SizedBox(height: 8),
                  TextFormField(controller: _image, decoration: const InputDecoration(labelText: 'Image URL (optional)')),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _saving = true);
                      await Future.delayed(const Duration(milliseconds: 700));
                      final newItem = TrendingARItem(
                        id: 't_${DateTime.now().millisecondsSinceEpoch}',
                        title: _title.text.trim(),
                        subtitle: _subtitle.text.trim(),
                        description: _desc.text.trim(),
                        imageUrl: _image.text.isNotEmpty ? _image.text : 'https://picsum.photos/seed/new/800/600',
                        likes: 0,
                        views: 0,
                        createdAt: DateTime.now(),
                        rating: 4.0,
                        isFeatured: false,
                      );
                      widget.onSave(newItem);
                      setState(() => _saving = false);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Create'),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ======================
// End of file
// TODOs / Integration notes:
// - Replace _mockTrending with Firestore stream: use StreamBuilder and query for trending order (composite of likes/views/recent)
// - Add analytics events on open, share, like, view
// - Replace _ARPreviewSheet "Play AR Scene" with UnityWidget or ARCore/ARKit native view and pass item.id for scene binding
// - Add offline caching for images using cached_network_image (already referenced)
// - Add localization and RTL support (text is generic English; adapt Arabic strings if desired)
// - Dependencies to add to pubspec.yaml:
//   cached_network_image: ^3.2.3
//   shimmer: ^2.0.0
//   flutter_staggered_grid_view: ^0.6.2 (optional)
// - Make sure to use Material 3 theme or adapt textTheme names used above
