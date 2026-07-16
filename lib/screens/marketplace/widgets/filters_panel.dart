import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class FiltersPanel extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApply;

  const FiltersPanel({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<FiltersPanel> createState() => _FiltersPanelState();
}

class _FiltersPanelState extends State<FiltersPanel> {
  late String selectedType;
  late double priceMin;
  late double priceMax;
  late double minRating;
  late String sortBy;

  final List<String> types = [
    "All",
    "Portal",
    "3D Object",
    "Sticker",
    "Light",
    "FX"
  ];

  final List<String> sortingOptions = [
    "Popular",
    "Newest",
    "Price: Low → High",
    "Price: High → Low",
    "Rating"
  ];

  @override
  void initState() {
    super.initState();

    selectedType = widget.initialFilters["type"] ?? "All";
    priceMin = widget.initialFilters["priceMin"] ?? 0.0;
    priceMax = widget.initialFilters["priceMax"] ?? 50.0;
    minRating = widget.initialFilters["minRating"] ?? 0.0;
    sortBy = widget.initialFilters["sortBy"] ?? "Popular";
  }

  Widget _typeButton(String t) {
    final bool selected = selectedType == t;

    return GestureDetector(
      onTap: () => setState(() => selectedType = t),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
          selected ? AppColors.primary : AppColors.surface.withOpacity(.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected
                  ? Colors.black
                  : AppColors.primary.withOpacity(.3)),
        ),
        child: Text(
          t,
          style: AppTextStyles.body(
              color: selected ? Colors.black : AppColors.text),
        ),
      ),
    );
  }

  Widget _ratingSelector() {
    return Row(
      children: List.generate(5, (i) {
        final filled = (i + 1) <= minRating;
        return GestureDetector(
          onTap: () => setState(() => minRating = (i + 1).toDouble()),
          child: Icon(
            filled ? Icons.star : Icons.star_border,
            color: AppColors.primary,
            size: 28,
          ),
        );
      }),
    );
  }

  Widget _dropdownSort() {
    return DropdownButtonFormField(
      value: sortBy,
      dropdownColor: AppColors.surface,
      decoration: InputDecoration(
        labelText: "Sort by",
        labelStyle: AppTextStyles.caption(),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.border)),
      ),
      items: sortingOptions
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) => setState(() => sortBy = v ?? "Popular"),
    );
  }

  void _reset() {
    setState(() {
      selectedType = "All";
      priceMin = 0;
      priceMax = 50;
      minRating = 0;
      sortBy = "Popular";
    });
  }

  void _apply() {
    widget.onApply({
      "type": selectedType,
      "priceMin": priceMin,
      "priceMax": priceMax,
      "minRating": minRating,
      "sortBy": sortBy,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.primary.withOpacity(.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.3),
            blurRadius: 30,
            spreadRadius: 1,
          )
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24, borderRadius: BorderRadius.circular(10)),
              )),
          const SizedBox(height: 18),

          // 🔵 TYPE
          Text("Asset Type", style: AppTextStyles.title(size: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: types.map((t) => _typeButton(t)).toList(),
          ),

          const SizedBox(height: 20),

          // ⭐ MIN RATING
          Text("Minimum Rating", style: AppTextStyles.title(size: 16)),
          const SizedBox(height: 12),
          _ratingSelector(),

          const SizedBox(height: 20),

          // 💲 PRICE RANGE
          Text("Price Range (\$)", style: AppTextStyles.title(size: 16)),
          const SizedBox(height: 12),
          RangeSlider(
            activeColor: AppColors.primary,
            values: RangeValues(priceMin, priceMax),
            min: 0,
            max: 200,
            divisions: 20,
            onChanged: (v) {
              setState(() {
                priceMin = v.start;
                priceMax = v.end;
              });
            },
          ),
          Text("\$${priceMin.toInt()} - \$${priceMax.toInt()}",
              style: AppTextStyles.caption()),

          const SizedBox(height: 20),

          // 🔽 SORTING
          _dropdownSort(),

          const SizedBox(height: 30),

          // 🟢 ACTIONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  onPressed: _apply,
                  child: const Text("Apply",
                      style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
