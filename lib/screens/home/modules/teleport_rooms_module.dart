// lib/screens/home/modules/teleport_rooms_module.dart
// Teleport Rooms module — Hybrid layout (C)
// Includes: TeleportRoomsScreen, TeleportRoomCard, TeleportRoomDetailsScreen, CreateRoomScreen
//
// NOTES FOR DEVELOPER:
// - This file is UI-only (mock data). Points where you should call Firestore / backend are marked with TODO: FIRESTORE.
// - Each major widget/field includes a comment explaining its purpose so backend integration is straightforward.

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// --------------------------
// Mock model (replace with your Firestore model later)
// --------------------------
class TeleportRoom {
  final String id; // unique id (use Firestore doc id)
  final String title; // room title
  final String owner; // owner's display name or uid
  final String thumbnail; // asset path or network URL
  final int online; // current online count
  final String category; // room category (Games/Art/...)
  final String description; // detailed description
  final double distanceMeters; // distance from user (if location-based)

  TeleportRoom({
    required this.id,
    required this.title,
    required this.owner,
    required this.thumbnail,
    required this.online,
    required this.category,
    required this.description,
    required this.distanceMeters,
  });
}

// -------------------------------
// Main Teleport Rooms Screen
// -------------------------------
class TeleportRoomsScreen extends StatefulWidget {
  const TeleportRoomsScreen({super.key});

  @override
  State<TeleportRoomsScreen> createState() => _TeleportRoomsScreenState();
}

