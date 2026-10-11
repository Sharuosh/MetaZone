import 'package:flutter/material.dart';

import '../../widgets/native_ar_view.dart';
import '../theme/ar_camera_theme.dart';
import '../widgets/ar_bottom_bar.dart';
import '../widgets/ar_reticle.dart';
import '../widgets/ar_side_rail.dart';
import '../widgets/ar_top_bar.dart';
import '../widgets/create_wheel.dart';
import '../widgets/object_library.dart';
import '../widgets/object_placement.dart';
import '../widgets/object_preview.dart';
import '../widgets/object_save_publish.dart';
import '../widgets/object_selected_editor.dart';

/// MetaZone AR Camera V1 — orchestration layer.
///
/// This screen is now the Flutter-side owner of the Object creation flow:
///
/// Create
///   ↓
/// Create Wheel
///   ↓
/// Object Library
///   ↓
/// Object Preview / Details
///   ↓
/// Object Placement
///   ↓
/// Selected Object / Editor
///   ↓
/// Save / Publish
///   ↓
/// AR Camera
///
/// Flutter owns navigation/state orchestration only.
///
/// UNITY INTEGRATION POINTS are deliberately kept as callbacks/state inputs:
/// - Real surface detection
/// - AR hit testing / pose
/// - Object instantiation
/// - 3D transform synchronization
/// - Object deletion / duplication in Unity
///
/// No Unity AR state is fabricated by this screen.
class ARCameraScreen extends StatefulWidget {
  const ARCameraScreen({
    super.key,
    this.zoneName = 'Downtown Cairo',
  });

  final String zoneName;

  @override
  State<ARCameraScreen> createState() => _ARCameraScreenState();
}

enum _ARCameraFlow {
  camera,
  objectLibrary,
  objectPreview,
  objectPlacement,
  selectedEditor,
  savePublish,
}

class _ARCameraScreenState extends State<ARCameraScreen> {
  _ARCameraFlow _flow = _ARCameraFlow.camera;
  ARLibraryObject? _selectedObject;

  bool _sideRailExpanded = false;
  bool _showCreateWheel = false;
  bool _compassActive = false;
  bool _captureActive = false;
  bool _scanActive = false;
  bool _layersActive = false;

