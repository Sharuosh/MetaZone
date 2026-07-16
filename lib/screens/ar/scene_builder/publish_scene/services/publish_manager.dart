// File: publish_manager.dart
// MetaZone — Publish Manager (Ultra PRO 2025)
//
// هذا هو قلب عملية نشر المشهد.
// مسؤول عن:
// 1. توليد الـ Thumbnail
// 2. تجهيز payload
// 3. حفظ المسودات
// 4. تنفيذ publish عبر service mock
// 5. إرسال progress updates للـ UI
// 6. التعامل مع الأخطاء بشكل متقدم
//
// * المستقبل *
// يتم استبدال mock services بالباك-اند الحقيقي + Unity engine APIs.

import 'dart:async';
import '../../../../../models/publish_scene_payload.dart';
import 'publish_service_mock.dart';
import 'thumbnail_generator_stub.dart';

class PublishManager {
  PublishManager._();
  static final PublishManager instance = PublishManager._();

  /// Stream to update UI progress in real-time.
  final StreamController<double> _progressCtrl =
  StreamController<double>.broadcast();

  Stream<double> get progressStream => _progressCtrl.stream;

  /// Used for autosave drafts
  final Map<String, PublishScenePayload> _drafts = {};

  // ---------------------------------------------------------
  //  Generate Thumbnail
  // ---------------------------------------------------------
  Future<String> generateThumbnail() async {
    try {
      return await ThumbnailGeneratorStub.captureFromViewport();
    } catch (e) {
      throw Exception("Thumbnail failed: $e");
    }
  }

  // ---------------------------------------------------------
  //  Save Draft
  // ---------------------------------------------------------
  void saveDraft(PublishScenePayload draft) {
    _drafts[draft.id] = draft;
  }

  List<PublishScenePayload> listDrafts() {
    return _drafts.values.toList();
  }

  void deleteDraft(String id) {
    _drafts.remove(id);
  }

  // ---------------------------------------------------------
  //  Publish Scene (Main Operation)
  // ---------------------------------------------------------
  Future<PublishScenePayload> publishScene({
    required PublishScenePayload payload,
  }) async {
    _progressCtrl.add(0.1);

    // Step 1 — Generate thumbnail if missing
    if (payload.thumbnailBase64.isEmpty) {
      final thumb = await generateThumbnail();
      payload = payload.copyWith(thumbnailBase64: thumb);
    }

    _progressCtrl.add(0.35);

    // Step 2 — Upload process (mock service)
    final result = await PublishServiceMock.uploadScene(
      payload,
      onProgress: (p) => _progressCtrl.add(0.35 + p * 0.55),
    );

    _progressCtrl.add(1.0);

    return result;
  }
}
