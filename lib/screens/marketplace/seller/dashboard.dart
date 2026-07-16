// File: lib/screens/marketplace/seller/dashboard.dart
// MetaZone — Seller Dashboard (Elegant Neon Edition)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// navigate to seller modules (ensure files exist)
import 'upload_item.dart';
import 'manage_listings.dart';
import 'orders.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard>
    with TickerProviderStateMixin {
  // Demo metrics (replace with real data / API)
  int totalItems = 12;
  int totalSales = 342;
  double revenue = 1284.50;
  int followers = 890;

  // sample lists
  final List<Map<String, dynamic>> _topItems = List.generate(
    4,
        (i) => {
      'id': 'p_$i',
      'title': ['Neon Portal', 'Holo Sticker Pack', 'Mini Sculpture', 'AR Light'][i],
      'sales': (100 - i * 12),
      'image': 'https://picsum.photos/seed/seller$i/400/300',
      'revenue': (200 - i * 15) + 0.0,
    },
  );

  final List<Map<String, dynamic>> _recentOrders = List.generate(
    5,
        (i) => {
      'id': 'o_$i',
      'buyer': 'User${i + 11}',
      'item': ['Neon Portal', 'AR Light', 'Mini Sculpture', 'Holo Sticker'][i % 4],
      'amount': (5.0 + i * 2),
      'date': DateTime.now().subtract(Duration(hours: i * 6)),
    },
  );

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.06).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _goToUpload() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => UploadARItemScreen()));
  void _goToListings() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => ManageListingsScreen()));
  void _goToOrders() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => OrdersScreen()));

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Seller Dashboard', style: AppTextStyles.heading()),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _headerRow(isWide),
              const SizedBox(height: 14),
              Expanded(
                child: isWide ? _wideLayout() : _columnLayout(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _pulseAnim,
        child: FloatingActionButton.extended(
          onPressed: _goToUpload,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.cloud_upload_outlined, color: Colors.black),
          label: Text('Upload New Item', style: AppTextStyles.body().copyWith(color: Colors.black)),
        ),
      ),
    );
  }

  Widget _headerRow(bool isWide) {
    return Row(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.primary.withOpacity(.12),
          child: const Icon(Icons.storefront, size: 30, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Abdelrahman', style: AppTextStyles.title()),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.neonGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Creator', style: AppTextStyles.body(size: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Marketplace • MetaZone', style: AppTextStyles.caption()),
            ],
          ),
        ),
        if (isWide)
          Row(
            children: [
              _smallStat('Items', totalItems.toString()),
              const SizedBox(width: 12),
              _smallStat('Sales', totalSales.toString()),
              const SizedBox(width: 12),
              _smallStat('Revenue', '\$${revenue.toStringAsFixed(2)}'),
            ],
          )
      ],
    );
  }

  Widget _smallStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: AppTextStyles.title(size: 14)),
        Text(label, style: AppTextStyles.caption(size: 12)),
      ],
    );
  }

  Widget _columnLayout() {
    return ListView(
      children: [
        _metricsRow(),
        const SizedBox(height: 12),
        _miniChartCard(),
        const SizedBox(height: 12),
        _sectionTitle('Top Items'),
        const SizedBox(height: 8),
        _topItemsList(horizontal: true),
        const SizedBox(height: 12),
        _sectionTitle('Recent Orders'),
        const SizedBox(height: 8),
        _recentOrdersList(),
      ],
    );
  }

  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _metricsRow(),
              const SizedBox(height: 12),
              _miniChartCard(),
              const SizedBox(height: 12),
              _sectionTitle('Top Items'),
              const SizedBox(height: 8),
              _topItemsList(horizontal: false),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _actionsCard(),
              const SizedBox(height: 12),
              _sectionTitle('Recent Orders'),
              const SizedBox(height: 8),
              Expanded(child: _recentOrdersList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _metricCard('Total Items', totalItems.toString(), Icons.inventory_2_outlined),
        _metricCard('Total Sales', totalSales.toString(), Icons.bar_chart),
        _metricCard('Revenue', '\$${revenue.toStringAsFixed(2)}', Icons.attach_money),
        _metricCard('Followers', followers.toString(), Icons.people_alt_outlined),
      ],
    );
  }

  Widget _metricCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: AppTextStyles.title()),
                  const SizedBox(height: 6),
                  Text(title, style: AppTextStyles.caption()),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _miniChartCard() {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Activity (7 days)', style: AppTextStyles.title(size: 14)),
              Text('Details', style: AppTextStyles.caption(size: 12).copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text('(Chart placeholder)\nIntegrate charts library later', textAlign: TextAlign.center, style: AppTextStyles.caption()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Row(
      children: [
        Text(t, style: AppTextStyles.title(size: 16)),
        const Spacer(),
        GestureDetector(onTap: _goToListings, child: Text('Manage', style: AppTextStyles.caption().copyWith(color: AppColors.primary))),
      ],
    );
  }

  Widget _topItemsList({required bool horizontal}) {
    if (horizontal) {
      return SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _topItems.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final it = _topItems[i];
            return _topItemCard(it);
          },
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _topItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.6),
      itemBuilder: (_, i) => _topItemCard(_topItems[i]),
    );
  }

  Widget _topItemCard(Map<String, dynamic> it) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(it['image'], width: 84, height: 84, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 84, height: 84, color: AppColors.surface)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(it['title'], style: AppTextStyles.title(size: 14)),
                  const SizedBox(height: 6),
                  Text('${it['sales']} sales • \$${(it['revenue'] as double).toStringAsFixed(2)}', style: AppTextStyles.caption()),
                ],
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
      ),
    );
  }

  Widget _recentOrdersList() {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      padding: const EdgeInsets.all(8),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _recentOrders.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final o = _recentOrders[i];
          return ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.surface, child: Text(o['buyer'][0])),
            title: Text(o['item'], style: AppTextStyles.body()),
            subtitle: Text('${o['buyer']} • ${_formatTime(o['date'] as DateTime)}', style: AppTextStyles.caption(size: 12)),
            trailing: Text('\$${(o['amount'] as double).toStringAsFixed(2)}', style: AppTextStyles.title()),
            onTap: _goToOrders,
          );
        },
      ),
    );
  }

  String _formatTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _actionsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTextStyles.title(size: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _actionTile(Icons.add, 'Upload', _goToUpload)),
              const SizedBox(width: 8),
              Expanded(child: _actionTile(Icons.list_alt, 'Listings', _goToListings)),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: _actionTile(Icons.receipt_long, 'Orders', _goToOrders)), const SizedBox(width: 8), Expanded(child: _actionTile(Icons.trending_up, 'Analytics', () {}))]),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border), color: AppColors.surface),
        child: Row(children: [Icon(icon, color: AppColors.primary), const SizedBox(width: 10), Text(label, style: AppTextStyles.body())]),
      ),
    );
  }
}
