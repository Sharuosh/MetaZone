import 'package:flutter/material.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';
import 'package:meta_zone/screens/home/presentation/widgets/category_item.dart';

class HomeCategories extends StatelessWidget {
final List<HomeCategory> categories;
final int selectedIndex;
final ValueChanged<int>? onSelected;
final VoidCallback? onSeeAll;

const HomeCategories({
super.key,
required this.categories,
this.selectedIndex = 0,
this.onSelected,
this.onSeeAll,
});

@override
Widget build(BuildContext context) {
if (categories.isEmpty) {
return const SizedBox.shrink();
}

final int normalizedSelectedIndex =
selectedIndex >= 0 &&
selectedIndex < categories.length
? selectedIndex
    : -1;

return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildHeader(),
const SizedBox(height: 12),
_buildCategoryList(
selectedIndex: normalizedSelectedIndex,
),
],
);
}

Widget _buildHeader() {
return Row(
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Expanded(
child: Text(
'Explore',
style: AppTextStyles.heading(
size: 20,
color: AppColors.text,
).copyWith(
fontWeight: FontWeight.w700,
),
),
),
_buildSeeAllButton(),
],
);
}

Widget _buildSeeAllButton() {
return Material(
color: Colors.transparent,
child: InkWell(
onTap: onSeeAll,
borderRadius: BorderRadius.circular(10),
child: Padding(
padding: const EdgeInsets.symmetric(
horizontal: 4,
vertical: 5,
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
'See all',
style: AppTextStyles.bodySmallStyle(
size: 13,
color: AppColors.primary,
).copyWith(
fontWeight: FontWeight.w600,
),
),
const SizedBox(width: 3),
Icon(
Icons.chevron_right_rounded,
size: 18,
color: AppColors.primary,
),
],
),
),
),
);
}

Widget _buildCategoryList({
required int selectedIndex,
}) {
return SizedBox(
height: 108,
child: ListView.separated(
scrollDirection: Axis.horizontal,
physics: const BouncingScrollPhysics(),
padding: const EdgeInsets.only(
right: 2,
bottom: 2,
),
itemCount: categories.length,
separatorBuilder: (_, __) {
return const SizedBox(width: 10);
},
itemBuilder: (context, index) {
final HomeCategory category =
categories[index];

return CategoryItem(
category: category,
selected: selectedIndex == index,
onTap: () {
onSelected?.call(index);
},
);
},
),
);
}
}
