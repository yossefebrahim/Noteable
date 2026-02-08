import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../providers/audio_recorder_provider.dart';

class AudioRecorderWidget extends StatelessWidget {
  const AudioRecorderWidget({
    super.key,
    required this.provider,
  });

  final AudioRecorderProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRecording = provider.isRecording;
    final duration = provider.duration;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Duration display
          Text(
            _formatDuration(duration),
            style: AppTextStyles.h3.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          // Recording status
          if (isRecording)
            Text(
              'Recording...',
              style: AppTextStyles.caption.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          if (isRecording) const SizedBox(height: 16),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isRecording) ...[
                // Record button
                _RecordButton(
                  onPressed: provider.startRecording,
                ),
              ] else ...[
                // Stop button
                _StopButton(
                  onPressed: provider.stopRecording,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      opacity: 1.0,
      child: SizedBox(
        width: 64,
        height: 64,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: const Icon(Icons.mic, size: 32),
        ),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      opacity: 1.0,
      child: SizedBox(
        width: 64,
        height: 64,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: const Icon(Icons.stop, size: 32),
        ),
      ),
    );
  }
}
