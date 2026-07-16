// lib/screens/home/chat/widgets/voice_message_bubble.dart
// MetaZone — Voice Message Bubble (Safe • Animated • AR Neon)

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class VoiceMessageBubble extends StatefulWidget {
  final bool fromMe;
  final Duration duration;

  const VoiceMessageBubble({
    super.key,
    required this.fromMe,
    required this.duration,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  bool _playing = false;
  double _progress = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    // إذا المدة صفر — نخرج مباشرة
    if (widget.duration.inMilliseconds <= 0) return;

    if (_playing) {
      _timer?.cancel();
      setState(() => _playing = false);
      return;
    }

    setState(() {
      _playing = true;
      _progress = 0;
    });

    final totalMs = widget.duration.inMilliseconds;

    _timer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      setState(() {
        _progress += 80 / totalMs;

        if (_progress >= 1) {
          _progress = 1;
          _playing = false;
          t.cancel();
        }
      });
    });
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, "0");
    final s = d.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = widget.fromMe
        ? AppColors.primary.withOpacity(.20)
        : AppColors.card.withOpacity(.65);

    final borderColor =
    widget.fromMe ? AppColors.primary : AppColors.border.withOpacity(.7);

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // play / pause
          GestureDetector(
            onTap: _togglePlay,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(.15),
              child: Icon(
                _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // waveform + progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // fake waveform bars
                SizedBox(
                  height: 18,
                  child: Row(
                    children: List.generate(14, (i) {
                      final active = _progress * 14 >= i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 3,
                        height: active ? 8 + (i % 5) * 3 : 6,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.textSoft.withOpacity(.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 6),

                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppColors.cardSoft,
                  color: AppColors.primary,
                  minHeight: 4,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // time
          Text(
            _format(widget.duration),
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
