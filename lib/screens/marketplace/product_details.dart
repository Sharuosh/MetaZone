// File: lib/screens/marketplace/product_details.dart
// MetaZone — Product Details (Full-featured, design-ready)

import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

// A self-contained Product Details screen for MetaZone marketplace.
// - 3D viewer placeholder
// - Try in AR button (opens ARCameraLiveViewScreen)
// - Rating & reviews
// - Promo video placeholder
// - Product metadata, license, seller profile
// - Add to cart / Buy now
// - Similar products carousel (placeholder)

class ProductDetailsScreen extends StatefulWidget {
  final String id; // product id (demo)
  const ProductDetailsScreen({super.key, required this.id});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // Demo product data (replace with API)
  final Map<String, dynamic> _product = {
    'id': 'p_001',
    'title': 'Neon Portal — Holographic Gateway',
    'price': 6.99,
    'currency': 'USD',
    'images': [
      'https://picsum.photos/seed/p1/1200/900',
      'https://picsum.photos/seed/p2/1200/900',
      'https://picsum.photos/seed/p3/1200/900',
    ],
    'rating': 4.6,
    'reviews': 234,
    'category': 'Portals',
    'size': '3.4 MB',
    'downloads': 1240,
    'license': 'Personal Use — Commercial available',
    'seller': {
      'name': 'HoloWorks',
      'avatar': 'https://picsum.photos/seed/seller/200/200',
      'rating': 4.8,
      'sales': 520,
    },
    'description':
    'A cinematic neon portal that opens a short teleport animation. Optimized for mobile AR with low poly mesh and baked lighting. Works best on modern devices.',
    'highlights': [
      'Mobile-optimized mesh',
      'Dynamic glow & emissive map',
      'Shadow-friendly',
      'Physics-friendly (optional)',
    ],
  };

  int _selectedImage = 0;
  bool _inCart = false;
  int _qty = 1;

