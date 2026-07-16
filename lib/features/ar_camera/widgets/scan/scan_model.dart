import 'package:flutter/material.dart';

class ScanModel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  const ScanModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}