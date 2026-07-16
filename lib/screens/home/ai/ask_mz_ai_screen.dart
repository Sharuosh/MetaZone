// lib/screens/home/ai/ask_mz_ai_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class AskMetaZoneAI extends StatefulWidget {
  const AskMetaZoneAI({super.key});

  @override
  State<AskMetaZoneAI> createState() => _AskMetaZoneAIState();
}

class _AskMetaZoneAIState extends State<AskMetaZoneAI>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String aiResponse = "";
  bool loading = false;

  late AnimationController glowCtrl;
  late Animation<double> glowAnim;

  @override
  void initState() {
    super.initState();

    glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    glowCtrl.dispose();
    super.dispose();
  }

  void sendPrompt() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => loading = true);

    await Future.delayed(const Duration(seconds: 2)); // AI Simulation

    setState(() {
      aiResponse = "AI says:\n\n${_controller.text}";
      loading = false;
      _controller.clear();
    });
  }

  Widget _buildARActionButton(IconData icon, String label, VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(.15),
              AppColors.accent.withOpacity(.08)
            ],
          ),
          border: Border.all(color: AppColors.primary.withOpacity(.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.body()),
          ],
        ),
      ),
    );
  }

  Widget _responseBox() {
    if (loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (aiResponse.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            "Ask me anything about your AR world…",
            style: AppTextStyles.caption(size: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        aiResponse,
        style: AppTextStyles.body(size: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text("Ask MetaZone AI", style: AppTextStyles.heading()),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FadeTransition(
                opacity: glowAnim,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(.6),
                          AppColors.surface
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: AppColors.primary,
                      size: 42,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(child: _responseBox()),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildARActionButton(Icons.view_in_ar, "Open AR View", () {}),
                  _buildARActionButton(Icons.auto_awesome, "Generate Object", () {}),
                  _buildARActionButton(Icons.map_outlined, "Analyze Area", () {}),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: AppColors.text),
                        decoration: InputDecoration(
                          hintText: "Ask MetaZone AI…",
                          hintStyle: TextStyle(color: AppColors.textSoft),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: sendPrompt,
                      icon: Icon(Icons.send, color: AppColors.primary),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
