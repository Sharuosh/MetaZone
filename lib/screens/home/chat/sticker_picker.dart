// lib/screens/home/chat/sticker_picker.dart
// MetaZone – Sticker Picker (AR Neon • Marketplace-ready • Recent Support)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme.dart';

class StickerPicker extends StatefulWidget {
  const StickerPicker({super.key});

  @override
  State<StickerPicker> createState() => _StickerPickerState();
}

class _StickerPickerState extends State<StickerPicker>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  List<String> recent = [];

  final List<String> popular = [
    "🔥","✨","🌌","🚀","🛰️","💥","👾","🤖","🎮","😎",
    "💫","⚡","🪐","🏆","🎯","💎","📡","🎆","🌟","🧭",
  ];

  final List<String> space = [
    "🌌","🚀","🛸","🪐","🌍","🌑","🌙","☄️","💫","✨",
    "🛰️","🌟","🌠","🌗","🌘","🔭","🌒","🛸","🚀","🌎",
  ];

  final List<String> tech = [
    "🤖","👾","🧠","🔧","⚙️","💻","📡","🛠️","🔋","♻️",
    "💽","🦾","🦿","🔌","👨‍💻","👩‍💻","🤝","⚡","🚨","🤖",
  ];

  final List<String> gaming = [
    "🎮","🕹️","🏆","💥","⚡","🎯","🔫","🧩","👾","💎",
    "🚀","🔥","🧨","💣","🥇","🥈","🥉","🧱","🎱","🗡️",
  ];

  final List<String> fun = [
    "😂","🤣","😎","😍","😴","🤯","🤡","🥳","🤩","😈",
    "🙃","😇","💀","👻","👅","😜","😹","😽","🫠","🤪",
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
    _loadRecent();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ================= RECENT STORAGE =================

  Future<void> _loadRecent() async {
    final p = await SharedPreferences.getInstance();
    setState(() => recent = p.getStringList("recent_stickers") ?? []);
  }

  Future<void> _addToRecent(String s) async {
    final p = await SharedPreferences.getInstance();

    recent.remove(s);
    recent.insert(0, s);

    if (recent.length > 24) {
      recent = recent.take(24).toList();
    }

    await p.setStringList("recent_stickers", recent);
  }

  // ================= GRID BUILDER =================

  Widget _grid(List<String> items) {
    if (items.isEmpty) {
      return Center(
        child: Text("No stickers yet",
            style: TextStyle(color: AppColors.textSoft)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final s = items[i];

        return GestureDetector(
          onLongPress: () => _previewSticker(s),
          onTap: () async {
            await _addToRecent(s);
            if (!mounted) return;
            Navigator.pop(context, s);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(.35),
              borderRadius: BorderRadius.circular(16),
              border:
              Border.all(color: AppColors.primarySoft.withOpacity(.4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withOpacity(.22),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              s,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        );
      },
    );
  }

  // ================= PREVIEW POPUP =================

  void _previewSticker(String s) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.55),
      builder: (_) => Center(
        child: AnimatedScale(
          scale: 1.2,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.35),
                  blurRadius: 30,
                )
              ],
            ),
            child: Text(
              s,
              style: const TextStyle(fontSize: 64),
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 390,
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),

          // Grab handle
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.cardSoft,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 10),

          // Header
          Row(
            children: [
              const SizedBox(width: 16),
              Text(
                "Stickers",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppColors.textSoft),
              ),
            ],
          ),

          // Tabs
          TabBar(
            controller: _tab,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "🕓 Recent"),
              Tab(text: "🔥 Popular"),
              Tab(text: "🌌 Space"),
              Tab(text: "🤖 Tech"),
              Tab(text: "🎮 Gaming"),
              Tab(text: "😂 Fun"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _grid(recent),
                _grid(popular),
                _grid(space),
                _grid(tech),
                _grid(gaming),
                _grid(fun),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
