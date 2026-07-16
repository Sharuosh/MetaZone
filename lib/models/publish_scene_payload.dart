// File: lib/models/publish_scene_payload.dart
// MetaZone – Publish Scene Payload Model (2025)

import 'dart:convert';
import 'package:flutter/material.dart';

class PublishScenePayload {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final String category;
  final List<String> tags;

  final String privacy;
  final bool locationLocked;
  final double? latitude;
  final double? longitude;
  final double? radius;

  final bool monetizationEnabled;
  final double? price;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String sceneDataJson;
  final String thumbnailBase64;

  PublishScenePayload({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.category,
    required this.tags,
    required this.privacy,
    required this.locationLocked,
    this.latitude,
    this.longitude,
    this.radius,
    required this.monetizationEnabled,
    this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.sceneDataJson,
    required this.thumbnailBase64,
  });

  // --------------------------
  // Convert to JSON
  // --------------------------
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "coverUrl": coverUrl,
      "category": category,
      "tags": tags,
      "privacy": privacy,
      "locationLocked": locationLocked,
      "latitude": latitude,
      "longitude": longitude,
      "radius": radius,
      "monetizationEnabled": monetizationEnabled,
      "price": price,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "sceneDataJson": sceneDataJson,
      "thumbnailBase64": thumbnailBase64,
    };
  }

  // --------------------------
  // Parse from JSON
  // --------------------------
  factory PublishScenePayload.fromJson(Map<String, dynamic> json) {
    return PublishScenePayload(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      coverUrl: json["coverUrl"],
      category: json["category"],
      tags: List<String>.from(json["tags"] ?? []),
      privacy: json["privacy"],
      locationLocked: json["locationLocked"] ?? false,
      latitude: json["latitude"],
      longitude: json["longitude"],
      radius: json["radius"],
      monetizationEnabled: json["monetizationEnabled"] ?? false,
      price: json["price"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      sceneDataJson: json["sceneDataJson"] ?? "{}",
      thumbnailBase64: json["thumbnailBase64"] ?? "",
    );
  }

  // --------------------------
  // Copy With (FIXED)
  // --------------------------
  PublishScenePayload copyWith({
    String? title,
    String? description,
    String? coverUrl,
    String? category,
    List<String>? tags,
    String? privacy,
    bool? locationLocked,
    double? latitude,
    double? longitude,
    double? radius,
    bool? monetizationEnabled,
    double? price,
    DateTime? updatedAt,
    String? sceneDataJson,
    String? thumbnailBase64,
  }) {
    return PublishScenePayload(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      privacy: privacy ?? this.privacy,
      locationLocked: locationLocked ?? this.locationLocked,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      monetizationEnabled: monetizationEnabled ?? this.monetizationEnabled,
      price: price ?? this.price,
      createdAt: this.createdAt,            // 🔥 FIXED
      updatedAt: updatedAt ?? this.updatedAt,
      sceneDataJson: sceneDataJson ?? this.sceneDataJson,
      thumbnailBase64: thumbnailBase64 ?? this.thumbnailBase64,
    );
  }
}
