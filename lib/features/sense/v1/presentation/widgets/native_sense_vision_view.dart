import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../../../../services/gemini_vision_service.dart';

class NativeSenseVisionView extends StatefulWidget {
  const NativeSenseVisionView({
    super.key,
    this.onSceneChanged,
    this.onObjectTap,
    this.onGeminiSceneChanged,
  });

  final ValueChanged<Map<String, dynamic>>? onSceneChanged;
  final ValueChanged<Map<String, dynamic>>? onObjectTap;

  /// Called whenever the multimodal Gemini analysis produces a new result.
  ///
  /// This is intentionally optional so existing VisionScreen consumers keep
  /// working without any changes.
  final ValueChanged<Map<String, dynamic>>? onGeminiSceneChanged;

  static const String viewType = 'metazone/native_ar_view';

  @override
  State<NativeSenseVisionView> createState() =>
      _NativeSenseVisionViewState();
}

class _NativeSenseVisionViewState
    extends State<NativeSenseVisionView> {
  MethodChannel? _methodChannel;
  Timer? _pollTimer;
  Timer? _geminiTimer;

  Map<String, dynamic> _scene = const <String, dynamic>{};
  Map<String, dynamic> _geminiScene =
  const <String, dynamic>{};

  bool _geminiBusy = false;
  bool _geminiStartedForCurrentView = false;
  String? _geminiError;

  Size _viewportSize = Size.zero;

  final GeminiVisionService _geminiVisionService =
  GeminiVisionService();

  bool get _isAndroid =>
      defaultTargetPlatform == TargetPlatform.android;

  void _onPlatformViewCreated(int viewId) {
    _methodChannel = MethodChannel(
      'metazone/native_ar/vision/methods/$viewId',
    );

    _pollTimer?.cancel();

    Future<void> poll() async {
      final channel = _methodChannel;
      if (channel == null) return;

      try {
        final result = await channel.invokeMethod<dynamic>(
          'getVisionScene',
        );

        if (!mounted || result is! Map) return;

        final scene = Map<String, dynamic>.from(result);

        setState(() {
          _scene = scene;
        });

        widget.onSceneChanged?.call(
          _publicScene(),
        );

        if (
        scene['isLive'] == true &&
            !_geminiStartedForCurrentView
        ) {
          _geminiStartedForCurrentView = true;
          debugPrint(
            '[MetaZone Gemini] native Vision is LIVE; starting multimodal analysis.',
          );
          Future<void>.microtask(_runGeminiAnalysis);
        }
      } on PlatformException catch (error) {
        debugPrint(
          'Sense Vision native scene unavailable: '
              '${error.code}: ${error.message}',
        );
      } catch (error) {
        debugPrint(
          'Sense Vision poll failed: $error',
        );
      }
    }

    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 160),
          (_) => poll(),
    );

    poll();

    _geminiTimer?.cancel();
    _geminiTimer = Timer.periodic(
      const Duration(seconds: 8),
          (_) => _runGeminiAnalysis(),
    );

    // Gemini starts automatically when the first live native scene arrives.
    // The periodic timer then performs bounded follow-up analyses.
  }

  Future<void> _runGeminiAnalysis() async {
    final channel = _methodChannel;

    if (!mounted ||
        channel == null ||
        !_live ||
        _geminiBusy) {
      return;
    }

    _geminiBusy = true;
    _geminiError = null;

    debugPrint(
      '[MetaZone Gemini] analysis cycle started.',
    );

    if (mounted) {
      setState(() {});
    }

    try {
      final captured =
      await channel.invokeMethod<dynamic>(
        'captureVisionFrame',
      );

      final Uint8List imageBytes;

      if (captured is Uint8List) {
        imageBytes = captured;
      } else if (captured is List) {
        imageBytes = Uint8List.fromList(
          captured
              .whereType<num>()
              .map((value) => value.toInt())
              .toList(growable: false),
        );
      } else {
        throw StateError(
          'captureVisionFrame returned no image bytes.',
        );
      }

      if (imageBytes.isEmpty) {
        throw StateError(
          'captureVisionFrame returned an empty image.',
        );
      }

      debugPrint(
        '[MetaZone Gemini] captureVisionFrame returned ${imageBytes.length} bytes.',
      );

      debugPrint(
        '[MetaZone Gemini] sending captured frame to Firebase AI Logic.',
      );

      final result =
      await _geminiVisionService.analyzeFrame(
        imageBytes: imageBytes,
        localContext: _geminiLocalContext(),
      );

      debugPrint(
        '[MetaZone Gemini] Gemini response received: objects=${result.objects.length}, relations=${result.relations.length}.',
      );

      if (!mounted) return;

      final gemini = <String, dynamic>{
        'available': true,
        'status': 'ready',
        'analyzedAtMs':
        DateTime.now().millisecondsSinceEpoch,
        'scene': result.scene,
        'objects': result.objects,
        'relations': result.relations,
      };

      setState(() {
        _geminiScene = gemini;
        _geminiError = null;
      });

      widget.onGeminiSceneChanged?.call(gemini);

      widget.onSceneChanged?.call(
        _publicScene(),
      );
    } on PlatformException catch (error) {
      if (!mounted) return;

      setState(() {
        _geminiScene = <String, dynamic>{
          'available': false,
          'status': 'error',
          'errorCode': error.code,
          'errorMessage':
          error.message ??
              'Unable to capture the Vision frame.',
        };
        _geminiError =
            error.message ?? error.code;
      });

      debugPrint(
        '[MetaZone Gemini] capture failed: '
            '${error.code}: ${error.message}',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _geminiScene = <String, dynamic>{
          'available': false,
          'status': 'error',
          'errorMessage': '$error',
        };
        _geminiError = '$error';
      });

      debugPrint(
        '[MetaZone Gemini] analysis failed: $error',
      );
    } finally {
      _geminiBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  Map<String, dynamic> _geminiLocalContext() {
    final localObjects =
    _nativeObjects
        .take(8)
        .map(
          (object) => <String, dynamic>{
        'trackingId':
        object['trackingId'],
        'primaryLabel':
        object['primaryLabel'],
        'confidence':
        object['confidence'],
        'semanticKind':
        object['semanticKind'],
        'distanceMeters':
        object['distanceMeters'],
        'spatialConfidence':
        object['spatialConfidence'],
        'spatiallyTracked':
        object['spatiallyTracked'],
      },
    )
        .toList(growable: false);

    return <String, dynamic>{
      'isLive': _live,
      'depthReady': _depthReady,
      'objects': localObjects,
    };
  }

  Map<String, dynamic> _publicScene() {
    final enriched =
    Map<String, dynamic>.from(_scene);

    enriched['objects'] = _objects;
    enriched['multimodal'] = _geminiScene;

    if (_geminiError != null) {
      enriched['multimodalStatus'] = 'error';
    } else if (_geminiBusy) {
      enriched['multimodalStatus'] = 'analyzing';
    } else if (_geminiScene['available'] == true) {
      enriched['multimodalStatus'] = 'ready';
    } else {
      enriched['multimodalStatus'] = 'idle';
    }

    return enriched;
  }

  List<Map<String, dynamic>> get _nativeObjects {
    final raw = _scene['objects'];

    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }

    return raw
        .whereType<Map>()
        .map(
          (item) =>
      Map<String, dynamic>.from(item),
    )
        .toList(growable: false);
  }

  List<Map<String, dynamic>> get _objects {
    final aiObjectsRaw = _geminiScene['objects'];

    if (aiObjectsRaw is! List ||
        aiObjectsRaw.isEmpty ||
        _viewportSize == Size.zero) {
      return _nativeObjects;
    }

    final nativeObjects =
        _nativeObjects;

    final nativeRects = <Rect?>[
      for (final object in nativeObjects)
        _bounds(object),
    ];

    final usedNativeIndexes =
    <int>{};

    final merged =
    <Map<String, dynamic>>[];

    for (final rawAi in aiObjectsRaw) {
      if (rawAi is! Map) continue;

      final ai =
      Map<String, dynamic>.from(rawAi);

      final aiRect =
      _aiBoundsInPhysicalPixels(ai);

      if (aiRect == null) continue;

      int? bestNativeIndex;
      double bestScore = 0;

      for (var index = 0;
      index < nativeObjects.length;
      index++) {
        if (usedNativeIndexes.contains(index)) {
          continue;
        }

        final nativeRect =
        nativeRects[index];

        if (nativeRect == null) continue;

        final score =
        _matchScore(
          nativeRect,
          aiRect,
        );

        final nativeLabel =
        '${nativeObjects[index]['primaryLabel'] ?? ''}'
            .trim()
            .toLowerCase();

        final genericNative =
            nativeLabel.isEmpty ||
                nativeLabel == 'object' ||
                nativeLabel == 'unknown';

        final accepted =
            score >= 0.18 ||
                (genericNative &&
                    nativeRect.contains(
                      aiRect.center,
                    ));

        if (accepted &&
            score > bestScore) {
          bestScore = score;
          bestNativeIndex = index;
        }
      }

      final enriched =
      <String, dynamic>{
        ...ai,
        'source': 'multimodal',
        'primaryLabel':
        '${ai['name'] ?? 'Object'}',
        'confidence':
        _number(
          ai['confidence'],
        ).clamp(0, 1),
        'bounds': <String, dynamic>{
          'left': aiRect.left,
          'top': aiRect.top,
          'right': aiRect.right,
          'bottom': aiRect.bottom,
        },
        'description':
        ai['description'],
        'attributes':
        ai['attributes'],
        'visibleAction':
        ai['visible_action'],
      };

      if (bestNativeIndex != null) {
        final native =
        nativeObjects[bestNativeIndex];

        usedNativeIndexes.add(
          bestNativeIndex,
        );

        enriched.addAll(
          <String, dynamic>{
            'trackingId':
            native['trackingId'],
            'semanticKind':
            native['semanticKind'],
            'distanceMeters':
            native['distanceMeters'],
            'spatialConfidence':
            native['spatialConfidence'],
            'worldPosition':
            native['worldPosition'],
            'estimatedSizeMeters':
            native['estimatedSizeMeters'],
            'spatiallyTracked':
            native['spatiallyTracked'],
          },
        );
      }

      merged.add(enriched);
    }

    // Preserve local detections that are specific and were not represented
    // by the current multimodal result.
    for (var index = 0;
    index < nativeObjects.length;
    index++) {
      if (usedNativeIndexes.contains(index)) {
        continue;
      }

      final native =
      nativeObjects[index];

      final label =
      '${native['primaryLabel'] ?? ''}'
          .trim()
          .toLowerCase();

      final generic =
          label.isEmpty ||
              label == 'object' ||
              label == 'unknown';

      if (!generic) {
        merged.add({
          ...native,
          'source': 'local',
        });
      }
    }

    return merged.isEmpty
        ? _nativeObjects
        : merged;
  }

  Rect? _aiBoundsInPhysicalPixels(
      Map<String, dynamic> object,
      ) {
    final raw = object['box'];

    if (raw is! Map) return null;

    final box =
    Map<String, dynamic>.from(raw);

    final x =
    _number(box['x']).clamp(0.0, 1.0);
    final y =
    _number(box['y']).clamp(0.0, 1.0);
    final width =
    _number(box['width']).clamp(0.0, 1.0);
    final height =
    _number(box['height']).clamp(0.0, 1.0);

    final physicalWidth =
        _viewportSize.width *
            _viewportDevicePixelRatio;
    final physicalHeight =
        _viewportSize.height *
            _viewportDevicePixelRatio;

    final left =
        x * physicalWidth;
    final top =
        y * physicalHeight;

    final right =
        (x + width).clamp(0.0, 1.0) *
            physicalWidth;
    final bottom =
        (y + height).clamp(0.0, 1.0) *
            physicalHeight;

    if (right <= left ||
        bottom <= top) {
      return null;
    }

    return Rect.fromLTRB(
      left,
      top,
      right,
      bottom,
    );
  }

  double get _viewportDevicePixelRatio {
    final width =
        _viewportSize.width;

    if (width <= 0) return 1;

    return View.of(
      context,
    ).devicePixelRatio;
  }

  double _matchScore(
      Rect a,
      Rect b,
      ) {
    final intersection =
    a.intersect(b);

    if (intersection.isEmpty) {
      if (a.contains(b.center) ||
          b.contains(a.center)) {
        return 0.20;
      }

      return 0;
    }

    final intersectionArea =
        intersection.width *
            intersection.height;

    final unionArea =
        (a.width * a.height) +
            (b.width * b.height) -
            intersectionArea;

    if (unionArea <= 0) return 0;

    return intersectionArea /
        unionArea;
  }

  bool get _live =>
      _scene['isLive'] == true;

  bool get _depthReady =>
      _scene['depthReady'] == true;

  double _number(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse('$value') ?? 0;
  }

  Rect? _bounds(
      Map<String, dynamic> object,
      ) {
    final raw = object['bounds'];
    if (raw is! Map) return null;

    final map =
    Map<String, dynamic>.from(raw);

    final left =
    _number(map['left']);
    final top =
    _number(map['top']);
    final right =
    _number(map['right']);
    final bottom =
    _number(map['bottom']);

    if (
    right <= left ||
        bottom <= top
    ) {
      return null;
    }

    return Rect.fromLTRB(
      left,
      top,
      right,
      bottom,
    );
  }

  Map<String, dynamic>? _hitObject(
      Offset point,
      double devicePixelRatio,
      ) {
    final physicalPoint =
        point * devicePixelRatio;

    final candidates =
    _objects
        .map(
          (object) => MapEntry(
        object,
        _bounds(object),
      ),
    )
        .where(
          (entry) => entry.value != null,
    )
        .where(
          (entry) =>
          entry.value!.contains(
            physicalPoint,
          ),
    )
        .toList();

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort(
          (a, b) {
        final aRect = a.value!;
        final bRect = b.value!;

        final aArea =
            aRect.width *
                aRect.height;

        final bArea =
            bRect.width *
                bRect.height;

        final areaCompare =
        aArea.compareTo(
          bArea,
        );

        if (areaCompare != 0) {
          return areaCompare;
        }

        final aConfidence =
        _number(
          a.key['confidence'],
        );

        final bConfidence =
        _number(
          b.key['confidence'],
        );

        return bConfidence.compareTo(
          aConfidence,
        );
      },
    );

    return candidates.first.key;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;

    _geminiTimer?.cancel();
    _geminiTimer = null;

    _methodChannel = null;

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    if (!_isAndroid) {
      return const ColoredBox(
        color: Colors.black,
      );
    }

    final media = MediaQuery.of(context);
    final dpr = media.devicePixelRatio;

    _viewportSize = media.size;

    return Stack(
      fit: StackFit.expand,
      children: [
        PlatformViewLink(
          viewType:
          NativeSenseVisionView.viewType,
          surfaceFactory: (
              BuildContext context,
              PlatformViewController controller,
              ) {
            return AndroidViewSurface(
              controller:
              controller as AndroidViewController,
              gestureRecognizers:
              const <Factory<
                  OneSequenceGestureRecognizer>>{},
              hitTestBehavior:
              PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (
              PlatformViewCreationParams params,
              ) {
            final controller =
            PlatformViewsService
                .initSurfaceAndroidView(
              id: params.id,
              viewType:
              NativeSenseVisionView.viewType,
              layoutDirection:
              TextDirection.ltr,
              creationParams:
              const <String, dynamic>{
                'mode': 'sense',
                'visionMode': true,
              },
              creationParamsCodec:
              const StandardMessageCodec(),
            );

            controller
                .addOnPlatformViewCreatedListener(
              params.onPlatformViewCreated,
            );

            controller
                .addOnPlatformViewCreatedListener(
              _onPlatformViewCreated,
            );

            controller.create();
            return controller;
          },
        ),

        /*
         * Detection overlays live in Flutter space.
         * They are visual only; a separate full-screen gesture layer below
         * handles Vision selection.
         */
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _VisionDetectionPainter(
                objects: _objects,
                devicePixelRatio: dpr,
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: GestureDetector(
            behavior:
            HitTestBehavior.translucent,
            onTapUp: (details) {
              final object =
              _hitObject(
                details.localPosition,
                dpr,
              );

              if (object != null) {
                widget.onObjectTap?.call(
                  object,
                );
              }
            },
            child: const SizedBox.expand(),
          ),
        ),

        Positioned(
          left: 18,
          right: 18,
          bottom: 166,
          child: IgnorePointer(
            child: _VisionLiveIndicator(
              live: _live,
              depthReady: _depthReady,
              geminiReady:
              _geminiScene['available'] == true,
              geminiBusy: _geminiBusy,
            ),
          ),
        ),
      ],
    );
  }
}

class _VisionDetectionPainter
    extends CustomPainter {
  const _VisionDetectionPainter({
    required this.objects,
    required this.devicePixelRatio,
  });

  final List<Map<String, dynamic>> objects;
  final double devicePixelRatio;

  double _number(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse('$value') ?? 0;
  }

  Rect? _bounds(
      Map<String, dynamic> object,
      ) {
    final raw = object['bounds'];

    if (raw is! Map) {
      return null;
    }

    final map =
    Map<String, dynamic>.from(raw);

    final left =
        _number(map['left']) /
            devicePixelRatio;
    final top =
        _number(map['top']) /
            devicePixelRatio;
    final right =
        _number(map['right']) /
            devicePixelRatio;
    final bottom =
        _number(map['bottom']) /
            devicePixelRatio;

    if (
    right <= left ||
        bottom <= top
    ) {
      return null;
    }

    return Rect.fromLTRB(
      left,
      top,
      right,
      bottom,
    );
  }

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    for (final object in objects) {
      final rect =
      _bounds(object);

      if (rect == null) {
        continue;
      }

      final confidence =
      _number(
        object['confidence'],
      ).clamp(0, 1);

      final label =
          '${object['primaryLabel'] ?? 'Object'}';

      final color =
      const Color(0xFF9B6CFF);

      final radius =
      math.min(
        18,
        math.min(
          rect.width,
          rect.height,
        ) *
            0.12,
      );

      final paint =
      Paint()
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color =
        color.withValues(
          alpha: 0.80,
        );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular(
            radius.toDouble(),
          ),
        ),
        paint,
      );

      final bgPaint =
      Paint()
        ..style =
            PaintingStyle.fill
        ..color =
        Colors.black.withValues(
          alpha: 0.72,
        );

      final labelWidth =
      (label.length * 7.1)
          .clamp(62, 180)
          .toDouble();

      final pillRect =
      Rect.fromLTWH(
        rect.left,
        math.max(
          8,
          rect.top - 30,
        ),
        labelWidth + 28,
        24,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          pillRect,
          const Radius.circular(12),
        ),
        bgPaint,
      );

      final textPainter =
      TextPainter(
        text:
        TextSpan(
          text:
          '$label  ${(confidence * 100).round()}%',
          style:
          const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection:
        TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(
        maxWidth:
        pillRect.width - 16,
      );

      textPainter.paint(
        canvas,
        Offset(
          pillRect.left + 10,
          pillRect.top + 5,
        ),
      );

      final corner =
      Paint()
        ..color =
        color.withValues(
          alpha: 0.95,
        )
        ..strokeWidth = 2.4
        ..style =
            PaintingStyle.stroke;

      const cornerLength = 11.0;

      final points = [
        [
          Offset(
            rect.left,
            rect.top + cornerLength,
          ),
          Offset(
            rect.left,
            rect.top,
          ),
          Offset(
            rect.left + cornerLength,
            rect.top,
          ),
        ],
        [
          Offset(
            rect.right - cornerLength,
            rect.top,
          ),
          Offset(
            rect.right,
            rect.top,
          ),
          Offset(
            rect.right,
            rect.top + cornerLength,
          ),
        ],
        [
          Offset(
            rect.left,
            rect.bottom - cornerLength,
          ),
          Offset(
            rect.left,
            rect.bottom,
          ),
          Offset(
            rect.left + cornerLength,
            rect.bottom,
          ),
        ],
        [
          Offset(
            rect.right - cornerLength,
            rect.bottom,
          ),
          Offset(
            rect.right,
            rect.bottom,
          ),
          Offset(
            rect.right,
            rect.bottom - cornerLength,
          ),
        ],
      ];

      for (final pathPoints in points) {
        final path =
        Path()
          ..moveTo(
            pathPoints[0].dx,
            pathPoints[0].dy,
          )
          ..lineTo(
            pathPoints[1].dx,
            pathPoints[1].dy,
          )
          ..lineTo(
            pathPoints[2].dx,
            pathPoints[2].dy,
          );

        canvas.drawPath(
          path,
          corner,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
      covariant _VisionDetectionPainter oldDelegate,
      ) {
    return oldDelegate.objects !=
        objects ||
        oldDelegate.devicePixelRatio !=
            devicePixelRatio;
  }
}

class _VisionLiveIndicator
    extends StatelessWidget {
  const _VisionLiveIndicator({
    required this.live,
    required this.depthReady,
    required this.geminiReady,
    required this.geminiBusy,
  });

  final bool live;
  final bool depthReady;
  final bool geminiReady;
  final bool geminiBusy;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color:
          Colors.black.withValues(
            alpha: 0.36,
          ),
          borderRadius:
          BorderRadius.circular(
            15,
          ),
          border: Border.all(
            color:
            Colors.white.withValues(
              alpha: 0.12,
            ),
          ),
        ),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration:
              BoxDecoration(
                shape:
                BoxShape.circle,
                color:
                live
                    ? const Color(
                  0xFF9B6CFF,
                )
                    : Colors.white38,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              live
                  ? 'VISION LIVE'
                  : 'VISION STARTING',
              style:
              const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight:
                FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            if (depthReady) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFF9B6CFF,
                  ).withValues(alpha: .12),
                  borderRadius:
                  BorderRadius.circular(7),
                ),
                child:
                const Text(
                  'SPATIAL',
                  style:
                  TextStyle(
                    color:
                    Color(
                      0xFFBFA6FF,
                    ),
                    fontSize: 7,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing:
                    .8,
                  ),
                ),
              ),
            ],
            if (geminiReady || geminiBusy) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration:
                BoxDecoration(
                  color:
                  Colors.white.withValues(alpha: .08),
                  borderRadius:
                  BorderRadius.circular(7),
                ),
                child:
                Text(
                  geminiBusy ? 'AI…' : 'AI',
                  style:
                  const TextStyle(
                    color: Colors.white70,
                    fontSize: 7,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing:
                    .8,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

