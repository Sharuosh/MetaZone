import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import 'chat_screen.dart';

class SavedChatsScreen extends StatefulWidget {
  const SavedChatsScreen({super.key});

  @override
  State<SavedChatsScreen> createState() => _SavedChatsScreenState();
}

class _SavedChatsScreenState extends State<SavedChatsScreen> {
  bool _gridMode = true;
  bool _manageMode = false;

  final TextEditingController _search = TextEditingController();
  List<Map<String, dynamic>> _saved = [];
  List<String> _selected = [];

  @override
  void initState() {
    super.initState();
    _loadSavedChats();
  }

  void _loadSavedChats() {
    // Later → Firestore or Local Storage
    _saved = [
      {
        "id": "spot_001",
        "name": "Cairo AR Portal",
        "subtitle": "Legendary Portal",
        "unread": 2,
        "image": "https://picsum.photos/seed/p1/600/400",
      },
      {
        "id": "user_lina",
        "name": "Lina",
        "subtitle": "Private Chat",
        "unread": 0,
        "image": null,
      },
      {
        "id": "spot_nile",
        "name": "Nile AR Spot",
        "subtitle": "Community Room",
        "unread": 5,
        "image": "https://picsum.photos/seed/p2/600/400",
      },
    ];
  }

  List<Map<String, dynamic>> _filter() {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _saved;
    return _saved.where((e) => e["name"].toLowerCase().contains(q)).toList();
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _deleteSelected() {
    setState(() {
      _saved.removeWhere((e) => _selected.contains(e["id"]));
      _selected.clear();
    });
  }

  void _openChat(Map item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          roomId: item["id"],
          roomName: item["name"],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filter();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _manageMode ? "Manage Favorites" : "Saved Chats",
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _gridMode = !_gridMode),
            icon: Icon(
              _gridMode ? Icons.view_list : Icons.grid_view,
              color: AppColors.text,
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              _manageMode = !_manageMode;
              _selected.clear();
            }),
            icon: Icon(
              _manageMode ? Icons.close : Icons.edit,
              color: AppColors.primary,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: "Search favorites…",
                hintStyle: TextStyle(color: AppColors.textSoft),
                filled: true,
                fillColor: AppColors.card,
                prefixIcon: Icon(Icons.search, color: AppColors.textSoft),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),

          Expanded(
            child: list.isEmpty
                ? Center(
              child: Text(
                "No saved chats yet",
                style: TextStyle(color: AppColors.textSoft),
              ),
            )
                : _gridMode
                ? _grid(list)
                : _list(list),
          ),

          if (_manageMode && _selected.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              child: ElevatedButton(
                onPressed: _deleteSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.black,
                ),
                child: Text("Delete ${_selected.length} selected"),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- GRID MODE ----------------
  Widget _grid(List<Map<String, dynamic>> list) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.92,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) => _gridItem(list[i]),
    );
  }

  Widget _gridItem(Map item) {
    final selected = _selected.contains(item["id"]);

    return GestureDetector(
      onTap: _manageMode
          ? () => _toggleSelect(item["id"])
          : () => _openChat(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border.withOpacity(0.5),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Image / Avatar
            Container(
              height: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: item["image"] != null
                    ? DecorationImage(
                    image: NetworkImage(item["image"]),
                    fit: BoxFit.cover)
                    : null,
                color: item["image"] == null
                    ? AppColors.surface
                    : Colors.transparent,
              ),
              child: item["image"] == null
                  ? Center(
                  child: Icon(Icons.person,
                      color: AppColors.primary, size: 38))
                  : null,
            ),

            const SizedBox(height: 10),
            Text(item["name"],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title(size: 14)),
            Text(item["subtitle"],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption()),

            const SizedBox(height: 8),

            if (item["unread"] > 0)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("${item["unread"]}",
                    style:
                    TextStyle(color: Colors.black, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- LIST MODE ----------------
  Widget _list(List<Map<String, dynamic>> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) => _listItem(list[i]),
    );
  }

  Widget _listItem(Map item) {
    final selected = _selected.contains(item["id"]);

    return GestureDetector(
      onLongPress: () => setState(() => _manageMode = true),
      onTap:
      _manageMode ? () => _toggleSelect(item["id"]) : () => _openChat(item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border.withOpacity(0.5),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: item["image"] != null
                    ? DecorationImage(
                    image: NetworkImage(item["image"]),
                    fit: BoxFit.cover)
                    : null,
                color: item["image"] == null
                    ? AppColors.surface
                    : Colors.transparent,
              ),
              child: item["image"] == null
                  ? Icon(Icons.person,
                  color: AppColors.primary, size: 32)
                  : null,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item["name"],
                        style: AppTextStyles.title(size: 15)),
                    const SizedBox(height: 4),
                    Text(item["subtitle"],
                        style: AppTextStyles.caption()),
                  ]),
            ),

            if (item["unread"] > 0)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("${item["unread"]}",
                    style:
                    TextStyle(color: Colors.black, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
