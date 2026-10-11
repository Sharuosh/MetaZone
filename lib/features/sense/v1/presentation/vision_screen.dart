import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import 'widgets/native_sense_vision_view.dart';

/// MetaZone Sense -> Vision.
///
/// User experience:
/// Camera -> live perception -> stable detection -> tap object -> object card.
///
/// This screen does not place AR content.
class VisionScreen extends StatefulWidget {
  const VisionScreen({super.key});

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  Map<String, dynamic> _scene =
  const <String, dynamic>{};

  Map<String, dynamic>? _selectedObject;

  List<Map<String, dynamic>> get _objects {
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

  List<Map<String, dynamic>> get _labels {
    final raw = _scene['labels'];

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

  Map<String, dynamic> get _environment {
    final raw =
    _scene['environment'];

    if (raw is! Map) {
      return const <String, dynamic>{};
    }

    return Map<String, dynamic>.from(
      raw,
    );
  }

  bool get _isLive =>
      _scene['isLive'] == true;

  bool get _tracking =>
      '${_scene['trackingState'] ?? ''}' ==
          'TRACKING';

  bool get _depthReady =>
      _scene['depthReady'] == true;

  void _handleSceneChanged(
      Map<String, dynamic> scene,
      ) {
    if (!mounted) return;

    setState(() {
      _scene = scene;

      final selected =
          _selectedObject;

      if (selected == null) {
        return;
      }

      final selectedId =
      _objectId(selected);

      if (
      !_objects.any(
            (object) =>
        _objectId(object) ==
            selectedId,
      )) {
        _selectedObject = null;
      }
    });
  }

  void _handleObjectTap(
      Map<String, dynamic> object,
      ) {
    if (!mounted) return;

    setState(() {
      _selectedObject =
          object;
    });
  }

  String _objectId(
      Map<String, dynamic> object,
      ) {
    return '${object['trackingId'] ?? object['primaryLabel'] ?? 'object'}';
  }

  double _number(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      '$value',
    ) ??
        0;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          NativeSenseVisionView(
            onSceneChanged:
            _handleSceneChanged,
            onObjectTap:
            _handleObjectTap,
          ),
          const _VisionCameraScrim(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const Spacer(),
                _buildSceneChips(),
                const SizedBox(height: 10),
                _buildBottomPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        0,
      ),
      child: Row(
        children: [
          _GlassIconButton(
            icon:
            Icons.arrow_back_rounded,
            onTap: () =>
                Navigator.of(
                  context,
                ).maybePop(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Vision',
                  style:
                  AppTextStyles.heading(
                    size: 21,
                  ).copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _isLive
                      ? 'LIVE UNDERSTANDING'
                      : 'STARTING VISION',
                  style:
                  AppTextStyles.caption(
                    size: 9,
                  ).copyWith(
                    color:
                    AppColors.primary,
                    fontWeight:
                    FontWeight.w700,
                    letterSpacing:
                    1.2,
                  ),
                ),
              ],
            ),
          ),
          _StatusPill(
            live: _isLive,
            tracking: _tracking,
          ),
        ],
      ),
    );
  }

  Widget _buildSceneChips() {
    final objectChips =
    _objects
        .take(5)
        .map(
          (object) {
        final selected =
            _selectedObject !=
                null &&
                _objectId(
                  _selectedObject!,
                ) ==
                    _objectId(
                      object,
                    );

        return _DetectionChip(
          label:
          '${object['primaryLabel'] ?? 'Object'}',
          confidence:
          _number(
            object['confidence'],
          ),
          selected:
          selected,
          onTap: () {
            setState(() {
              _selectedObject =
              selected
                  ? null
                  : object;
            });
          },
        );
      },
    )
        .toList();

    final labelChips =
    _labels
        .where(
          (label) =>
      '${label['text'] ?? ''}'
          .trim()
          .isNotEmpty,
    )
        .take(3)
        .map(
          (label) =>
          _DetectionChip(
            label:
            '${label['text']}',
            confidence:
            _number(
              label['confidence'],
            ),
            selected: false,
            onTap: () {},
          ),
    )
        .toList();

    final chips = [
      ...objectChips,
      ...labelChips,
    ];

    if (chips.isEmpty) {
      return Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        child:
        _GlassMessage(
          icon:
          Icons.radar_rounded,
          title:
          _isLive
              ? 'Looking around…'
              : 'Preparing Vision…',
          message:
          _isLive
              ? 'Move the camera slowly and keep the scene clear.'
              : 'The perception engine is starting.',
        ),
      );
    }

    return SizedBox(
      height: 42,
      child:
      ListView.separated(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        scrollDirection:
        Axis.horizontal,
        itemCount:
        chips.length,
        separatorBuilder:
            (_, __) =>
        const SizedBox(
          width: 8,
        ),
        itemBuilder:
            (_, index) =>
        chips[index],
      ),
    );
  }

  Widget _buildBottomPanel() {
    final selected =
        _selectedObject;

    return Container(
      width:
      double.infinity,
      decoration:
      BoxDecoration(
        color:
        AppColors.card
            .withOpacity(.95),
        borderRadius:
        const BorderRadius.vertical(
          top:
          Radius.circular(24),
        ),
        border:
        Border(
          top:
          BorderSide(
            color:
            AppColors.primary
                .withOpacity(.18),
          ),
        ),
      ),
      padding:
      const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        18,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                  BoxDecoration(
                    shape:
                    BoxShape.circle,
                    color:
                    AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color:
                        AppColors.primary
                            .withOpacity(
                          .40,
                        ),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_objects.length} objects',
                  style:
                  AppTextStyles.title(
                    size: 14,
                  ).copyWith(
                    color:
                    Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  '${_labels.length} scene labels',
                  style:
                  AppTextStyles.caption(
                    size: 11,
                  ).copyWith(
                    color:
                    Colors.white70,
                  ),
                ),
                const Spacer(),
                _EnvironmentBadge(
                  label:
                  _environmentLabel(),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            if (selected != null)
              _SelectedObjectCard(
                object:
                selected,
                depthReady:
                _depthReady,
                onClose: () {
                  setState(() {
                    _selectedObject =
                    null;
                  });
                },
              )
            else
              _VisionInstruction(
                live:
                _isLive,
                hasObjects:
                _objects.isNotEmpty,
                onHintTap:
                    () {},
              ),
          ],
        ),
      ),
    );
  }

  String _environmentLabel() {
    if (_environment[
    'hasPerson'
    ] ==
        true) {
      return 'PERSON';
    }

    if (_environment[
    'hasVehicle'
    ] ==
        true) {
      return 'VEHICLE';
    }

    if (_environment[
    'hasFurniture'
    ] ==
        true) {
      return 'FURNITURE';
    }

    if (_environment[
    'hasVegetation'
    ] ==
        true) {
      return 'VEGETATION';
    }

    if (_environment[
    'hasBuildingElement'
    ] ==
        true) {
      return 'STRUCTURE';
    }

    if (_environment[
    'hasFloorLikeSurface'
    ] ==
        true) {
      return 'SURFACE';
    }

    return 'SCENE';
  }
}

