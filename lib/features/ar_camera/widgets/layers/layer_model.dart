import 'package:flutter/material.dart';

class LayerModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  bool enabled;

  LayerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.enabled = true,
  });
}