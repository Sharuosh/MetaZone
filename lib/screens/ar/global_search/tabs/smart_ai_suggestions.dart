import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../create/ar_portal_viewer.dart';

class SmartAISuggestionsTab extends StatefulWidget {
  final String query;
  const SmartAISuggestionsTab({super.key, required this.query});

  @override
  State<SmartAISuggestionsTab> createState() => _SmartAISuggestionsTabState();
}

class _SmartAISuggestionsTabState extends State<SmartAISuggestionsTab> {
  String _searchText = "";
  String _activeCategory = "All";

  final List<String> _categories = [
    "All",
    "Optimization",
    "Feature",
    "Engagement",
  ];

  // MOCK data
  final List<Map<String, dynamic>> _all = [
    {
      "id": "s1",
      "title": "Nebula Gate — Sparkle Variant",
      "summary":
      "Increase bloom, add particle drift, neon rim boost, scale -8%.",
      "type": "Optimization",
      "score": 0.92,
      "action": "apply_tweak"
    },
    {
      "id": "s2",
      "title": "Portal Gate — Landmark Mode",
      "summary":
      "Geo-lock anchors, loop animation, ambient sound within 10m.",
      "type": "Feature",
      "score": 0.87,
      "action": "enable_feature"
    },
    {
      "id": "s3",
      "title": "Tiny Robot — Performance Trim",
      "summary": "Use LOD2 > 6m, bake lightmap, reduce draw calls.",
      "type": "Optimization",
      "score": 0.79,
      "action": "performance"
    },
    {
      "id": "s4",
      "title": "Sky Lantern — Social Boost",
      "summary": "Enable shared anchor for instant group trigger.",
      "type": "Engagement",
      "score": 0.76,
      "action": "social_event"
    },
  ];

  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _results = List.from(_all);
  }

  @override
  void didUpdateWidget(covariant SmartAISuggestionsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applySearch(widget.query);
  }

  // SEARCH
  void _applySearch(String text) {
    _searchText = text.toLowerCase().trim();
    _filter();
  }

  // FILTER
  void _filter() {
    List<Map<String, dynamic>> list = List.from(_all);

    if (_activeCategory != "All") {
      list = list.where((e) => e["type"] == _activeCategory).toList();
    }

    if (_searchText.isNotEmpty) {
      list = list.where((e) {
        return e["title"].toLowerCase().contains(_searchText) ||
            e["summary"].toLowerCase().contains(_searchText);
      }).toList();
    }

    setState(() => _results = list);
  }

  // ACTIONS
  void _apply(Map<String, dynamic> s) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Applied: ${s['title']}")));
  }

  void _save(Map<String, dynamic> s) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Saved (demo)")));
  }

  void _openDetails(Map<String, dynamic> s) {

  }

  void _openAR(Map<String, dynamic> s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ARPortalViewerScreen(
          spotId: s["id"],
          title: s["title"],
          owner: "AI Engine",
        ),
      ),
    );
  }

  // CATEGORY FILTERS UI
  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final c = _categories[i];
          final active = c == _activeCategory;

          return GestureDetector(
            onTap: () => setState(() {
              _activeCategory = c;
              _filter();
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                c,
                style: active
                    ? AppTextStyles.body()
                    : AppTextStyles.caption(),
              ),
            ),
          );
        },
      ),
    );
  }

  // MAIN SUGGESTION CARD
  Widget _suggestion(Map<String, dynamic> s) {
    final score = (s["score"] * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP — title + score
          Row(
            children: [
              Expanded(
                child: Text(s["title"], style: AppTextStyles.title()),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$score%",
                  style: AppTextStyles.caption(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(s["summary"], style: AppTextStyles.body(size: 13)),
          const SizedBox(height: 12),

          // ACTION BUTTONS
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _apply(s),
                icon: const Icon(Icons.check, color: Colors.black),
                label: const Text("Apply"),
              ),
              const SizedBox(width: 8),

              OutlinedButton.icon(
                onPressed: () => _save(s),
                icon: const Icon(Icons.save_outlined),
                label: const Text("Save"),
              ),
              const SizedBox(width: 8),

              OutlinedButton.icon(
                onPressed: () => _openDetails(s),
                icon: const Icon(Icons.info_outline),
                label: const Text("Details"),
              ),

              const Spacer(),

              IconButton(
                onPressed: () => _openAR(s),
                icon: Icon(Icons.view_in_ar, color: AppColors.primary),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildFilters(),
        const SizedBox(height: 12),

        Expanded(
          child: _results.isEmpty
              ? Center(
            child: Text("No AI suggestions",
                style: AppTextStyles.caption()),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            itemCount: _results.length,
            itemBuilder: (_, i) => _suggestion(_results[i]),
          ),
        ),
      ],
    );
  }
}
