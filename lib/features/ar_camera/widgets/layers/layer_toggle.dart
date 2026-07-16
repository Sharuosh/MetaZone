import 'package:flutter/material.dart';

class LayerToggle extends StatelessWidget {
  final bool value;
  final Color color;
  final VoidCallback onTap;

  const LayerToggle({
    super.key,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 34,
        height: 18,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: value
              ? color.withOpacity(.25)
              : Colors.white.withOpacity(.08),
          border: Border.all(
            color: value
                ? color.withOpacity(.35)
                : Colors.white.withOpacity(.05),
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              alignment: value
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(3),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value
                      ? color
                      : Colors.white54,
                  boxShadow: [
                    BoxShadow(
                      color: value
                          ? color.withOpacity(.45)
                          : Colors.black26,
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}