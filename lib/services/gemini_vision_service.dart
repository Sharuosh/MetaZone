import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

/// MetaZone Sense — Multimodal Vision bridge.
///
/// ARCore/Depth/local perception can keep running continuously, while this
/// service receives selected camera frames for deeper visual understanding.
class GeminiVisionService {
  GeminiVisionService({
    String modelName = _defaultModel,
  }) : _model = FirebaseAI.googleAI(
    appCheck: FirebaseAppCheck.instance,
  ).generativeModel(
    model: modelName,
  );

  static const String _defaultModel = 'gemini-3.8-flash';

  final GenerativeModel _model;

  /// Sends one selected camera frame to Gemini and asks for structured
  /// scene understanding.
  Future<GeminiVisionResult> analyzeFrame({
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
    String? userQuestion,
    Map<String, dynamic>? localContext,
  }) async {
    if (imageBytes.isEmpty) {
      throw ArgumentError('imageBytes cannot be empty.');
    }

    final contextText = localContext == null
        ? ''
        : '\nLocal AR context (use only as supporting evidence; do not invent '
        'visual facts from it): ${jsonEncode(localContext)}\n';

    final questionText = userQuestion == null || userQuestion.trim().isEmpty
        ? 'Understand the visible scene.'
        : userQuestion.trim();

    final prompt = """
You are MetaZone Sense Vision, a visual understanding engine.

Analyze the supplied camera image carefully.

Goals:
1. Identify the meaningful visible objects and scene elements.
2. For each object, describe only details that are visually supported.
3. Include approximate visual location using normalized coordinates:
   x, y, width, height where each value is from 0.0 to 1.0.
4. Note visible spatial relationships between objects when they are clear.
5. Recognize visible human activity only when the action is visually supported.
6. Never invent exact brand, model, material, identity, text, measurements,
   or hidden information.
7. When uncertain, say so or use null rather than guessing.
8. Do not use a generic "Object" label when a more specific description is
   visually possible.
9. Treat this as visual perception, not a medical, psychological, or
   identity system.

User request:
$questionText
$contextText

Return ONLY valid JSON matching this shape:

{
  "scene": {
    "summary": "string",
    "location_type": "string or null"
  },
  "objects": [
    {
      "name": "string",
      "description": "string",
      "confidence": 0.0,
      "box": {
        "x": 0.0,
        "y": 0.0,
        "width": 0.0,
        "height": 0.0
      },
      "attributes": {
        "color": "string or null",
        "shape": "string or null",
        "material": "string or null",
        "text_visible": "string or null"
      },
      "visible_action": "string or null"
    }
  ],
  "relations": [
    {
      "subject": "string",
      "relation": "string",
      "object": "string"
    }
  ]
}
""";

    final response = await _model.generateContent([
      Content.multi([
        TextPart(prompt),
        InlineDataPart(mimeType, imageBytes),
      ]),
    ]);

    final rawText = response.text?.trim() ?? '';

    if (rawText.isEmpty) {
      throw StateError('Gemini returned an empty response.');
    }

    final decoded = _decodeJson(rawText);

    return GeminiVisionResult.fromJson(
      decoded,
      rawText: rawText,
    );
  }

  Map<String, dynamic> _decodeJson(String rawText) {
    var text = rawText.trim();

    if (text.startsWith('```')) {
      final firstNewline = text.indexOf('\n');
      final lastFence = text.lastIndexOf('```');

      if (firstNewline != -1 && lastFence > firstNewline) {
        text = text.substring(firstNewline + 1, lastFence).trim();
      }
    }

    try {
      final decoded = jsonDecode(text);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Fall through to extracting the largest JSON object.
    }

    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');

    if (start != -1 && end > start) {
      final candidate = text.substring(start, end + 1);
      final decoded = jsonDecode(candidate);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    throw FormatException(
      'Gemini response was not valid JSON.\n$rawText',
    );
  }
}

class GeminiVisionResult {
  const GeminiVisionResult({
    required this.rawText,
    required this.scene,
    required this.objects,
    required this.relations,
  });

  factory GeminiVisionResult.fromJson(
      Map<String, dynamic> json, {
        required String rawText,
      }) {
    final rawScene = json['scene'];
    final rawObjects = json['objects'];
    final rawRelations = json['relations'];

    return GeminiVisionResult(
      rawText: rawText,
      scene: rawScene is Map
          ? Map<String, dynamic>.from(rawScene)
          : const <String, dynamic>{},
      objects: rawObjects is List
          ? rawObjects
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
      )
          .toList(growable: false)
          : const <Map<String, dynamic>>[],
      relations: rawRelations is List
          ? rawRelations
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
      )
          .toList(growable: false)
          : const <Map<String, dynamic>>[],
    );
  }

  final String rawText;
  final Map<String, dynamic> scene;
  final List<Map<String, dynamic>> objects;
  final List<Map<String, dynamic>> relations;
}