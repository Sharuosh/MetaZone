import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'rating_widget.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String type;
  final double price;
  final double rating;
  final IconData icon;
  final VoidCallback onOpenDetails;
  final VoidCallback onPreview;
  final VoidCallback? onAddToCart;

  const ItemCard({
    super.key,
    required this.title,
    required this.type,
    required this.price,
    required this.rating,
    required this.icon,
    required this.onOpenDetails,
    required this.onPreview,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenDetails,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.18),
              blurRadius: 16,
              spreadRadius: 1,
            )
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 Asset Icon
            Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 40, color: AppColors.primary),
              ),
            ),

            const SizedBox(height: 12),

            // 🔤 Title
            Text(title, style: AppTextStyles.title(size: 15)),

            const SizedBox(height: 6),

            // 🏷 Type
            Text(type, style: AppTextStyles.caption()),

            const SizedBox(height: 8),

            // ⭐ Rating
            RatingWidget(rating: rating),

            const Spacer(),

            // 💲 Price + AR Preview + Cart
            Row(
              children: [
                // سعر أو كلمة Free
                Text(
                  price == 0 ? "Free" : "\$${price.toStringAsFixed(2)}",
                  style: AppTextStyles.body(
                      size: 14,
                      color: price == 0 ? Colors.greenAccent : AppColors.text),
                ),

                const Spacer(),

                // 👁 Preview AR
                GestureDetector(
                  onTap: onPreview,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Preview",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // 🛒 Add to cart - يظهر فقط لو المنتج مش Free
                if (price > 0)
                  GestureDetector(
                    onTap: onAddToCart,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_shopping_cart,
                          size: 18, color: Colors.white70),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