  void _openARTry() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'AR Preview will be connected to the new MetaZone AR runtime.',
          ),
        ),
      );
  }

  void _addToCart() {
    setState(() => _inCart = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
  }

  void _buyNow() {
    // In real app -> go to checkout with this product
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proceed to checkout (demo)')));
  }

  Widget _buildImageViewer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image / 3D viewer placeholder
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image: NetworkImage(_product['images'][_selectedImage]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // subtle overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: [Colors.black.withOpacity(.18), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.center),
            ),
          ),
          // 3D badge
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.surface.withOpacity(.85), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Row(children: [Icon(Icons.threed_rotation, size: 16, color: AppColors.primary), const SizedBox(width: 8), Text('3D Model', style: AppTextStyles.caption())]),
            ),
          ),
          // Try in AR button
          Positioned(
            right: 12,
            bottom: 12,
            child: ElevatedButton.icon(
              onPressed: _openARTry,
              icon: const Icon(Icons.vrpano, color: Colors.black),
              label: Text('Try in AR', style: AppTextStyles.body().copyWith(color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGradient.colors.first, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          // image thumbs
          Positioned(
            left: 12,
            bottom: 12,
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() => _selectedImage = i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 64,
                      decoration: BoxDecoration(
                        border: Border.all(color: i == _selectedImage ? AppColors.primary : Colors.transparent, width: 2),
                      ),
                      child: Image.network(_product['images'][i], fit: BoxFit.cover),
                    ),
                  ),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: (_product['images'] as List).length,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_product['title'], style: AppTextStyles.title(size: 18)),
              const SizedBox(height: 6),
              Row(children: [
                RatingWidget(rating: _product['rating'], count: _product['reviews']),
                const SizedBox(width: 12),
                Text(_product['category'], style: AppTextStyles.caption()),
              ]),
              const SizedBox(height: 8),
              Text('${_product['currency']} ${_product['price'].toStringAsFixed(2)}', style: AppTextStyles.heading(size: 18)),
            ],
          ),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
      ],
    );
  }

  Widget _buildHighlights() {
    final List<String> highlights = List<String>.from(_product['highlights']);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: highlights.map((h) => Chip(label: Text(h), backgroundColor: AppColors.card)).toList(),
    );
  }

  Widget _buildSellerCard() {
    final seller = _product['seller'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        CircleAvatar(radius: 28, backgroundImage: NetworkImage(seller['avatar'])),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(seller['name'], style: AppTextStyles.title(size: 14)),
            const SizedBox(height: 4),
            Row(children: [RatingWidget(rating: seller['rating'], compact: true), const SizedBox(width: 8), Text('${seller['sales']} sales', style: AppTextStyles.caption())]),
          ]),
        ),
        TextButton(onPressed: () {}, child: const Text('View Creator'))
      ]),
    );
  }

  Widget _buildActionBar() {
    return Row(children: [
      Expanded(
        child: OutlinedButton(
          onPressed: _addToCart,
          child: Text(_inCart ? 'In Cart' : 'Add to Cart'),
          style: OutlinedButton.styleFrom(backgroundColor: AppColors.card, foregroundColor: AppColors.text),
        ),
      ),
      const SizedBox(width: 12),
      ElevatedButton(
        onPressed: _buyNow,
        child: Text('Buy Now — ${_product['currency']} ${_product['price'].toStringAsFixed(2)}'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(160, 52)),
      ),
    ]);
  }

  Widget _buildSimilarProducts() {
    // placeholder carousel
    final List<Map<String, String>> sims = List.generate(6, (i) => {
      'id': 's_$i',
      'title': 'Related ${i + 1}',
      'image': 'https://picsum.photos/seed/sim$i/400/300'
    });

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () {
            // open another product (demo)
          },
          child: Container(
            width: 120,
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)), child: Image.network(sims[i]['image']!, height: 80, width: 120, fit: BoxFit.cover)),
              const SizedBox(height: 6),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text(sims[i]['title']!, style: AppTextStyles.caption(), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: sims.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, title: Text('Product', style: AppTextStyles.heading())),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _buildImageViewer(),
        const SizedBox(height: 14),
        _buildHeader(),
        const SizedBox(height: 12),

        // promo video placeholder
        Container(
          height: 140,
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.play_circle_outline, size: 36, color: AppColors.primary), const SizedBox(height: 8), Text('Promo Video (tap to play)', style: AppTextStyles.caption())])),
        ),

        const SizedBox(height: 12),

        Text('Highlights', style: AppTextStyles.title(size: 14)),
        const SizedBox(height: 8),
        _buildHighlights(),

        const SizedBox(height: 12),
        Text('Description', style: AppTextStyles.title(size: 14)),
        const SizedBox(height: 8),
        Text(_product['description'], style: AppTextStyles.body()),

        const SizedBox(height: 12),
        Text('Seller', style: AppTextStyles.title(size: 14)),
        const SizedBox(height: 8),
        _buildSellerCard(),

        const SizedBox(height: 12),
        Text('License', style: AppTextStyles.title(size: 14)),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: Text(_product['license'], style: AppTextStyles.body())),

        const SizedBox(height: 12),
        Text('FAQ', style: AppTextStyles.title(size: 14)),
        const SizedBox(height: 8),
        ExpansionTile(backgroundColor: AppColors.card, title: Text('Does it work on low-end devices?', style: AppTextStyles.body()), children: [Padding(padding: const EdgeInsets.all(12), child: Text('This asset is optimized for mobile. For best results use modern devices; fallback LODs are available.', style: AppTextStyles.caption()))]),
        ExpansionTile(backgroundColor: AppColors.card, title: Text('Can I use for commercial projects?', style: AppTextStyles.body()), children: [Padding(padding: const EdgeInsets.all(12), child: Text('Commercial license available — contact seller.', style: AppTextStyles.caption()))]),

        const SizedBox(height: 12),
        Text('Similar', style: AppTextStyles.title(size: 14)),
        const SizedBox(height: 8),
        _buildSimilarProducts(),

        const SizedBox(height: 18),
        _buildActionBar(),
        const SizedBox(height: 18),
      ]),
    );
  }
}

// ---------------------------------
// Small rating widget used inside the screen
// ---------------------------------
class RatingWidget extends StatelessWidget {
  final double rating;
  final int count;
  final bool compact;
  const RatingWidget({super.key, required this.rating, this.count = 0, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = ((rating - full) >= 0.5);

    return Row(children: [
      Row(children: List.generate(5, (i) {
        IconData icon;
        if (i < full) icon = Icons.star;
        else if (i == full && half) icon = Icons.star_half;
        else icon = Icons.star_border;
        return Icon(icon, size: compact ? 12 : 16, color: AppColors.primary);
      })),
      if (!compact) const SizedBox(width: 8),
      if (!compact) Text('${rating.toStringAsFixed(1)} (${count})', style: AppTextStyles.caption()),
    ]);
  }
}
