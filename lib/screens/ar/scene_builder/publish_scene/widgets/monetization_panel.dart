// File: monetization_panel.dart
// MetaZone — Monetization Panel (Ultra PRO 2025)
// Compatible version with PublishSceneScreen requirements.

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class MonetizationPanel extends StatefulWidget {
  final bool enabled;
  final double price;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onPriceChanged;

  const MonetizationPanel({
    super.key,
    required this.enabled,
    required this.price,
    required this.onToggle,
    required this.onPriceChanged,
  });

  @override
  State<MonetizationPanel> createState() => _MonetizationPanelState();
}

class _MonetizationPanelState extends State<MonetizationPanel> {
  late bool _enabled;
  late TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
    _priceCtrl = TextEditingController(
      text: widget.price.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _toggleRow(),

        const SizedBox(height: 16),

        if (_enabled) _priceInputBox(),
        if (_enabled) const SizedBox(height: 16),
        if (_enabled) _earningsEstimate(),
      ],
    );
  }

  // =============================================================
  // TOGGLE
  // =============================================================
  Widget _toggleRow() {
    return Row(
      children: [
        Expanded(
          child: Text("Enable Monetization",
              style: AppTextStyles.body(size: 14)),
        ),
        Switch(
          value: _enabled,
          activeColor: AppColors.primary,
          onChanged: (v) {
            setState(() => _enabled = v);
            widget.onToggle(v);
          },
        ),
      ],
    );
  }

  // =============================================================
  // PRICE INPUT
  // =============================================================
  Widget _priceInputBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _priceCtrl,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.body(),
              onChanged: (v) {
                final val = double.tryParse(v) ?? 0;
                widget.onPriceChanged(val);
              },
              decoration: InputDecoration(
                hintText: "Price (in MC)",
                hintStyle: AppTextStyles.caption()
                    .copyWith(color: AppColors.textSoft),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "MC",
              style: AppTextStyles.caption(size: 12)
                  .copyWith(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  // =============================================================
  // EARNINGS ESTIMATION
  // =============================================================
  Widget _earningsEstimate() {
    double price = double.tryParse(_priceCtrl.text) ?? 0;
    double estimated = price * 0.75; // platform keeps 25%

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.stacked_line_chart,
              color: AppColors.primary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Earnings: ~${estimated.toStringAsFixed(2)} MC per purchase",
              style: AppTextStyles.caption(size: 12),
            ),
          ),
        ],
      ),
    );
  }
}
