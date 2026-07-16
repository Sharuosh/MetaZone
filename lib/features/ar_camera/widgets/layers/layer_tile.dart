import 'package:flutter/material.dart';
import 'layer_model.dart';
import 'layer_toggle.dart';

class LayerTile extends StatelessWidget {
  final LayerModel layer;
  final VoidCallback onToggle;

  const LayerTile({
    super.key,
    required this.layer,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        8,
        10,
        8,
        16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            layer.color.withOpacity(.30),
            Colors.black.withOpacity(.08),
          ],
        ),
        border: Border.all(
          color: layer.color.withOpacity(.45),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: layer.color.withOpacity(.18),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            layer.icon,
            color: layer.color,
            size: 24,
          ),

          const SizedBox(height: 10),

          Text(
            layer.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            layer.subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 7,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 10),

          LayerToggle(
            value: layer.enabled,
            color: layer.color,
            onTap: onToggle,
          ),
        ],
      ),
    );
  }
}