// File: lib/screens/ar/scene_builder/publish_scene/services/publish_service_mock.dart
// MetaZone — Publish Service (Ultra PRO Mock 2025)
//
// هذا mock يمثل شكل الـ API الحقيقي اللي هيكون في المستقبل.
// متوافق مع PublishManager بالكامل.
//
// - يدعم progress callback
// - يرجّع PublishScenePayload النهائي
// - فيه stages واضحة (تحضير - رفع - تأكيد)
// - بيستخدم أخطاء منظمة عشان UI يعرف يتصرف

import 'dart:async';
import '../../../../../models/publish_scene_payload.dart';

class PublishServiceMock {
  /// Main upload function — returns final payload after "successful" upload.
  static Future<PublishScenePayload> uploadScene(
      PublishScenePayload payload, {
        required Function(double) onProgress,
      }) async {
    // --------------------------
    // Stage 1 — Preparing Upload
    // --------------------------
    onProgress(0.05);
    await Future.delayed(const Duration(milliseconds: 300));

    // --------------------------
    // Stage 2 — Uploading (Simulated)
    // --------------------------
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 180));
      onProgress(i / 10); // 0.1 → 1.0
    }

    // --------------------------
    // Randomized Simulated Errors
    // --------------------------
    final failChance = DateTime.now().millisecondsSinceEpoch % 7;
    if (failChance == 0) {
      throw PublishServiceError(
        code: "NETWORK_TIMEOUT",
        message: "Upload failed due to unstable network. Please retry.",
      );
    } else if (failChance == 1) {
      throw PublishServiceError(
        code: "SERVER_BUSY",
        message: "Server is currently busy. Try again in a minute.",
      );
    }

    // --------------------------
    // Stage 3 — Server Confirmation
    // --------------------------
    await Future.delayed(const Duration(milliseconds: 350));

    // Return the same payload (in real backend this will modify IDs, URLs, etc.)
    return payload;
  }

  /// Mock for auto-saving drafts (local only)
  static Future<void> autoSaveDraft(PublishScenePayload payload) async {
    await Future.delayed(const Duration(milliseconds: 250));
  }

  /// Delete a draft (mock)
  static Future<bool> deleteDraft(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}

/// Custom structured error class
class PublishServiceError implements Exception {
  final String code;
  final String message;

  PublishServiceError({
    required this.code,
    required this.message,
  });

  @override
  String toString() => "[$code] $message";
}
