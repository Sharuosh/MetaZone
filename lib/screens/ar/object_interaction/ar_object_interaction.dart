import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../services/chat_service.dart';
import '../../home/chat/chat_screen.dart';

/// ==========================================================
///         META ZONE — AR OBJECT INTERACTION OVERLAY
/// ==========================================================
///  - يظهر عند الضغط على Object داخل AR World
///  - يدعم: Move, Scale, Rotate, Duplicate, Pin, Save, Delete
///  - تصميم مستقبلي متوافق مع Meta Glasses OS
/// ==========================================================

class ARObjectInteraction extends StatefulWidget {
  final String objectId;
  final String objectName;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onSave;
  final VoidCallback? onPinLocation;

  const ARObjectInteraction({
    super.key,
    required this.objectId,
    required this.objectName,
    this.onDelete,
    this.onDuplicate,
    this.onSave,
    this.onPinLocation,
  });

  @override
  State<ARObjectInteraction> createState() => _ARObjectInteractionState();
}

class _ARObjectInteractionState extends State<ARObjectInteraction> {
  double scale = 1.0;
  double rotation = 0.0;
  Future<void> _openChat() async {
    final ctxId = await ChatService().ensureARObjectContext(
      objectId: widget.objectId,
      title: widget.objectName,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          contextType: 'AR_OBJECT',
          contextId: ctxId,
          contextName: widget.objectName,
        ),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 25,
      left: 0,
      right: 0,
      child: Center(
        child: _panel(),
      ),
    );
  }

  Widget _panel() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 330,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(AppColors.glassOpacity),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _title(),
          const SizedBox(height: 14),
          _transformControls(),
          const SizedBox(height: 16),
          _actionBar(),
        ],
      ),
    );
  }

  Widget _title() {
    return Text(
      widget.objectName,
      style: AppTextStyles.heading(size: 18),
    );
  }

  /// MOVE / ROTATE / SCALE
  Widget _transformControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _circleButton(Icons.open_with, "Move", () {}),
        _circleButton(Icons.rotate_right, "Rotate", () {
          setState(() => rotation += 15);
        }),
        _circleButton(Icons.zoom_in, "Scale +", () {
          setState(() => scale += 0.1);
        }),
        _circleButton(Icons.zoom_out, "Scale -", () {
          if (scale > 0.3) setState(() => scale -= 0.1);
        }),
      ],
    );
  }

  Widget _actionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _squareAction(Icons.chat_bubble_outline, "Chat", _openChat),
        _squareAction(Icons.push_pin, "Pin", widget.onPinLocation),
        _squareAction(Icons.copy, "Duplicate", widget.onDuplicate),
        _squareAction(Icons.save, "Save", widget.onSave),
        _squareAction(Icons.delete_forever, "Delete", widget.onDelete, danger: true),
      ],
    );

  }

  Widget _circleButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.surface,
            child: Icon(icon, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: AppTextStyles.caption()),
      ],
    );
  }

  Widget _squareAction(
      IconData icon, String label, VoidCallback? onTap,
      {bool danger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: danger ? AppColors.danger.withOpacity(.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: danger ? AppColors.danger : AppColors.primarySoft,
            width: 1.3,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: danger ? AppColors.danger : AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.caption()
                    .copyWith(color: danger ? AppColors.danger : null)),
          ],
        ),
      ),
    );
  }
}
