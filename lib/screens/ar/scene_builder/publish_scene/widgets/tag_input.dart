// File: tag_input.dart
// MetaZone — Scene Builder: Tag Input (Ultra PRO 2025)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class TagInput extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  const TagInput({
    super.key,
    required this.tags,
    required this.onChanged,
  });

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final TextEditingController _tagCtrl = TextEditingController();

  void _addTag() {
    final text = _tagCtrl.text.trim();

    if (text.isEmpty) return;
    if (widget.tags.contains(text)) return;

    setState(() {
      widget.tags.add(text);
      _tagCtrl.clear();
    });

    widget.onChanged(widget.tags);
  }

  void _removeTag(String tag) {
    setState(() {
      widget.tags.remove(tag);
    });
    widget.onChanged(widget.tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...widget.tags.map((t) => _tagChip(t)).toList(),
            _inputChip(),
          ],
        ),
      ],
    );
  }

  // =============================================================
  // TAG CHIP
  // =============================================================
  Widget _tagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: AppTextStyles.caption()),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeTag(text),
            child: const Icon(Icons.close, size: 14, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // ADD NEW TAG INPUT
  // =============================================================
  Widget _inputChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      constraints: const BoxConstraints(minWidth: 110),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              controller: _tagCtrl,
              style: AppTextStyles.caption(),
              decoration: InputDecoration(
                hintText: "Add tag...",
                hintStyle: AppTextStyles.caption(size: 12)
                    .copyWith(color: AppColors.textSoft),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _addTag(),
            ),
          ),
          GestureDetector(
            onTap: _addTag,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
