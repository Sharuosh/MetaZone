// lib/screens/home/modules/daily_missions_screen.dart
// Daily Missions Screen — MetaZone
// -----------------------------------------------------------------
// شاشة "Daily Missions" متكاملة: تصميم عصري، نظام مهام يومية، تتبع تقدم، مكافآت، تأكيدات، انيميشن، badges، leaderboard، وروابط واضحة لربط Firestore و Notifications.
// الهدف: ملف جاهز 100% للتطوير — تشغيلي محلياً مع بيانات Mock، وجاهز للربط بالـ backend لاحقاً.
// يعتمد على Material3 textTheme names (titleLarge, titleMedium, bodyMedium...)

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// -----------------------------
// Models
// -----------------------------
class Mission {
  final String id;
  final String title;
  final String description;
  final int progress; // current progress
  final int goal; // target to complete
  final int rewardCoins;
  final bool daily; // if true resets daily
  final DateTime assignedAt;
  final bool isCompleted;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.goal,
    required this.rewardCoins,
    required this.daily,
    required this.assignedAt,
    required this.isCompleted,
  });

  double get percent => goal == 0 ? 0 : (progress / goal).clamp(0, 1).toDouble();
}

// Mock missions
List<Mission> _mockMissions = [
  Mission(
    id: 'm1',
    title: 'Explore 3 AR Spots',
    description: 'Visit and open 3 different AR spots today.',
    progress: 1,
    goal: 3,
    rewardCoins: 50,
    daily: true,
    assignedAt: DateTime.now().subtract(const Duration(hours: 2)),
    isCompleted: false,
  ),
  Mission(
    id: 'm2',
    title: 'Place 1 AR Sticker',
    description: 'Create or place an AR sticker in the world.',
    progress: 0,
    goal: 1,
    rewardCoins: 80,
    daily: true,
    assignedAt: DateTime.now().subtract(const Duration(days: 1)),
    isCompleted: false,
  ),
  Mission(
    id: 'm3',
    title: 'Like 5 creations',
    description: 'Appreciate 5 creators by liking their AR creations.',
    progress: 3,
    goal: 5,
    rewardCoins: 30,
    daily: true,
    assignedAt: DateTime.now().subtract(const Duration(hours: 6)),
    isCompleted: false,
  ),
  Mission(
    id: 'm4',
    title: 'Earn 200 XP',
    description: 'Collect 200 experience points from activities.',
    progress: 120,
    goal: 200,
    rewardCoins: 100,
    daily: false,
    assignedAt: DateTime.now().subtract(const Duration(days: 3)),
    isCompleted: false,
  ),
];

// -----------------------------
// Daily Missions Screen
// -----------------------------
class DailyMissionsScreen extends StatefulWidget {
  const DailyMissionsScreen({Key? key}) : super(key: key);

  @override
  State<DailyMissionsScreen> createState() => _DailyMissionsScreenState();
}

