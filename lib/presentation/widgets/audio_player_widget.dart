import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../providers/audio_player_provider.dart';
import 'waveform_visualization.dart';

/// Widget for audio playback with waveform visualization and controls.
///
/// Provides play/pause, seek functionality, and displays audio waveform
/// with current position and duration.
class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({
    super.key,
    required this.provider,
    this.waveformAmplitudes,
    this.onDelete,
  });

  /// Provider that manages audio playback state
  final AudioPlayerProvider provider;

  /// Optional waveform amplitude data (0.0 to 1.0 values)
  /// If not provided, shows a simple progress bar instead
  final List<double>? waveformAmplitudes;

  /// Optional callback for deleting the audio
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasWaveform = waveformAmplitudes != null && waveformAmplitudes!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Duration display and delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DurationDisplay(position: provider.position, duration: provider.duration),
              if (onDelete != null) _DeleteButton(onPressed: onDelete!),
            ],
          ),
          const SizedBox(height: 16),
          // Waveform or progress bar
          if (hasWaveform)
            _WaveformSlider(
              amplitudes: waveformAmplitudes!,
              position: provider.position.inSeconds.toDouble(),
              duration: provider.duration?.inSeconds.toDouble() ?? 1.0,
              isActive: provider.isPlaying,
              onSeek: (position) {
                final seekPosition = Duration(seconds: position.toInt());
                provider.seek(seekPosition);
              },
            )
          else
            _ProgressBar(
              position: provider.position,
              duration: provider.duration,
              onSeek: (percent) {
                provider.seekByPercent(percent);
              },
            ),
          const SizedBox(height: 16),
          // Playback controls
          _PlaybackControls(
            isPlaying: provider.isPlaying,
            hasAudio: provider.hasAudio,
            onPlayPressed: provider.play,
            onPausePressed: provider.pause,
            onStopPressed: provider.stop,
          ),
        ],
      ),
    );
  }
}

/// Displays current position and total duration
class _DurationDisplay extends StatelessWidget {
  const _DurationDisplay({required this.position, required this.duration});

  final Duration position;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positionText = _formatDuration(position);
    final durationText = duration != null ? _formatDuration(duration!) : '--:--';

    return Text(
      '$positionText / $durationText',
      style: AppTextStyles.caption.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Delete button for removing audio attachment
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      opacity: 1.0,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
        tooltip: 'Delete audio',
        style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      ),
    );
  }
}

/// Waveform visualization with seek capability
class _WaveformSlider extends StatelessWidget {
  const _WaveformSlider({
    required this.amplitudes,
    required this.position,
    required this.duration,
    required this.isActive,
    required this.onSeek,
  });

  final List<double> amplitudes;
  final double position;
  final double duration;
  final bool isActive;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPosition = box.localToGlobal(details.localPosition);
        final tapPosition = localPosition.dx;
        final percent = (tapPosition / box.size.width).clamp(0.0, 1.0);
        onSeek(percent * duration);
      },
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final tapPosition = details.localPosition.dx;
        final percent = (tapPosition / box.size.width).clamp(0.0, 1.0);
        onSeek(percent * duration);
      },
      child: WaveformVisualization(
        amplitudes: amplitudes,
        position: position,
        duration: duration,
        isActive: isActive,
      ),
    );
  }
}

/// Simple progress bar for when waveform is not available
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.position, required this.duration, required this.onSeek});

  final Duration position;
  final Duration? duration;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = duration != null && duration!.inMilliseconds > 0
        ? position.inMilliseconds / duration!.inMilliseconds
        : 0.0;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Slider(
        value: progress.clamp(0.0, 1.0),
        onChanged: duration != null ? (value) => onSeek(value) : null,
        activeColor: theme.colorScheme.primary,
        inactiveColor: theme.colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }
}

/// Playback control buttons
class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({
    required this.isPlaying,
    required this.hasAudio,
    required this.onPlayPressed,
    required this.onPausePressed,
    required this.onStopPressed,
  });

  final bool isPlaying;
  final bool hasAudio;
  final VoidCallback onPlayPressed;
  final VoidCallback onPausePressed;
  final VoidCallback onStopPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stop button
        _ControlButton(icon: Icons.stop, onPressed: hasAudio ? onStopPressed : null, size: 48),
        const SizedBox(width: 16),
        // Play/Pause button
        _ControlButton(
          icon: isPlaying ? Icons.pause : Icons.play_arrow,
          onPressed: hasAudio ? (isPlaying ? onPausePressed : onPlayPressed) : null,
          size: 64,
          isPrimary: true,
        ),
        const SizedBox(width: 16),
        // Placeholder for symmetry
        const SizedBox(width: 48),
      ],
    );
  }
}

/// Individual control button
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.size,
    this.isPrimary = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = onPressed == null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      opacity: disabled ? 0.5 : 1.0,
      child: SizedBox(
        width: size,
        height: size,
        child: FilledButton(
          onPressed: disabled ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: isPrimary
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            foregroundColor: isPrimary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: Icon(icon, size: isPrimary ? 32 : 24),
        ),
      ),
    );
  }
}
