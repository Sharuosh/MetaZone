import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// Tabs
import 'tabs/creators_search.dart';
import 'tabs/portals_search.dart';
import 'tabs/spots_search.dart';
import 'tabs/smart_ai_suggestions.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final TextEditingController _searchCtl = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text("Global AR Search", style: AppTextStyles.heading()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3, color: AppColors.primary),
                insets: const EdgeInsets.symmetric(horizontal: 20),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textLight,
              labelStyle: AppTextStyles.body(size: 14),
              tabs: const [
                Tab(text: "Creators"),
                Tab(text: "Portals"),
                Tab(text: "AR Spots"),
                Tab(text: "AI Smart"),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withOpacity(.4)),
              ),
              child: TextField(
                controller: _searchCtl,
                onChanged: (v) =>
                    setState(() => _query = v.trim().toLowerCase()),
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  hintText: "Search anything across MetaZone...",
                  hintStyle: AppTextStyles.caption(),
                  prefixIcon:
                  Icon(Icons.search, color: AppColors.primary, size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Tabs Content
          Expanded(
            child: AnimatedBuilder(
              animation: _tabCtrl.animation!,
              builder: (_, __) {
                return FadeTransition(
                  opacity: _tabCtrl.animation!,
                  child: TabBarView(
                    controller: _tabCtrl,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      CreatorsSearchTab(query: _query),
                      PortalsSearchTab(query: _query),
                      ARSpotsSearchTab(query: _query),
                      SmartAISuggestionsTab(query: _query),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