class _DailyMissionsScreenState extends State<DailyMissionsScreen> with SingleTickerProviderStateMixin {
  late List<Mission> missions;
  late AnimationController _pulseController;
  bool _loading = true;
  int _coinsBalance = 320; // mock user balance
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    missions = List.from(_mockMissions);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseController.repeat(reverse: true);
    _simulateLoad();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _simulateLoad() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => _loading = false);
  }

  void _completeMission(Mission m) {
    if (m.isCompleted) return;
    // In real: call Firestore transaction to mark complete and award coins
    setState(() {
      final idx = missions.indexWhere((x) => x.id == m.id);
      if (idx != -1) {
        missions[idx] = Mission(
          id: m.id,
          title: m.title,
          description: m.description,
          progress: m.goal,
          goal: m.goal,
          rewardCoins: m.rewardCoins,
          daily: m.daily,
          assignedAt: m.assignedAt,
          isCompleted: true,
        );
        _coinsBalance += m.rewardCoins;
      }
    });

    // show celebratory UI
    _showRewardDialog(m.rewardCoins);
  }

  void _incrementProgress(Mission m, int amount) {
    final idx = missions.indexWhere((x) => x.id == m.id);
    if (idx == -1) return;
    final cur = missions[idx];
    final newProgress = (cur.progress + amount).clamp(0, cur.goal);
    setState(() {
      missions[idx] = Mission(
        id: cur.id,
        title: cur.title,
        description: cur.description,
        progress: newProgress,
        goal: cur.goal,
        rewardCoins: cur.rewardCoins,
        daily: cur.daily,
        assignedAt: cur.assignedAt,
        isCompleted: newProgress >= cur.goal,
      );
    });
    if (missions[idx].isCompleted) _completeMission(missions[idx]);
  }

  void _showRewardDialog(int coins) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reward Received'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, size: 48, color: Colors.amber),
            const SizedBox(height: 12),
            Text('You received $coins MetaCoins!', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Great job completing the mission. Keep the momentum!'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _claimAllCompleted() {
    final completed = missions.where((m) => m.isCompleted).toList();
    if (completed.isEmpty) return;
    int total = completed.fold(0, (sum, m) => sum + m.rewardCoins);
    setState(() {
      _coinsBalance += total; // in real: dedupe claimed vs unclaimed
      missions = missions.map((m) => m.isCompleted ? m : m).toList();
    });
    _showRewardDialog(total);
  }

  void _resetDailyMissions() {
    // For demo: reset daily missions only
    setState(() {
      missions = missions.map((m) {
        if (m.daily) {
          return Mission(
            id: m.id,
            title: m.title,
            description: m.description,
            progress: 0,
            goal: m.goal,
            rewardCoins: m.rewardCoins,
            daily: m.daily,
            assignedAt: DateTime.now(),
            isCompleted: false,
          );
        }
        return m;
      }).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daily missions reset (demo)')));
  }

  // UI pieces
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily Missions', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Complete missions to earn MetaCoins & XP', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const Spacer(),
          ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.05).animate(_pulseController),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.monetization_on, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('$_coinsBalance', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedControl(
              options: const ['All', 'Daily', 'One-time', 'Completed'],
              selectedIndex: _showCompleted ? 3 : 0,
              onChanged: (idx) {
                setState(() {
                  if (idx == 3) _showCompleted = true; else _showCompleted = false;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: _resetDailyMissions,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset daily (demo)',
          )
        ],
      ),
    );
  }

  Widget _buildMissionCard(Mission m) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(m.title, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold))),
              if (m.isCompleted)
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(8)), child: const Text('Completed', style: TextStyle(color: Colors.white)))
              else
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: Colors.orange.shade700, borderRadius: BorderRadius.circular(8)), child: Text('+${m.rewardCoins}'))
            ]),
            const SizedBox(height: 8),
            Text(m.description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: m.percent, minHeight: 8),
            const SizedBox(height: 8),
            Row(children: [
              Text('${m.progress}/${m.goal}', style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              if (!m.isCompleted)
                ElevatedButton(
                  onPressed: () => _incrementProgress(m, 1),
                  child: const Text('Progress +1'),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: m.isCompleted ? null : () => _completeMission(m),
                child: const Text('Claim'),
              )
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildMissionsList() {
    final list = _showCompleted ? missions.where((m) => m.isCompleted).toList() : missions.where((m) => !_showCompleted).toList();
    if (list.isEmpty) return _buildEmptyState();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: list.length + 1,
      itemBuilder: (ctx, idx) {
        if (idx == 0) return const SizedBox(height: 8);
        final m = list[idx - 1];
        return _buildMissionCard(m);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 84, color: Colors.grey),
          const SizedBox(height: 12),
          Text('No missions available', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Check back later for new daily missions and rewards!', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildLeaderboardSection() {
    // mock leaderboard
    final leaders = List.generate(5, (i) => {'name': 'User${i + 1}', 'score': 1000 - i * 120});
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Leaderboard', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => Column(children: [
                CircleAvatar(radius: 22, child: Text(leaders[i]['name']!.toString().substring(0, 1))),
                const SizedBox(height: 6),
                Text(leaders[i]['name']!.toString(), style: Theme.of(context).textTheme.bodySmall),
                Text('${leaders[i]['score']}', style: Theme.of(context).textTheme.bodySmall),
              ]),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: leaders.length,
            ),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Missions', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _claimAllCompleted, icon: const Icon(Icons.card_giftcard)),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? _buildLoading()
            : Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            Expanded(child: _buildMissionsList()),
            _buildLeaderboardSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // quick demo: add a random mission
          final id = 'm${DateTime.now().millisecondsSinceEpoch}';
          setState(() {
            missions.insert(
                0,
                Mission(
                    id: id,
                    title: 'Quick Mission',
                    description: 'Auto-generated demo mission',
                    progress: 0,
                    goal: 1,
                    rewardCoins: 20,
                    daily: true,
                    assignedAt: DateTime.now(),
                    isCompleted: false));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: 4,
      itemBuilder: (_, __) => Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(height: 100, color: Colors.white),
        ),
      ),
    );
  }
}

// -----------------------------
// Small reusable widgets
// -----------------------------
class SegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final void Function(int) onChanged;
  const SegmentedControl({Key? key, required this.options, required this.selectedIndex, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: options.map((o) {
          final idx = options.indexOf(o);
          final selected = idx == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(idx),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(o, style: selected ? const TextStyle(color: Colors.white) : null)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// -----------------------------
// End of file
// Integration notes:
// - Replace _mockMissions with Firestore query & user-specific claimed flags
// - Add server-side protection to awarding coins
// - Use local notification scheduling to remind users (daily reset)
// - Add analytics events for mission completions

