import 'package:flutter/material.dart';

import '../theme/ar_camera_theme.dart';
import 'ar_glass.dart';
import 'object_library.dart';

/// MetaZone Object Save / Publish.
///
/// Flutter owns the complete presentation and local interaction state:
/// - Object identity
/// - Name / description editing
/// - Visibility
/// - Interaction permissions
/// - Advanced metadata presentation
/// - Validation
/// - Draft state
/// - Publish confirmation
/// - Publish success state
/// - Loading / disabled states
/// - Unsaved-changes protection
///
/// Unity / Backend responsibilities are intentionally kept outside this
/// widget. The parent receives [ObjectSaveData] through callbacks and can
/// connect it to persistence, Unity registration, uploads, analytics, etc.
class ObjectSavePublish extends StatefulWidget {
  const ObjectSavePublish({
    super.key,
    required this.object,
    required this.onBack,
    required this.onSaveDraft,
    required this.onPublish,
  });

  final ARLibraryObject object;

  final VoidCallback onBack;
  final ValueChanged<ObjectSaveData> onSaveDraft;
  final ValueChanged<ObjectSaveData> onPublish;

  @override
  State<ObjectSavePublish> createState() => _ObjectSavePublishState();
}

class _ObjectSavePublishState extends State<ObjectSavePublish> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  ObjectVisibility _visibility = ObjectVisibility.public;

  bool _allowInteraction = true;
  bool _showAdvanced = false;
  bool _saving = false;
  bool _published = false;
  bool _draftSaved = false;
  bool _hasEdited = false;

  String? _nameError;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.object.name);
    _descriptionController =
        TextEditingController(text: widget.object.description);

    _nameController.addListener(_markEdited);
    _descriptionController.addListener(_markEdited);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_markEdited)
      ..dispose();
    _descriptionController
      ..removeListener(_markEdited)
      ..dispose();
    super.dispose();
  }

  void _markEdited() {
    if (!_hasEdited && mounted) {
      setState(() => _hasEdited = true);
    }
  }

  ObjectSaveData _buildData() {
    return ObjectSaveData(
      object: widget.object,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      visibility: _visibility,
      allowInteraction: _allowInteraction,
    );
  }

  bool _validate() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = 'Object name is required.');
      return false;
    }

    if (name.length < 2) {
      setState(
            () => _nameError = 'Object name must contain at least 2 characters.',
      );
      return false;
    }

    setState(() => _nameError = null);
    return true;
  }

  Future<void> _saveDraft() async {
    if (_saving || !_validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _saving = true);

    try {
      widget.onSaveDraft(_buildData());

      if (!mounted) return;

      setState(() {
        _saving = false;
        _draftSaved = true;
        _hasEdited = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _saving = false);

      _showError(
        'The draft could not be saved. Please try again.',
      );
    }
  }

  Future<void> _publish() async {
    if (_saving || !_validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final confirmed = await _showPublishConfirmation();
    if (!confirmed || !mounted) return;

    setState(() => _saving = true);

    try {
      widget.onPublish(_buildData());

      if (!mounted) return;

      setState(() {
        _saving = false;
        _published = true;
        _hasEdited = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _saving = false);

      _showError(
        'The object could not be published. Please try again.',
      );
    }
  }

  Future<bool> _showPublishConfirmation() async {
    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _PublishConfirmationSheet(
          object: widget.object,
          name: _nameController.text.trim(),
          visibility: _visibility,
          allowInteraction: _allowInteraction,
        );
      },
    ) ??
        false;
  }

  Future<void> _handleBack() async {
    if (_saving) return;

    if (!_hasEdited) {
      widget.onBack();
      return;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (context) {
        return const _DiscardChangesDialog();
      },
    );

    if (shouldLeave == true && mounted) {
      widget.onBack();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 9),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _setVisibility(ObjectVisibility value) {
    if (_saving || _visibility == value) return;

    setState(() {
      _visibility = value;
      _hasEdited = true;
    });
  }

  void _setInteraction(bool value) {
    if (_saving || _allowInteraction == value) return;

    setState(() {
      _allowInteraction = value;
      _hasEdited = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_published) {
      return Positioned.fill(
        child: SafeArea(
          child: _PublishSuccess(
            object: widget.object,
            name: _nameController.text.trim(),
            visibility: _visibility,
            onDone: widget.onBack,
          ),
        ),
      );
    }

    if (_draftSaved) {
      return Positioned.fill(
        child: SafeArea(
          child: _DraftSavedState(
            object: widget.object,
            onContinue: () {
              setState(() => _draftSaved = false);
            },
            onDone: widget.onBack,
          ),
        ),
      );
    }

    return Positioned.fill(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 68, 12, 128),
                child: Column(
                  children: [
                    _ObjectIdentityCard(object: widget.object),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Object Details',
                      icon: Icons.edit_note_rounded,
                      child: Column(
                        children: [
                          _InputField(
                            controller: _nameController,
                            label: 'Name',
                            hint: 'Give your object a name',
                            icon: Icons.title_rounded,
                            enabled: !_saving,
                            errorText: _nameError,
                            maxLength: 40,
                          ),
                          const SizedBox(height: 12),
                          _InputField(
                            controller: _descriptionController,
                            label: 'Description',
                            hint: 'Tell people what this object is',
                            icon: Icons.notes_rounded,
                            enabled: !_saving,
                            maxLines: 4,
                            maxLength: 160,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Visibility',
                      icon: Icons.visibility_rounded,
                      child: Column(
                        children: [
                          _VisibilityOption(
                            icon: Icons.public_rounded,
                            title: 'Public',
                            subtitle: 'Anyone can discover this object.',
                            value: ObjectVisibility.public,
                            groupValue: _visibility,
                            enabled: !_saving,
                            onChanged: _setVisibility,
                          ),
                          const SizedBox(height: 8),
                          _VisibilityOption(
                            icon: Icons.people_alt_rounded,
                            title: 'Friends',
                            subtitle: 'Only your friends can discover it.',
                            value: ObjectVisibility.friends,
                            groupValue: _visibility,
                            enabled: !_saving,
                            onChanged: _setVisibility,
                          ),
                          const SizedBox(height: 8),
                          _VisibilityOption(
                            icon: Icons.lock_rounded,
                            title: 'Private',
                            subtitle: 'Only you can access this object.',
                            value: ObjectVisibility.private,
                            groupValue: _visibility,
                            enabled: !_saving,
                            onChanged: _setVisibility,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Interaction',
                      icon: Icons.touch_app_rounded,
                      child: _SwitchRow(
                        icon: Icons.touch_app_rounded,
                        title: 'Allow interaction',
                        subtitle:
                        'Let people interact with this object in AR.',
                        value: _allowInteraction,
                        enabled: !_saving,
                        onChanged: _setInteraction,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Advanced',
                      icon: Icons.tune_rounded,
                      child: Column(
                        children: [
                          _AdvancedHeader(
                            expanded: _showAdvanced,
                            onTap: _saving
                                ? null
                                : () {
                              setState(
                                    () => _showAdvanced = !_showAdvanced,
                              );
                            },
                          ),
                          AnimatedCrossFade(
                            duration: ARCameraTheme.motionNormal,
                            crossFadeState: _showAdvanced
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                children: [
                                  _AdvancedInfo(
                                    icon: Icons.view_in_ar_rounded,
                                    title: 'AR placement',
                                    value: 'World anchored',
                                  ),
                                  _AdvancedInfo(
                                    icon: Icons.category_rounded,
                                    title: 'Category',
                                    value: widget.object.category,
                                  ),
                                  _AdvancedInfo(
                                    icon: Icons.sensors_rounded,
                                    title: 'Tracking',
                                    value: 'AR tracking',
                                  ),
                                  _AdvancedInfo(
                                    icon: Icons.lock_outline_rounded,
                                    title: 'Edit state',
                                    value: _saving ? 'Locked' : 'Editable',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ActionArea(
                      saving: _saving,
                      onSaveDraft: _saveDraft,
                      onPublish: _publish,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _GlassButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: _saving ? null : _handleBack,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(child: _HeaderTitle()),
                  if (_hasEdited && !_saving)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _UnsavedBadge(),
                    ),
                ],
              ),
            ),
            if (_saving)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _SavingIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DATA
// ============================================================================

enum ObjectVisibility {
  public,
  friends,
  private,
}

class ObjectSaveData {
  const ObjectSaveData({
    required this.object,
    required this.name,
    required this.description,
    required this.visibility,
    required this.allowInteraction,
  });

  final ARLibraryObject object;
  final String name;
  final String description;
  final ObjectVisibility visibility;
  final bool allowInteraction;
}

// ============================================================================
// HEADER
// ============================================================================

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return ARGlass(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      blur: ARCameraTheme.glassBlur,
      opacity: ARCameraTheme.glassStrongOpacity,
      child: const Row(
        children: [
          Icon(
            Icons.publish_rounded,
            size: 17,
            color: ARCameraTheme.primaryBright,
          ),
          SizedBox(width: 8),
          Text(
            'Save Object',
            style: TextStyle(
              color: ARCameraTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnsavedBadge extends StatelessWidget {
  const _UnsavedBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Unsaved changes',
      child: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ARCameraTheme.warning,
          boxShadow: [
            BoxShadow(
              color: ARCameraTheme.warning.withValues(alpha: 0.45),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingIndicator extends StatelessWidget {
  const _SavingIndicator();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LinearProgressIndicator(
        minHeight: 2,
        backgroundColor: Colors.transparent,
        valueColor: const AlwaysStoppedAnimation<Color>(
          ARCameraTheme.primaryBright,
        ),
      ),
    );
  }
}

// ============================================================================
// OBJECT IDENTITY
// ============================================================================

class _ObjectIdentityCard extends StatelessWidget {
  const _ObjectIdentityCard({required this.object});

  final ARLibraryObject object;

  @override
  Widget build(BuildContext context) {
    return ARGlass(
      padding: const EdgeInsets.all(11),
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      blur: ARCameraTheme.glassBlurStrong,
      opacity: ARCameraTheme.glassStrongOpacity,
      child: Row(
        children: [
          Hero(
            tag: 'object-save-${object.name}',
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: ARCameraTheme.primarySoft,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: ARCameraTheme.borderActive),
              ),
              child: Icon(
                object.icon,
                size: 29,
                color: ARCameraTheme.primaryBright,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  object.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ARCameraTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  object.category,
                  style: const TextStyle(
                    color: ARCameraTheme.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 7),
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 12,
                      color: ARCameraTheme.success,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Ready to save',
                      style: TextStyle(
                        color: ARCameraTheme.success,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Object type',
            child: Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: ARCameraTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION
// ============================================================================

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ARGlass(
      padding: const EdgeInsets.all(11),
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      blur: ARCameraTheme.glassBlur,
      opacity: ARCameraTheme.glassOpacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 15,
                color: ARCameraTheme.primaryBright,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  color: ARCameraTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ============================================================================
// INPUT
// ============================================================================

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.errorText,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool enabled;
  final String? errorText;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ARCameraTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          textCapitalization: TextCapitalization.sentences,
          textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
          style: const TextStyle(
            color: ARCameraTheme.textPrimary,
            fontSize: 11,
          ),
          cursorColor: ARCameraTheme.primaryBright,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: ARCameraTheme.textMuted,
              fontSize: 10,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                left: 11,
                right: maxLines == 1 ? 0 : 5,
                top: maxLines == 1 ? 0 : 12,
              ),
              child: Icon(
                icon,
                size: 16,
                color: ARCameraTheme.textSecondary,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 35),
            filled: true,
            fillColor: ARCameraTheme.glassSoftColor,
            errorText: errorText,
            errorStyle: const TextStyle(fontSize: 8),
            counterStyle: const TextStyle(
              color: ARCameraTheme.textMuted,
              fontSize: 8,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: ARCameraTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: ARCameraTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: ARCameraTheme.borderActive,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: ARCameraTheme.border),
            ),
          ),
          onChanged: (_) {
            if (errorText != null && controller.text.trim().length >= 2) {
              // Validation state is cleared by the parent on publish/save.
            }
          },
        ),
      ],
    );
  }
}

// ============================================================================
// VISIBILITY
// ============================================================================

class _VisibilityOption extends StatelessWidget {
  const _VisibilityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ObjectVisibility value;
  final ObjectVisibility groupValue;
  final bool enabled;
  final ValueChanged<ObjectVisibility> onChanged;

  @override
  Widget build(BuildContext context) {
    final active = value == groupValue;

    return Semantics(
      button: true,
      selected: active,
      label: '$title visibility',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? () => onChanged(value) : null,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: ARCameraTheme.motionFast,
            curve: ARCameraTheme.motionCurve,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: active
                  ? ARCameraTheme.primarySoft
                  : ARCameraTheme.glassSoftColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active
                    ? ARCameraTheme.borderActive
                    : ARCameraTheme.border,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: ARCameraTheme.motionFast,
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: active
                        ? ARCameraTheme.primarySoft
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 17,
                    color: active
                        ? ARCameraTheme.primaryBright
                        : ARCameraTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: ARCameraTheme.textPrimary,
                          fontSize: 10,
                          fontWeight:
                          active ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ARCameraTheme.textMuted,
                          fontSize: 8,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: ARCameraTheme.motionFast,
                  width: 19,
                  height: 19,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active
                          ? ARCameraTheme.primaryBright
                          : ARCameraTheme.border,
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: AnimatedContainer(
                    duration: ARCameraTheme.motionFast,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? ARCameraTheme.primaryBright
                          : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SWITCH
// ============================================================================

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: ARCameraTheme.motionFast,
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: value
                ? ARCameraTheme.primarySoft
                : ARCameraTheme.glassSoftColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 17,
            color: value
                ? ARCameraTheme.primaryBright
                : ARCameraTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ARCameraTheme.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ARCameraTheme.textMuted,
                  fontSize: 8,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeThumbColor: ARCameraTheme.primaryBright,
          activeTrackColor: ARCameraTheme.primarySoft,
        ),
      ],
    );
  }
}

// ============================================================================
// ADVANCED
// ============================================================================

class _AdvancedHeader extends StatelessWidget {
  const _AdvancedHeader({
    required this.expanded,
    required this.onTap,
  });

  final bool expanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      expanded: expanded,
      label: 'Advanced settings',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Advanced settings',
                    style: TextStyle(
                      color: ARCameraTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: ARCameraTheme.motionFast,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: ARCameraTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdvancedInfo extends StatelessWidget {
  const _AdvancedInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: ARCameraTheme.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: ARCameraTheme.textSecondary,
                fontSize: 9,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ARCameraTheme.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ACTION AREA
// ============================================================================

class _ActionArea extends StatelessWidget {
  const _ActionArea({
    required this.saving,
    required this.onSaveDraft,
    required this.onPublish,
  });

  final bool saving;
  final VoidCallback onSaveDraft;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: saving ? null : onPublish,
            style: ElevatedButton.styleFrom(
              backgroundColor: ARCameraTheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: ARCameraTheme.glassSoftColor,
              disabledForegroundColor: ARCameraTheme.textMuted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: saving
                ? const _ButtonLoading()
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.publish_rounded, size: 17),
                SizedBox(width: 7),
                Text(
                  'Publish Object',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 7),
        SizedBox(
          width: double.infinity,
          height: 38,
          child: TextButton.icon(
            onPressed: saving ? null : onSaveDraft,
            icon: const Icon(Icons.bookmark_border_rounded, size: 15),
            label: const Text(
              'Save as Draft',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: ARCameraTheme.textSecondary,
              disabledForegroundColor: ARCameraTheme.textMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'You can change these settings later.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ARCameraTheme.textMuted,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}

class _ButtonLoading extends StatelessWidget {
  const _ButtonLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 17,
      height: 17,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.white,
      ),
    );
  }
}

// ============================================================================
// PUBLISH CONFIRMATION
// ============================================================================

class _PublishConfirmationSheet extends StatelessWidget {
  const _PublishConfirmationSheet({
    required this.object,
    required this.name,
    required this.visibility,
    required this.allowInteraction,
  });

  final ARLibraryObject object;
  final String name;
  final ObjectVisibility visibility;
  final bool allowInteraction;

  String get visibilityLabel {
    switch (visibility) {
      case ObjectVisibility.public:
        return 'Public';
      case ObjectVisibility.friends:
        return 'Friends';
      case ObjectVisibility.private:
        return 'Private';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: ARGlass(
        padding: const EdgeInsets.all(14),
        borderRadius: const BorderRadius.all(Radius.circular(22)),
        blur: ARCameraTheme.glassBlurStrong,
        opacity: ARCameraTheme.glassStrongOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 3,
              decoration: BoxDecoration(
                color: ARCameraTheme.textMuted,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ARCameraTheme.primarySoft,
                border: Border.all(color: ARCameraTheme.borderActive),
              ),
              child: Icon(
                object.icon,
                size: 27,
                color: ARCameraTheme.primaryBright,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ready to publish?',
              style: TextStyle(
                color: ARCameraTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              name.isEmpty ? object.name : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ARCameraTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                _SummaryChip(
                  icon: _visibilityIcon(visibility),
                  label: visibilityLabel,
                ),
                _SummaryChip(
                  icon: allowInteraction
                      ? Icons.touch_app_rounded
                      : Icons.touch_app_outlined,
                  label: allowInteraction ? 'Interactive' : 'View only',
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'This object will become part of your AR experience.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ARCameraTheme.textMuted,
                fontSize: 9,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ARCameraTheme.textSecondary,
                      side: const BorderSide(color: ARCameraTheme.border),
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Review',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ARCameraTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Publish',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Not now',
                style: TextStyle(
                  color: ARCameraTheme.textMuted,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _visibilityIcon(ObjectVisibility value) {
    switch (value) {
      case ObjectVisibility.public:
        return Icons.public_rounded;
      case ObjectVisibility.friends:
        return Icons.people_alt_rounded;
      case ObjectVisibility.private:
        return Icons.lock_rounded;
    }
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: ARCameraTheme.glassSoftColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ARCameraTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: ARCameraTheme.primaryBright,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: ARCameraTheme.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DISCARD DIALOG
// ============================================================================

class _DiscardChangesDialog extends StatelessWidget {
  const _DiscardChangesDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ARCameraTheme.glassStrongColor,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Discard changes?',
        style: TextStyle(
          color: ARCameraTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: const Text(
        'Your unsaved changes will be lost.',
        style: TextStyle(
          color: ARCameraTheme.textSecondary,
          fontSize: 11,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Keep editing',
            style: TextStyle(
              color: ARCameraTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'Discard',
            style: TextStyle(
              color: ARCameraTheme.error,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// DRAFT SUCCESS
// ============================================================================

class _DraftSavedState extends StatelessWidget {
  const _DraftSavedState({
    required this.object,
    required this.onContinue,
    required this.onDone,
  });

  final ARLibraryObject object;
  final VoidCallback onContinue;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ARGlass(
          padding: const EdgeInsets.all(20),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          blur: ARCameraTheme.glassBlurStrong,
          opacity: ARCameraTheme.glassStrongOpacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusIcon(
                icon: Icons.bookmark_added_rounded,
                color: ARCameraTheme.primaryBright,
              ),
              const SizedBox(height: 14),
              const Text(
                'Draft saved',
                style: TextStyle(
                  color: ARCameraTheme.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${object.name} is safely stored as a draft.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ARCameraTheme.textSecondary,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ARCameraTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue Editing',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: onDone,
                child: const Text(
                  'Back to AR Camera',
                  style: TextStyle(
                    color: ARCameraTheme.textMuted,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PUBLISH SUCCESS
// ============================================================================

class _PublishSuccess extends StatelessWidget {
  const _PublishSuccess({
    required this.object,
    required this.name,
    required this.visibility,
    required this.onDone,
  });

  final ARLibraryObject object;
  final String name;
  final ObjectVisibility visibility;
  final VoidCallback onDone;

  String get visibilityLabel {
    switch (visibility) {
      case ObjectVisibility.public:
        return 'Public';
      case ObjectVisibility.friends:
        return 'Friends';
      case ObjectVisibility.private:
        return 'Private';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ARGlass(
          padding: const EdgeInsets.all(20),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          blur: ARCameraTheme.glassBlurStrong,
          opacity: ARCameraTheme.glassStrongOpacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusIcon(
                icon: Icons.check_rounded,
                color: ARCameraTheme.success,
              ),
              const SizedBox(height: 14),
              const Text(
                'Published',
                style: TextStyle(
                  color: ARCameraTheme.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${name.isEmpty ? object.name : name} is now part of your AR world.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ARCameraTheme.textSecondary,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              _SummaryChip(
                icon: visibility == ObjectVisibility.public
                    ? Icons.public_rounded
                    : visibility == ObjectVisibility.friends
                    ? Icons.people_alt_rounded
                    : Icons.lock_rounded,
                label: visibilityLabel,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ARCameraTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back to AR Camera',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.72, end: 1),
      duration: ARCameraTheme.motionSmooth,
      curve: ARCameraTheme.motionCurve,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 24,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 36,
          color: color,
        ),
      ),
    );
  }
}

// ============================================================================
// GLASS BUTTON
// ============================================================================

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: AnimatedOpacity(
            duration: ARCameraTheme.motionFast,
            opacity: onTap == null ? 0.45 : 1,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ARCameraTheme.glassStrongColor,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: ARCameraTheme.border),
              ),
              child: Icon(
                icon,
                size: 17,
                color: ARCameraTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
