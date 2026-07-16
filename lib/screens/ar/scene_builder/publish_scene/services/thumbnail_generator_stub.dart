// File: thumbnail_generator_stub.dart
// MetaZone — Thumbnail Generator Stub (PRO Edition 2025)
//
// هذا الملف عبارة عن واجهة مؤقتة (Stub) لحين ربط Unity أو
// AR Engine الحقيقي لتوليد صورة thumbnail للمشهد.
// حالياً يقوم بإرجاع صورة Base64 بسيطة + supports fake generation.
//
// لاحقاً سيتم استبداله بوظيفة:
// UnityRenderAPI.generateThumbnail(sceneId)
//
// ————————————————————————————————————————————————

import 'dart:async';

class ThumbnailGeneratorStub {
  /// Generate a fake thumbnail (Base64 PNG)
  /// Used ONLY for UI development and previews.
  static Future<String> generateThumbnail({
    String? sceneId,
    int width = 1280,
    int height = 720,
  }) async {
    // Simulate processing time
    await Future.delayed(const Duration(milliseconds: 400));

    // Transparent 1×1 pixel PNG (Base64)
    const base64Placeholder =
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGNgYGBgAAAABQAB"
        "JzQnCgAAAABJRU5ErkJggg==";

    return base64Placeholder;
  }

  /// Simulate capturing thumbnail directly from the Scene Builder viewport.
  /// Later replaced by a real Unity capture function.
  static Future<String> captureFromViewport() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return generateThumbnail();
  }

  /// Simulate failure (for testing error UI screens)
  static Future<String> generateBrokenThumbnail() async {
    await Future.delayed(const Duration(milliseconds: 350));
    throw Exception("Thumbnail rendering failed — Unity engine not available.");
  }
}