class _TeleportRoomsScreenState extends State<TeleportRoomsScreen>
    with TickerProviderStateMixin {
  List<TeleportRoom> _rooms = [];
  String _query = '';
  String _filter = 'All';
  late AnimationController _entranceController;

  // Local UI state for favorites/bookmarks - in production: keep in Firestore user doc
  final Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _rooms = _generateMockRooms();
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _entranceController.forward();

    // TODO: FIRESTORE: subscribe to rooms collection snapshot and update _rooms in real-time
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // -----------------------
  // Mock data generator
  // Replace this with data from Firestore (map to TeleportRoom)
  // -----------------------
  List<TeleportRoom> _generateMockRooms() {
    return List.generate(12, (i) {
      final cats = ['Games', 'Art', 'Social', 'Music', 'Education'];
      final cat = cats[i % cats.length];
      return TeleportRoom(
        id: 'room_$i',
        title: '${cat} Hub #${i + 1}',
        owner: 'User${i + 1}',
        thumbnail: 'assets/images/room_${(i % 4) + 1}.jpg', // placeholders — use network URLs in production
        online: Random().nextInt(24) + 1,
        category: cat,
        description: 'This is a demo description for $cat Hub #${i + 1}. Explore AR content, meet users and teleport.',
        distanceMeters: (100 + Random().nextInt(2000)).toDouble(),
      );
    });
  }

  // Apply search + category filter
  List<TeleportRoom> get _filteredRooms {
    final q = _query.trim().toLowerCase();
    return _rooms.where((r) {
      final byFilter = _filter == 'All' ? true : r.category == _filter;
      final byQuery = q.isEmpty ? true : (r.title.toLowerCase().contains(q) || r.owner.toLowerCase().contains(q));
      return byFilter && byQuery;
    }).toList();
  }

  String _distanceLabel(double m) => m < 1000 ? '${m.toInt()} m' : '${(m / 1000).toStringAsFixed(1)} km';

  // Open "Create Room" screen, returns true if created (demo)
  void _openCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
    );
    if (created == true) {
      // in production you'd refresh from backend or append the new room
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room created (demo)')));
      // TODO: FIRESTORE: on successful create, refresh list / listen to new doc
    }
  }

  // Open details with nice fade transition
  void _openDetails(TeleportRoom room) {
    Navigator.push(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => TeleportRoomDetailsScreen(room: room),
        transitionsBuilder: (_, a, __, child) {
          return FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child);
        }
    ));
  }

  // Toggle favorite locally (persist to backend later)
  void _toggleFavorite(String roomId) {
    setState(() {
      if (_favorites.contains(roomId)) _favorites.remove(roomId);
      else _favorites.add(roomId);
    });

    // TODO: FIRESTORE: update user's favorites list (add/remove roomId)
  }

  // Share room (uses system share in production)
  void _shareRoom(TeleportRoom r) {
    // TODO: integrate share plugin and share deep link
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share link copied for ${r.title} (demo)')));
  }

  // Report room placeholder
  void _reportRoom(TeleportRoom r) {
    // TODO: open report flow or write report doc to Firestore
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reported ${r.title} (demo)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Teleport Rooms', style: AppTextStyles.heading()),
        actions: [
          // Filter button — opens same filter bottom sheet
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.textLight),
            onPressed: () => _showFilterSheet(),
            tooltip: 'Filter rooms by category',
          ),
          // Create room quick action
          IconButton(
            icon: Icon(Icons.add_location_alt, color: AppColors.primary),
            onPressed: _openCreate,
            tooltip: 'Create a new Teleport Room',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            children: [
              // Search
              _buildSearchRow(),
              const SizedBox(height: 12),

              // Sections: Horizontal Highlights + Grid
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Highlights (horizontal) — featured rooms
                    SizedBox(
                      height: 140,
                      child: AnimatedBuilder(
                        animation: _entranceController,
                        builder: (_, __) {
                          return Opacity(
                            opacity: _entranceController.value,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: min(5, _rooms.length),
                              itemBuilder: (_, i) {
                                final r = _rooms[i];
                                return GestureDetector(
                                  onTap: () => _openDetails(r),
                                  child: Container(
                                    width: 240,
                                    margin: EdgeInsets.only(left: i == 0 ? 0 : 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      image: DecorationImage(
                                        image: AssetImage(r.thumbnail),
                                        fit: BoxFit.cover,
                                      ),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8)],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        gradient: LinearGradient(colors: [Colors.black.withOpacity(.35), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      alignment: Alignment.bottomLeft,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(r.title, style: AppTextStyles.title(size: 16)),
                                          const SizedBox(height: 4),
                                          Row(children: [Icon(Icons.group, size: 12, color: AppColors.textLight), const SizedBox(width: 6), Text('${r.online} online', style: AppTextStyles.caption())]),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Grid / List mix — Section header
                    _sectionHeader('Recommended Rooms', onViewAll: () {
                      // TODO: optional navigate to full list screen
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viewing all (demo)')));
                    }),

                    const SizedBox(height: 8),

                    // Grid: responsive columns
                    LayoutBuilder(builder: (ctx, cons) {
                      final cross = cons.maxWidth > 900 ? 3 : (cons.maxWidth > 600 ? 2 : 1);
                      final items = _filteredRooms;
                      if (items.isEmpty) {
                        return Container(
                          height: 240,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off, size: 48, color: AppColors.textSoft),
                              const SizedBox(height: 8),
                              Text('No rooms found', style: AppTextStyles.caption()),
                            ],
                          ),
                        );
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cross,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.4,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final r = items[i];
                          return TeleportRoomCard(
                            room: r,
                            isFavorite: _favorites.contains(r.id),
                            onTap: () => _openDetails(r),
                            onFavorite: () => _toggleFavorite(r.id),
                            onMore: () {
                              // open bottom sheet with actions
                              _showRoomActions(r);
                            },
                          );
                        },
                      );
                    }),

                    const SizedBox(height: 26),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Search row (search input + quick filter button)
  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.textSoft),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(color: AppColors.text),
                    decoration: InputDecoration.collapsed(hintText: 'Search rooms, owners...', hintStyle: TextStyle(color: AppColors.textSoft)),
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(onTap: () => setState(() => _query = ''), child: Icon(Icons.close, size: 18, color: AppColors.textLight)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _showFilterSheet(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Icon(Icons.tune, color: AppColors.primary),
          ),
        )
      ],
    );
  }

  Widget _sectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.title(size: 16)),
        if (onViewAll != null)
          TextButton(onPressed: onViewAll, child: Text('View all', style: AppTextStyles.caption(size: 13)))
      ],
    );
  }

  // Filter bottom sheet (category chips)
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        final cats = ['All', 'Games', 'Art', 'Social', 'Music', 'Education'];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Rooms', style: AppTextStyles.heading()),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cats.map((c) {
                  final active = _filter == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: active,
                    onSelected: (_) => setState(() => _filter = c),
                    selectedColor: AppColors.primary.withOpacity(.12),
                    backgroundColor: AppColors.card,
                    labelStyle: TextStyle(color: active ? AppColors.primary : AppColors.textLight),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')))
            ],
          ),
        );
      },
    );
  }

  // Room action sheet (favorite/share/report)
  void _showRoomActions(TeleportRoom r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) {
        final fav = _favorites.contains(r.id);
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(leading: Icon(fav ? Icons.bookmark : Icons.bookmark_border, color: AppColors.primary), title: Text(fav ? 'Unfavorite' : 'Favorite'), onTap: () { Navigator.pop(context); _toggleFavorite(r.id); }),
            ListTile(leading: Icon(Icons.share, color: AppColors.primary), title: Text('Share'), onTap: () { Navigator.pop(context); _shareRoom(r); }),
            ListTile(leading: Icon(Icons.report, color: Colors.redAccent), title: Text('Report'), onTap: () { Navigator.pop(context); _reportRoom(r); }),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))
          ]),
        );
      },
    );
  }
}