class _VisionCameraScrim
    extends StatelessWidget {
  const _VisionCameraScrim();

  @override
  Widget build(
      BuildContext context,
      ) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration:
        BoxDecoration(
          gradient:
          LinearGradient(
            begin:
            Alignment.topCenter,
            end:
            Alignment.bottomCenter,
            stops:
            const [
              0,
              .26,
              .62,
              1,
            ],
            colors: [
              Colors.black
                  .withOpacity(
                .44,
              ),
              Colors.transparent,
              Colors.transparent,
              Colors.black
                  .withOpacity(
                .75,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton
    extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color:
      Colors.black.withOpacity(
        .28,
      ),
      shape:
      const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder:
        const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration:
          BoxDecoration(
            shape:
            BoxShape.circle,
            border:
            Border.all(
              color:
              Colors.white
                  .withOpacity(
                .16,
              ),
            ),
          ),
          child: Icon(
            icon,
            color:
            Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _StatusPill
    extends StatelessWidget {
  const _StatusPill({
    required this.live,
    required this.tracking,
  });

  final bool live;
  final bool tracking;

  @override
  Widget build(
      BuildContext context,
      ) {
    final active =
        live && tracking;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.black.withOpacity(
          .30,
        ),
        borderRadius:
        BorderRadius.circular(
          999,
        ),
        border:
        Border.all(
          color:
          (
              active
                  ? AppColors.primary
                  : Colors.white24
          ).withOpacity(
            .45,
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
              active
                  ? AppColors.primary
                  : Colors.white54,
            ),
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            active
                ? 'LIVE'
                : live
                ? 'SYNC'
                : 'WAIT',
            style:
            const TextStyle(
              color:
              Colors.white,
              fontSize: 9,
              fontWeight:
              FontWeight.w800,
              letterSpacing:
              1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassMessage
    extends StatelessWidget {
  const _GlassMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.black
            .withOpacity(
          .35,
        ),
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        border:
        Border.all(
          color:
          Colors.white
              .withOpacity(
            .12,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
            AppColors.primary,
            size: 19,
          ),
          const SizedBox(
            width: 9,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  message,
                  style:
                  const TextStyle(
                    color:
                    Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetectionChip
    extends StatelessWidget {
  const _DetectionChip({
    required this.label,
    required this.confidence,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double confidence;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color:
      selected
          ? AppColors.primary
          .withOpacity(
        .20,
      )
          : Colors.black.withOpacity(
        .36,
      ),
      borderRadius:
      BorderRadius.circular(
        14,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          14,
        ),
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              14,
            ),
            border:
            Border.all(
              color:
              selected
                  ? AppColors.primary
                  .withOpacity(
                .55,
              )
                  : Colors.white
                  .withOpacity(
                .12,
              ),
            ),
          ),
          child: Row(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radar_rounded,
                color:
                selected
                    ? AppColors.primary
                    : Colors.white70,
                size: 14,
              ),
              const SizedBox(
                width: 6,
              ),
              Text(
                label,
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              Text(
                '${(confidence.clamp(0, 1) * 100).round()}%',
                style:
                TextStyle(
                  color:
                  selected
                      ? AppColors.primary
                      : Colors.white54,
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnvironmentBadge
    extends StatelessWidget {
  const _EnvironmentBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration:
      BoxDecoration(
        color:
        AppColors.primary
            .withOpacity(
          .10,
        ),
        borderRadius:
        BorderRadius.circular(
          9,
        ),
        border:
        Border.all(
          color:
          AppColors.primary
              .withOpacity(
            .20,
          ),
        ),
      ),
      child: Text(
        label,
        style:
        TextStyle(
          color:
          AppColors.primary,
          fontSize: 8,
          fontWeight:
          FontWeight.w800,
          letterSpacing:
          .9,
        ),
      ),
    );
  }
}

class _VisionInstruction
    extends StatelessWidget {
  const _VisionInstruction({
    required this.live,
    required this.hasObjects,
    required this.onHintTap,
  });

  final bool live;
  final bool hasObjects;
  final VoidCallback onHintTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    final title =
    !live
        ? 'Preparing Vision'
        : hasObjects
        ? 'Vision is watching'
        : 'Looking around…';

    final message =
    !live
        ? 'Starting the native perception engine.'
        : hasObjects
        ? 'Tap a detected object to inspect it.'
        : 'Move the camera slowly and keep the scene clear.';

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration:
          BoxDecoration(
            shape:
            BoxShape.circle,
            color:
            AppColors.primary
                .withOpacity(
              .10,
            ),
          ),
          child: Icon(
            hasObjects
                ? Icons.center_focus_strong_rounded
                : Icons.radar_rounded,
            color:
            AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(
          width: 11,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                message,
                style:
                const TextStyle(
                  color:
                  Colors.white70,
                  fontSize: 10.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectedObjectCard
    extends StatelessWidget {
  const _SelectedObjectCard({
    required this.object,
    required this.depthReady,
    required this.onClose,
  });

  final Map<String, dynamic> object;
  final bool depthReady;
  final VoidCallback onClose;

  double _number(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      '$value',
    ) ??
        0;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final label =
        '${object['primaryLabel'] ?? 'Object'}';

    final kind =
        '${object['semanticKind'] ?? 'UNKNOWN'}';

    final confidence =
    _number(
      object['confidence'],
    ).clamp(
      0,
      1,
    );

    final trackingId =
        '${object['trackingId'] ?? -1}';

    final spatial =
        object['spatiallyTracked'] ==
            true;

    final distance =
    _number(
      object['distanceMeters'],
    );

    return Container(
      padding:
      const EdgeInsets.all(
        13,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.black
            .withOpacity(
          .20,
        ),
        borderRadius:
        BorderRadius.circular(
          17,
        ),
        border:
        Border.all(
          color:
          AppColors.primary
              .withOpacity(
            .22,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,
                  color:
                  AppColors.primary
                      .withOpacity(
                    .12,
                  ),
                ),
                child:
                const Icon(
                  Icons.visibility_rounded,
                  color:
                  Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(
                width: 11,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      '$kind  •  ${(confidence * 100).round()}%  •  #$trackingId',
                      style:
                      const TextStyle(
                        color:
                        Colors.white60,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed:
                onClose,
                tooltip:
                'Clear selection',
                icon:
                const Icon(
                  Icons.close_rounded,
                  color:
                  Colors.white70,
                  size: 19,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              _MetaFact(
                icon:
                Icons.straighten_rounded,
                label:
                spatial
                    ? '${distance.toStringAsFixed(1)} m'
                    : 'Distance pending',
              ),
              const SizedBox(
                width: 8,
              ),
              _MetaFact(
                icon:
                Icons.public_rounded,
                label:
                spatial
                    ? 'SPATIAL'
                    : depthReady
                    ? 'DEPTH READY'
                    : '2D ONLY',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaFact
    extends StatelessWidget {
  const _MetaFact({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9,
        ),
        decoration:
        BoxDecoration(
          color:
          Colors.white
              .withOpacity(
            .05,
          ),
          borderRadius:
          BorderRadius.circular(
            12,
          ),
          border:
          Border.all(
            color:
            Colors.white
                .withOpacity(
              .08,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
              AppColors.primary,
              size: 15,
            ),
            const SizedBox(
              width: 6,
            ),
            Expanded(
              child: Text(
                label,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