  ARReticleState _reticleState = ARReticleState.searching;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ARCameraTheme.cameraFallback,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: NativeArView()),
          const Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: ARCameraTheme.cameraScrim),
            ),
          ),

          // Base AR camera UI is hidden behind creation/editor flows.
          if (_flow == _ARCameraFlow.camera) ...[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ARTopBar(
                zoneName: widget.zoneName,
                zoneSubtitle: 'AR Space',
                compassActive: _compassActive,
                onBack: _handleBack,
                onCompassTap: _handleCompass,
                onControlsTap: _toggleSideRail,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Center(child: ARReticle(state: _reticleState)),
              ),
            ),
            Positioned(
              top: 0,
              right: ARCameraTheme.horizontalPadding,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: ARSideRail(
                    expanded: _sideRailExpanded,
                    onToggle: _toggleSideRail,
                    onCapture: _handleCapture,
                    onScan: _handleScan,
                    onLayers: _handleLayers,
                    captureActive: _captureActive,
                    scanActive: _scanActive,
                    layersActive: _layersActive,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ARBottomBar(
                activeItem: ARBottomBarItem.create,
                onExplore: _handleExplore,
                onCreate: _handleCreate,
                onProfile: _handleProfile,
              ),
            ),
          ],

          if (_showCreateWheel && _flow == _ARCameraFlow.camera)
            CreateWheel(
              visible: true,
              onClose: _closeCreateWheel,
              onObject: _openObjectLibrary,
              onComment: () => _showComingSoon('Spatial Comment'),
              onMemory: () => _showComingSoon('Memory'),
            ),

          if (_flow == _ARCameraFlow.objectLibrary)
            ObjectLibrary(
              onClose: _returnToCamera,
              onObjectSelected: _openObjectPreview,
            ),

          if (_flow == _ARCameraFlow.objectPreview && _selectedObject != null)
            ObjectPreview(
              object: _selectedObject!,
              onBack: _returnToObjectLibrary,
              onPlace: _openObjectPlacement,
            ),

          if (_flow == _ARCameraFlow.objectPlacement && _selectedObject != null)
            ObjectPlacement(
              object: _selectedObject!,
              onBack: _returnToObjectPreview,
              onCancel: _returnToObjectLibrary,
              onPlace: _handlePlacementConfirmed,
              // UNITY INTEGRATION POINT:
              // Replace the default false with the real Unity/ARCore
              // surface-valid state once the native bridge is connected.
              surfaceDetected: false,
              onScanRequested: _requestUnitySurfaceScan,
            ),

          if (_flow == _ARCameraFlow.selectedEditor && _selectedObject != null)
            ObjectSelectedEditor(
              object: _selectedObject!,
              onDone: _openSavePublish,
              onDelete: _deleteSelectedObject,
              onDuplicate: _duplicateSelectedObject,
              onEdit: _returnToObjectPlacement,
            ),

          if (_flow == _ARCameraFlow.savePublish && _selectedObject != null)
            ObjectSavePublish(
              object: _selectedObject!,
              onBack: _returnToSelectedEditor,
              onSaveDraft: _saveDraft,
              onPublish: _publishObject,
            ),
        ],
      ),
    );
  }

  // ========================================================================
  // CREATE FLOW
  // ========================================================================

  void _handleCreate() {
    if (!mounted) return;

    setState(() {
      _showCreateWheel = !_showCreateWheel;
      _sideRailExpanded = false;
    });
  }

  void _closeCreateWheel() {
    if (!mounted) return;
    setState(() => _showCreateWheel = false);
  }

  void _openObjectLibrary() {
    if (!mounted) return;

    setState(() {
      _showCreateWheel = false;
      _selectedObject = null;
      _flow = _ARCameraFlow.objectLibrary;
    });
  }

  void _openObjectPreview(ARLibraryObject object) {
    if (!mounted) return;

    setState(() {
      _selectedObject = object;
      _flow = _ARCameraFlow.objectPreview;
    });
  }

  void _openObjectPlacement() {
    if (!mounted || _selectedObject == null) return;

    setState(() => _flow = _ARCameraFlow.objectPlacement);
  }

  void _returnToObjectLibrary() {
    if (!mounted) return;

    setState(() => _flow = _ARCameraFlow.objectLibrary);
  }

  void _returnToObjectPreview() {
    if (!mounted || _selectedObject == null) return;

    setState(() => _flow = _ARCameraFlow.objectPreview);
  }

  void _handlePlacementConfirmed() {
    if (!mounted || _selectedObject == null) return;

    // UNITY INTEGRATION POINT:
    // This callback should only be invoked by the placement widget after
    // Unity confirms successful instantiation. The current placement widget
    // exposes the action through onPlace; no Flutter-side AR object is faked.
    setState(() => _flow = _ARCameraFlow.selectedEditor);
  }

  void _returnToObjectPlacement() {
    if (!mounted || _selectedObject == null) return;

    setState(() => _flow = _ARCameraFlow.objectPlacement);
  }

  // ========================================================================
  // SELECTED OBJECT / SAVE
  // ========================================================================

  void _openSavePublish() {
    if (!mounted || _selectedObject == null) return;

    setState(() => _flow = _ARCameraFlow.savePublish);
  }

  void _returnToSelectedEditor() {
    if (!mounted || _selectedObject == null) return;

    setState(() => _flow = _ARCameraFlow.selectedEditor);
  }

  void _deleteSelectedObject() {
    if (!mounted) return;

    // UNITY INTEGRATION POINT:
    // Delete the actual Unity scene object here.
    setState(() {
      _selectedObject = null;
      _flow = _ARCameraFlow.camera;
    });
  }

  void _duplicateSelectedObject() {
    final object = _selectedObject;
    if (!mounted || object == null) return;

    // Flutter-side draft duplication. Backend/Unity persistence is still an
    // integration responsibility and must use the duplicated object's ID.
    setState(() {
      _selectedObject = ARLibraryObject(
        id: '${object.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
        name: '${object.name} Copy',
        category: object.category,
        icon: object.icon,
        description: object.description,
        featured: false,
      );
    });

    _showTemporaryMessage('Duplicated', 'A new object draft is selected.');
  }

  void _saveDraft(ObjectSaveData data) {
    // BACKEND INTEGRATION POINT:
    // Persist the draft using the complete ObjectSaveData payload.
    _showTemporaryMessage('Draft', 'Object draft is ready to persist.');
  }

  void _publishObject(ObjectSaveData data) {
    // BACKEND + UNITY INTEGRATION POINT:
    // Persist publication, register the AR object, and associate it with
    // the active Zone/anchor in the real implementation.
    _showTemporaryMessage('Publish', 'Object is ready for backend publish.');
  }

  // ========================================================================
  // UNITY SURFACE SCAN
  // ========================================================================

  void _requestUnitySurfaceScan() {
    // UNITY INTEGRATION POINT:
    // Send a surface-scan command through the native bridge. Unity should
    // later rebuild the surface state and rebuild this widget with the real
    // `surfaceDetected` value.
    _showTemporaryMessage(
      'Surface Scan',
      'Waiting for Unity surface detection.',
    );
  }

  // ========================================================================
  // CAMERA CONTROLS
  // ========================================================================

  void _handleBack() {
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  void _returnToCamera() {
    if (!mounted) return;

    setState(() {
      _selectedObject = null;
      _showCreateWheel = false;
      _flow = _ARCameraFlow.camera;
    });
  }

  void _handleCompass() {
    if (!mounted) return;
    setState(() => _compassActive = !_compassActive);
  }

  void _toggleSideRail() {
    if (!mounted) return;
    setState(() => _sideRailExpanded = !_sideRailExpanded);
  }

  void _handleCapture() {
    if (!mounted) return;
    setState(() => _captureActive = !_captureActive);
  }

  void _handleScan() {
    if (!mounted) return;

    setState(() {
      _scanActive = !_scanActive;
      _reticleState = _scanActive
          ? ARReticleState.processing
          : ARReticleState.searching;
    });
  }

  void _handleLayers() {
    if (!mounted) return;
    setState(() => _layersActive = !_layersActive);
  }

  void _handleExplore() {
    _showTemporaryMessage('Explore', 'Discovery will open here.');
  }

  void _handleProfile() {
    _showTemporaryMessage('Profile', 'Profile navigation will open here.');
  }

  void _showComingSoon(String feature) {
    _closeCreateWheel();
    _showTemporaryMessage(feature, 'This creation flow is next.');
  }

  void _showTemporaryMessage(String title, String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title — $message'),
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 110),
        ),
      );
  }
}