// -------------------------------
// Teleport Room Card (used in grid)
// - includes quick actions and clearly labeled widgets
// -------------------------------
class TeleportRoomCard extends StatelessWidget {
  final TeleportRoom room;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onMore;
  final bool isFavorite;

  const TeleportRoomCard({
    super.key,
    required this.room,
    required this.onTap,
    required this.onFavorite,
    required this.onMore,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    // Card layout: thumbnail | info | actions
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Thumbnail: use network image in production
            Container(
              width: 96,
              height: 86,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: AssetImage(room.thumbnail), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(room.title, style: AppTextStyles.title(size: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text('by ${room.owner} • ${room.category}', style: AppTextStyles.caption()),
                  const SizedBox(height: 8),
                  Row(children: [Icon(Icons.group, size: 14, color: AppColors.textSoft), const SizedBox(width: 6), Text('${room.online} online', style: AppTextStyles.caption())]),
                ],
              ),
            ),
            // Actions column: favorite + more
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onFavorite,
                  icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border, color: isFavorite ? AppColors.primary : AppColors.textLight),
                  tooltip: 'Favorite / Save for later',
                ),
                IconButton(
                  onPressed: onMore,
                  icon: Icon(Icons.more_vert, color: AppColors.textLight),
                  tooltip: 'More actions (share, report, etc.)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------
// Teleport Room Details Screen
// - Full screen details with Join flow placeholder
// - All fields shown with commented markers for backend integration
// -------------------------------
class TeleportRoomDetailsScreen extends StatelessWidget {
  final TeleportRoom room;
  const TeleportRoomDetailsScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(room.title, style: AppTextStyles.heading(size: 16)),
        actions: [
          IconButton(onPressed: () {
            // TODO: FIRESTORE: implement share deep link
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share (demo)')));
          }, icon: Icon(Icons.share, color: AppColors.textLight)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // preview (image or live thumbnail)
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(image: AssetImage(room.thumbnail), fit: BoxFit.cover),
                border: Border.all(color: AppColors.border),
              ),
            ),
            const SizedBox(height: 12),

            // owner row + online count
            Row(
              children: [
                CircleAvatar(radius: 22, backgroundColor: AppColors.card, child: Text(room.owner[0], style: TextStyle(color: AppColors.primary))),
                const SizedBox(width: 10),
                Expanded(child: Text(room.owner, style: AppTextStyles.title())),
                Column(children: [Text('${room.online}', style: AppTextStyles.title()), Text('online', style: AppTextStyles.caption())]),
              ],
            ),

            const SizedBox(height: 12),
            Text(room.description, style: AppTextStyles.body()),
            const SizedBox(height: 12),

            Wrap(spacing: 8, children: [
              Chip(label: Text(room.category), backgroundColor: AppColors.card),
              Chip(label: Text(_distanceLabel(room.distanceMeters)), backgroundColor: AppColors.surface),
            ]),

            const SizedBox(height: 20),

            // Join / Preview actions
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Placeholder join flow:
                    // 1) Check permissions (camera, mic)
                    // 2) Request entry token from backend
                    // 3) Open ARPortalViewer + pass room id
                    // TODO: FIRESTORE: call cloud function or update join count & generate token
                    showDialog(context: context, builder: (_) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: Text('Join Room', style: AppTextStyles.title()),
                      content: Text('Start teleporting into ${room.title} — this will open AR view (demo).', style: AppTextStyles.body()),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                        ElevatedButton(onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Joining ${room.title} (demo)')));
                          // TODO: open AR viewer (pass room.id to AR viewer)
                        }, child: Text('Join'))
                      ],
                    ));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text('Join Portal'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  // Preview (non-AR): show short preview or 360 thumbnail
                  // TODO: FIRESTORE: request preview asset, or stream thumbnail
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preview (demo)')));
                },
                style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.border)),
                child: Icon(Icons.visibility, color: AppColors.textLight),
              )
            ]),

            const SizedBox(height: 20),

            // additional info: clearly labeled for backend
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Room Info', style: AppTextStyles.title()),
                const SizedBox(height: 8),
                // ID: must be stored in Firestore and used for routing
                Text('ID: ${room.id}', style: AppTextStyles.caption()),
                // Owner: show owner id or link to profile (backend)
                Text('Owner: ${room.owner}', style: AppTextStyles.caption()),
                Text('Category: ${room.category}', style: AppTextStyles.caption()),
                // TODO: add fields: createdAt, privacy, joinCode, anchorId (for AR anchors)
              ]),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _distanceLabel(double m) => m < 1000 ? '${m.toInt()} m' : '${(m / 1000).toStringAsFixed(1)} km';
}

