import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class LocationPrecisionScreen extends StatefulWidget {
  const LocationPrecisionScreen({super.key});

  @override
  State<LocationPrecisionScreen> createState() => _LocationPrecisionScreenState();
}

class _LocationPrecisionScreenState extends State<LocationPrecisionScreen> {
  String _precision = "City Only";
  // الخيارات:
  // "Exact Location"
  // "Nearby Area (1 km)"
  // "City Only"
  // "Hidden"

  @override
  Widget build(BuildContext context) {
    final options = [
      "Exact Location",
      "Nearby Area (1 km)",
      "City Only",
      "Hidden"
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Location Precision"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            "اختر مستوى دقّة الموقع الذي يتم مشاركته داخل MetaZone.\n"
                "هذا يؤثر على ظهور الـ AR Spots الخاصة بك وموقعك أثناء استخدام التطبيق.",
            style: AppTextStyles.body(),
          ),

          const SizedBox(height: 20),

          ...options.map((opt) {
            return Card(
              color: AppColors.card,
              child: RadioListTile(
                value: opt,
                groupValue: _precision,
                title: Text(opt),
                subtitle: _getDescription(opt),
                onChanged: (v) {
                  setState(() => _precision = v!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Location precision set to: $v")),
                  );
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _getDescription(String value) {
    switch (value) {
      case "Exact Location":
        return const Text("يظهر موقعك الحقيقي بنقطة دقيقة.");
      case "Nearby Area (1 km)":
        return const Text("يظهر موقع تقريبي ضمن دائرة نصف قطرها 1 كم.");
      case "City Only":
        return const Text("يظهر فقط اسم المدينة بدون تفاصيل.");
      case "Hidden":
        return const Text("لا يتم مشاركة موقعك إطلاقًا داخل التطبيق.");
      default:
        return const SizedBox();
    }
  }
}
