// File: lib/screens/marketplace/home1.dart
// Marketplace Home — MetaZone
// Clean + corrected version

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class MarketplaceHomeScreen extends StatefulWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  State<MarketplaceHomeScreen> createState() => _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends State<MarketplaceHomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _activeCategory = 'All';

  // DEMO DATA
  final List<String> _categories = [
    'All',
    'Environments',
    'Portals',
    'Props',
    'Characters',
    'Audio',
    'Textures',
  ];

  final List<Map<String, dynamic>> _items = List.generate(12, (i) {
    return {
      'id': 'it_$i',
      'title': 'Neon Object ${i + 1}',
      'seller': i % 2 == 0 ? 'CreatorA' : 'StudioB',
      'price': (i + 1) * 3.5,
      'currency': 'USD',
      'rating': (4.0 + (i % 5) * 0.1),
      'reviews': 10 + i,
      'isARReady': i % 3 == 0,
      'image': 'https://picsum.photos/seed/market$i/800/600',
      'badge': i % 4 == 0 ? 'Limited' : null,
    };
  });

  List<Map<String, dynamic>> get _filteredItems {
    final q = _query.trim().toLowerCase();
    return _items.where((it) {
      if (_activeCategory != 'All' &&
          !_matchesCategory(it, _activeCategory)) return false;
      if (q.isEmpty) return true;
      return (it['title'] as String).toLowerCase().contains(q) ||
          (it['seller'] as String).toLowerCase().contains(q);
    }).toList();
  }

  bool _matchesCategory(Map<String, dynamic> it, String cat) {
    if (cat == 'All') return true;
    return (it['title'] as String)
        .toLowerCase()
        .contains(cat.toLowerCase().split(' ').first);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openItem(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FakeProductDetails(item: item)),
    );
  }

  void _openCategory(String cat) {
    setState(() {
      _activeCategory = cat;
    });
  }

  void _onSearchChanged(String v) {
    setState(() => _query = v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Marketplace', style: AppTextStyles.heading()),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.shopping_cart_outlined,
                  color: AppColors.text)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildPromoBanner(),
            const SizedBox(height: 14),
            _buildCategories(),
            const SizedBox(height: 18),
            _sectionTitle('Featured', action: 'See all', onTap: () {}),
            const SizedBox(height: 12),
            _featuredRow(),
            const SizedBox(height: 18),
            _sectionTitle('All Items'),
            const SizedBox(height: 12),
            _itemsGrid(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.search),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration.collapsed(
                hintText: 'Search assets, creators, tags...',
              ),
              style: AppTextStyles.body(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.surface,
              ),
              child: Row(
                children: [
                  Text('Filters', style: AppTextStyles.caption()),
                  const SizedBox(width: 6),
                  const Icon(Icons.filter_list, size: 18),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // PROMO BANNER
  Widget _buildPromoBanner() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.neonGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySoft,
            blurRadius: 18,
            spreadRadius: 1,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('MetaZone Market',
                      style: AppTextStyles
                          .title(size: 18)
                          .copyWith(color: Colors.black)),
                  const SizedBox(height: 6),
                  Text(
                    'AR ready assets & exclusive drops — tap to explore.',
                    style: AppTextStyles.body().copyWith(color: Colors.black87),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {},
              child: const Text('Explore',
                  style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  // CATEGORY CHIPS
  Widget _buildCategories() {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final c = _categories[i];
          final active = c == _activeCategory;
          return GestureDetector(
            onTap: () => _openCategory(c),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary.withOpacity(.12)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  c,
                  style: AppTextStyles
                      .caption(size: 13)
                      .copyWith(color: active ? AppColors.primary : AppColors.text),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title, {String? action, VoidCallback? onTap}) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.title(size: 16)),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: AppTextStyles.caption().copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  // FEATURED HORIZONTAL ROW
  Widget _featuredRow() {
    final featured = _filteredItems.take(4).toList();
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: featured.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final it = featured[i];
          return GestureDetector(
            onTap: () => _openItem(it),
            child: Container(
              width: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      it['image'],
                      width: 120,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(it['title'], style: AppTextStyles.title(size: 14)),
                        const SizedBox(height: 6),
                        Text(it['seller'], style: AppTextStyles.caption()),
                        const SizedBox(height: 8),
                        Text(
                          '\$${(it['price']).toStringAsFixed(2)} ${it['currency']}',
                          style: AppTextStyles.heading(size: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // GRID
  Widget _itemsGrid() {
    final list = _filteredItems;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text('No items found', style: AppTextStyles.caption()),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: .78,
      ),
      itemBuilder: (_, i) => _ItemCard(item: list[i], onTap: _openItem),
    );
  }
}

// -----------------------------
// Item card — FIXED
// -----------------------------
class _ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final void Function(Map<String, dynamic>) onTap;

  const _ItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(item),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE + AR BADGE
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // FIXED AR BADGE
                  if (item['isARReady'] == true)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.view_in_ar,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'AR',
                              style: AppTextStyles
                                  .caption()
                                  .copyWith(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // INFO
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: AppTextStyles.title(size: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          item['seller'],
                          style: AppTextStyles.caption(size: 11),
                        ),
                        const Spacer(),
                        Text(
                          "\$${(item['price']).toStringAsFixed(2)}",
                          style: AppTextStyles.heading(size: 13),
                        ),
                      ],
                    ),
                  ]),
            )
          ],
        ),
      ),
    );
  }
}

// ------------------------------------
// Fake product details — placeholder
// ------------------------------------
class _FakeProductDetails extends StatelessWidget {
  final Map<String, dynamic> item;
  const _FakeProductDetails({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(backgroundColor: AppColors.surface, title: Text(item['title'], style: AppTextStyles.heading())),
      body: Center(
        child: Text(
          'Product details placeholder for "${item['title']}"',
          style: AppTextStyles.body(),
        ),
      ),
    );
  }
}
