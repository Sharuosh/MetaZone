// File: lib/screens/ar/scene_builder/scene_analytics/scene_analytics_panel.dart
// MetaZone – Scene Analytics Panel (Ultra PRO Edition 2025)
// UI-only panel showing scene stats / complexity / perf estimate

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class SceneAnalyticsPanel extends StatelessWidget {
  final int objectsCount;
  final int lightsCount;
  final int physicsCount;
  final int materialsCount;
  final double estimatedPolygons; // in thousands
  final double memoryUsageMB; // estimated
  final double perfScore; // 0.0 - 100.0

  const SceneAnalyticsPanel({
    super.key,
    required this.objectsCount,
    required this.lightsCount,
    required this.physicsCount,
    required this.materialsCount,
    required this.estimatedPolygons,
    required this.memoryUsageMB,
    required this.perfScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 12),
          _summaryRow(),
          const SizedBox(height: 12),
          _statGrid(),
          const SizedBox(height: 12),
          _perfMeter(),
          const SizedBox(height: 12),
          _recommendations(),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Text("Scene Analytics", style: AppTextStyles.title(size: 16)),
        const Spacer(),
        Icon(Icons.insights_outlined, color: AppColors.textSoft),
      ],
    );
  }

  Widget _summaryRow() {
    return Row(
      children: [
        _smallBadge("Objects", objectsCount.toString(), Icons.view_in_ar),
        const SizedBox(width: 8),
        _smallBadge("Lights", lightsCount.toString(), Icons.lightbulb_outline),
        const SizedBox(width: 8),
        _smallBadge("Physics", physicsCount.toString(), Icons.science_outlined),
      ],
    );
  }

  Widget _smallBadge(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withOpacity(.28)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySoft.withOpacity(.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Icon(icon, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.caption(size: 11).copyWith(color: AppColors.textSoft)),
                  const SizedBox(height: 2),
                  Text(value, style: AppTextStyles.title(size: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statGrid() {
    return Column(
      children: [
        _statRow("Materials", materialsCount.toString(), "${estimatedPolygons.toStringAsFixed(1)}k polys"),
        const SizedBox(height: 8),
        _statRow("Estimated Memory", "${memoryUsageMB.toStringAsFixed(0)} MB", _memoryLevelLabel()),
      ],
    );
  }

  Widget _statRow(String label, String leftValue, String rightValue) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withOpacity(.24)),
      ),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.body(size: 13)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(leftValue, style: AppTextStyles.title(size: 13)),
              const SizedBox(height: 2),
              Text(rightValue, style: AppTextStyles.caption(size: 11).copyWith(color: AppColors.textSoft)),
            ],
          ),
        ],
      ),
    );
  }

  String _memoryLevelLabel() {
    if (memoryUsageMB < 200) return "Low";
    if (memoryUsageMB < 500) return "Medium";
    return "High";
  }

  Widget _perfMeter() {
    final clamped = perfScore.clamp(0.0, 100.0);
    Color meterColor;
    if (clamped > 75) {
      meterColor = Colors.greenAccent;
    } else if (clamped > 45) {
      meterColor = Colors.amberAccent;
    } else {
      meterColor = Colors.redAccent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Performance", style: AppTextStyles.caption(size: 12)),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 14,
              width: (clamped / 100) * 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  meterColor.withOpacity(.95),
                  AppColors.primary.withOpacity(.9),
                ]),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: meterColor.withOpacity(.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text("${clamped.toStringAsFixed(0)}", style: AppTextStyles.title(size: 16).copyWith(color: AppColors.primary)),
            const SizedBox(width: 8),
            Text("/ 100", style: AppTextStyles.caption(size: 12).copyWith(color: AppColors.textSoft)),
            const Spacer(),
            Text(_perfTip(clamped), style: AppTextStyles.caption(size: 11).copyWith(color: AppColors.textSoft)),
          ],
        ),
      ],
    );
  }

  String _perfTip(double score) {
    if (score > 75) return "Good";
    if (score > 45) return "Optimize";
    return "Critical";
  }

  Widget _recommendations() {
    final recs = _generateRecommendations();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recommendations", style: AppTextStyles.caption(size: 12)),
        const SizedBox(height: 8),
        ...recs.map((r) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: AppColors.primarySoft.withOpacity(.2), blurRadius: 6)
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(r, style: AppTextStyles.body(size: 12).copyWith(color: AppColors.textSoft))),
            ],
          ),
        )),
      ],
    );
  }

  List<String> _generateRecommendations() {
    final List<String> out = [];
    if (objectsCount > 80) out.add("Reduce object count or use LODs.");
    if (estimatedPolygons > 100) out.add("Optimize high-poly assets ( > 100k polys ).");
    if (memoryUsageMB > 400) out.add("Compress textures / reduce resolution.");
    if (physicsCount > 20) out.add("Limit dynamic physics objects.");
    if (out.isEmpty) out.add("No immediate actions — scene looks optimized.");
    return out;
  }
}