// -------------------------------
// Create Room Screen (UI only)
// - Clearly annotated for backend integration
// -------------------------------
class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _titleCtl = TextEditingController();
  final TextEditingController _descCtl = TextEditingController();
  String _category = 'Social';
  bool _isPrivate = false; // if true, requires invite code to join
  bool _locationBased = true; // if true, attach geolocation anchor to room
  String? _inviteCode; // generate on create if private

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  // Create room locally — return true to caller (demo)
  void _create() {
    if (_titleCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a room name')));
      return;
    }

    // In production:
    // 1) Upload thumbnail if provided
    // 2) Create Firestore document under "rooms" with fields:
    //    - title, description, category, ownerId, privacy, inviteCode (if private), location (if locationBased), anchorId (if AR anchor created)
    // 3) Optionally create AR anchor & store anchorId in doc
    //
    // For demo, generate invite code if private and return true

    if (_isPrivate) _inviteCode = _generateInviteCode();

    // TODO: FIRESTORE: create room doc and return success/failure
    Navigator.pop(context, true);
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Create Teleport Room', style: AppTextStyles.heading()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Title input — required
              TextField(
                controller: _titleCtl,
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  hintText: 'Room name',
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              // Description
              TextField(
                controller: _descCtl,
                minLines: 3,
                maxLines: 5,
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  hintText: 'Short description',
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              // Category select
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  fillColor: AppColors.card,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: ['Social', 'Games', 'Art', 'Music', 'Education'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 12),

              // Privacy & location toggles
              Row(children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(child: Text('Private room (invite only)', style: AppTextStyles.body())),
                        Switch(value: _isPrivate, onChanged: (v) => setState(() => _isPrivate = v)),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(child: Text('Location-based (nearby users)', style: AppTextStyles.body())),
                        Switch(value: _locationBased, onChanged: (v) => setState(() => _locationBased = v)),
                      ],
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              // Buttons: Cancel / Create
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: _create, child: Text('Create Room'))),
              ]),

              const SizedBox(height: 12),

              // Developer notes: show invite code if private (demo)
              if (_isPrivate && _inviteCode != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(child: Text('Invite code: $_inviteCode', style: AppTextStyles.body())),
                      IconButton(onPressed: () { /* copy to clipboard */ }, icon: Icon(Icons.copy, color: AppColors.textLight)),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
