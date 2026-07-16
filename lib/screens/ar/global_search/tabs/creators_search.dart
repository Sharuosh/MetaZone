import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class CreatorsSearchTab extends StatefulWidget {
  final String query;
  const CreatorsSearchTab({super.key, required this.query});

  @override
  State<CreatorsSearchTab> createState() => _CreatorsSearchTabState();
}

class _CreatorsSearchTabState extends State<CreatorsSearchTab> {
  final List<String> _filters = ["All", "Top Rated", "Nearby", "Rising"];
  String _activeFilter = "All";

  // MOCK DATA
  final List<Map<String, dynamic>> _allCreators = [
    {
      "id": "u001",
      "name": "MetaLina",
      "followers": 18400,
      "objectsCount": 46,
      "distance": 240,
      "bio": "Specialized in AR portals & nebula effects.",
      "featured": true,
    },
    {
      "id": "u002",
      "name": "ARMaster",
      "followers": 9000,
      "objectsCount": 24,
      "distance": 1000,
      "bio": "Creator of immersive floating AR objects.",
      "featured": false,
    },
    {
      "id": "u003",
      "name": "Hadi",
      "followers": 4200,
      "objectsCount": 13,
      "distance": 5000,
      "bio": "Designer of advanced 3D assets.",
      "featured": false,
    },
    {
      "id": "u004",
      "name": "MetaGirl",
      "followers": 32000,
      "objectsCount": 61,
      "distance": 650,
      "bio": "Top AR creator in the region.",
      "featured": true,
    },
  ];

  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _results = List.from(_allCreators);
  }

  @override
  void didUpdateWidget(covariant CreatorsSearchTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applySearch(widget.query);
  }

  // SEARCH
  void _applySearch(String q) {
    final query = q.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() => _results = List.from(_allCreators));
      _applyFilter(_activeFilter);
      return;
    }

    setState(() {
      _results = _allCreators.where((c) {
        return c["name"].toLowerCase().contains(query) ||
            c["bio"].toLowerCase().contains(query);
      }).toList();
    });
    _applyFilter(_activeFilter);
  }

  // FILTER
  void _applyFilter(String filter) {
    _activeFilter = filter;
    List<Map<String, dynamic>> d = List.from(_results);

    switch (filter) {
      case "Top Rated":
        d.sort((b, a) => a["followers"].compareTo(b["followers"]));
        break;

      case "Nearby":
        d.sort((a, b) => a["distance"].compareTo(b["distance"]));
        d = d.where((c) => c["distance"] < 1000).toList();
        break;

      case "Rising":
        d.sort((b, a) => a["objectsCount"].compareTo(b["objectsCount"]));
        break;

      default:
        break;
    }

    setState(() => _results = d);
  }

  // BOTTOM SHEET
  void _openCreator(Map<String, dynamic> c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _creatorSheet(c),
    );
  }

  Widget _creatorSheet(Map<String, dynamic> c) {
    return Container(
      height: 440,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Container(
                  height: 5,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(6),
                  ))),

          const SizedBox(height: 18),

          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.card,
                child: Text(c["name"][0],
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child:
                Text(c["name"], style: AppTextStyles.title(size: 20)),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(c["bio"], style: AppTextStyles.caption()),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.people, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              Text("${c["followers"]} followers",
                  style: AppTextStyles.caption()),
              const SizedBox(width: 12),
              Icon(Icons.view_in_ar, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              Text("${c["objectsCount"]} objects",
                  style: AppTextStyles.caption()),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person),
                  label: const Text("Visit Profile"),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {},
                child: const Icon(Icons.share),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text("Featured Work", style: AppTextStyles.title(size: 14)),
          const SizedBox(height: 10),

          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                4,
                    (i) => Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Icon(Icons.view_in_ar,
                        size: 50, color: AppColors.primary),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // FILTERS
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _filters[i];
              final active = f == _activeFilter;

              return GestureDetector(
                onTap: () => setState(() => _applyFilter(f)),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                      color:
                      active ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border)),
                  child: Text(f,
                      style: active
                          ? AppTextStyles.body()
                          : AppTextStyles.caption()),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // LIST
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            itemBuilder: (_, i) {
              final c = _results[i];

              return GestureDetector(
                onTap: () => _openCreator(c),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.surface,
                        child: Text(
                          c["name"][0],
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(c["name"], style: AppTextStyles.title()),
                            const SizedBox(height: 4),
                            Text(
                              "${c["followers"]} followers • ${c["objectsCount"]} objects",
                              style: AppTextStyles.caption(),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: AppColors.textSoft),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
