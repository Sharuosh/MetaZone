import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class ARObjectInteractionPanel extends StatefulWidget {
  final String objectName;
  final String owner;
  final bool isPinned;
  final Function()? onDelete;
  final Function()? onDuplicate;
  final Function(double)? onScale;
  final Function(double)? onRotate;
  final Function()? onPinToggle;
  final Function()? onSaveToProfile;
  final Function()? onShare;

  const ARObjectInteractionPanel({
    super.key,
    required this.objectName,
    required this.owner,
    this.isPinned = false,
    this.onDelete,
    this.onDuplicate,
    this.onScale,
    this.onRotate,
    this.onPinToggle,
    this.onSaveToProfile,
    this.onShare,
  });

  @override
  State<ARObjectInteractionPanel> createState() =>
      _ARObjectInteractionPanelState();
}

class _ARObjectInteractionPanelState extends State<ARObjectInteractionPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _panelCtrl;
  late Animation<double> _slideAnim;
  double _scaleValue = 1.0;
  double _rotationValue = 0.0;

  @override
  void initState() {
    super.initState();

    _panelCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _slideAnim = CurvedAnimation(
      parent: _panelCtrl,
      curve: Curves.easeOutBack,
    );

    _panelCtrl.forward();
  }

  @override
  void dispose() {
    _panelCtrl.dispose();
    super.dispose();
  }

  Widget _mainInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.card,
            child: Text(widget.objectName[0].toUpperCase(),
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.objectName, style: AppTextStyles.title(size: 16)),
              Text("By ${widget.owner}", style: AppTextStyles.caption()),
            ]),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.textSoft),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, String label, VoidCallback? onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.card,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.caption(size: 11)),
      ],
    );
  }

  Widget _quickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _iconBtn(Icons.delete_outline, "Delete", widget.onDelete),
        _iconBtn(Icons.copy, "Duplicate", widget.onDuplicate),
        _iconBtn(widget.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            widget.isPinned ? "Unpin" : "Pin", widget.onPinToggle),
        _iconBtn(Icons.share_outlined, "Share", widget.onShare),
        _iconBtn(Icons.person_add_alt_1, "Save", widget.onSaveToProfile),
      ]),
    );
  }

  Widget _sliders() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Transform Controls", style: AppTextStyles.title(size: 14)),
          const SizedBox(height: 12),

          // SCALE
          Text("Scale", style: AppTextStyles.caption()),
          Slider(
            value: _scaleValue,
            min: 0.4,
            max: 2.5,
            onChanged: (v) {
              setState(() => _scaleValue = v);
              widget.onScale?.call(v);
            },
          ),

          const SizedBox(height: 12),

          // ROTATION
          Text("Rotation", style: AppTextStyles.caption()),
          Slider(
            value: _rotationValue,
            min: 0.0,
            max: 2 * pi,
            onChanged: (v) {
              setState(() => _rotationValue = v);
              widget.onRotate?.call(v);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _panelCtrl,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnim.value) * 260),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              border: Border.all(color: AppColors.border.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _mainInfo(),
                const SizedBox(height: 12),
                _quickActions(),
                const SizedBox(height: 12),
                _sliders(),
                const SizedBox(height: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}
