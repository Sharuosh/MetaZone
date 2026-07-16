import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'widgets/item_card.dart';
import 'widgets/filters_panel.dart';

class MarketplaceSearchScreen extends StatefulWidget {
  const MarketplaceSearchScreen({super.key});

  @override
  State<MarketplaceSearchScreen> createState() => _MarketplaceSearchScreenState();
}

class _MarketplaceSearchScreenState extends State<MarketplaceSearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showFilters = false;

  List<Map<String, dynamic>> _results = [];

  final List<Map<String, dynamic>> _mockItems = [
    {
      "title": "Cyber Neon Portal",
      "price": 12.99,
      "rating": 4.6,
    },
    {
      "title": "Floating Hologram Statue",
      "price": 8.50,
      "rating": 4.9,
    },
    {
      "title": "AR Graffiti Pack",
      "price": 5.99,
      "rating": 4.3,
    },
  ];

  void _performSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _results = _mockItems
          .where((item) => item["title"].toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Search Marketplace"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: AppTextStyles.body(),
                      decoration: const InputDecoration(
                        hintText: "Search AR assets...",
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => _performSearch(),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => _showFilters = !_showFilters),
                    icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // 🎛 FILTER PANEL
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showFilters
                ? FiltersPanel(
              initialFilters: {
                "type": "All",
                "priceMin": 0.0,
                "priceMax": 50.0,
                "minRating": 0.0,
                "sortBy": "Popular",
              },
              onApply: (filters) {
                print(filters);
                // هنا تقدر تحدّث نتائج البحث بالفلاتر
              },
            )
                : const SizedBox.shrink(),
          ),

          // 📦 RESULTS GRID
          Expanded(
            child: _results.isEmpty
                ? Center(
              child: Text(
                "No results found",
                style: AppTextStyles.caption(),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: .75,
              ),
              itemBuilder: (_, i) {
                final item = _results[i];

                return ItemCard(
                  title: item["title"],
                  type: "AR Asset",
                  price: (item["price"] as num).toDouble(),
                  rating: (item["rating"] as num).toDouble(),
                  icon: Icons.auto_awesome, // أو أيقونة حسب النوع
                  onOpenDetails: () {
                    // TODO: Navigate to product details
                  },
                  onPreview: () {
                    // TODO: Open AR preview
                  },
                  onAddToCart: () {
                    // TODO: Add to cart
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
