import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Visualizes audio waveform using CustomPainter.
///
/// Displays audio amplitude data as vertical bars with optional
/// playback position indicator and different color states.
class WaveformVisualization extends StatelessWidget {
  const WaveformVisualization({
    super.key,
    required this.amplitudes,
    this.position = 0.0,
    this.duration = 1.0,
    this.color,
    this.isActive = false,
    this.barCount = 100,
    this.spacing = 2,
  });

  /// Normalized amplitude values (0.0 to 1.0)
  final List<double> amplitudes;

  /// Current playback position in seconds
  final double position;

  /// Total duration in seconds
  final double duration;

  /// Override color for waveform bars. Uses theme accent color if null.
  final Color? color;

  /// Whether the audio is currently playing or recording
  final bool isActive;

  /// Number of bars to display
  final int barCount;

  /// Spacing between bars in logical pixels
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final barColor = color ??
        (isDark ? AppColors.accentDark : AppColors.accentLight);

    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(double.infinity, 60),
        painter: _WaveformPainter(
          amplitudes: amplitudes,
          position: position,
          duration: duration,
          color: barColor,
          isActive: isActive,
          barCount: barCount,
          spacing: spacing,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.amplitudes,
    required this.position,
    required this.duration,
    required this.color,
    required this.isActive,
    required this.barCount,
    required this.spacing,
    required this.isDark,
  });

  final List<double> amplitudes;
  final double position;
  final double duration;
  final Color color;
  final bool isActive;
  final int barCount;
  final double spacing;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final progress = duration > 0 ? position / duration : 0;
    final availableWidth = size.width - (spacing * (barCount - 1));
    final barWidth = availableWidth / barCount;

    // Sample or interpolate amplitudes to match bar count
    final sampledAmplitudes = _sampleAmplitudes(amplitudes, barCount);

    final playedPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final unplayedPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      final amplitude = sampledAmplitudes[i];
      if (amplitude <= 0) continue;

      final barHeight = amplitude * size.height * 0.8;
      final x = i * (barWidth + spacing);
      final y = (size.height - barHeight) / 2;

      final isPlayed = (i / barCount) <= progress;
      final paint = isPlayed ? playedPaint : unplayedPaint;

      // Draw rounded rect for each bar
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(2),
      );

      canvas.drawRRect(rrect, paint);
    }

    // Draw position indicator if playing
    if (isActive && duration > 0) {
      final indicatorX = progress * size.width;

      final indicatorPaint = Paint()
        ..color = isDark ? Colors.white : Colors.black
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(indicatorX, 0),
        Offset(indicatorX, size.height),
        indicatorPaint,
      );
    }
  }

  /// Samples or interpolates amplitude data to match desired bar count.
  List<double> _sampleAmplitudes(List<double> source, int targetCount) {
    if (source.length <= targetCount) {
      return _interpolateAmplitudes(source, targetCount);
    }
    return _downsampleAmplitudes(source, targetCount);
  }

  /// Downsamples amplitudes by averaging chunks.
  List<double> _downsampleAmplitudes(List<double> source, int targetCount) {
    final result = <double>[];
    final chunkSize = source.length / targetCount;

    for (int i = 0; i < targetCount; i++) {
      final start = (i * chunkSize).floor();
      final end = ((i + 1) * chunkSize).ceil();
      final chunk = source.sublist(start, end.clamp(0, source.length));

      final avg = chunk.reduce((a, b) => a + b) / chunk.length;
      result.add(avg);
    }

    return result;
  }

  /// Interpolates amplitudes when source has fewer values than target.
  List<double> _interpolateAmplitudes(List<double> source, int targetCount) {
    if (source.isEmpty) return List.filled(targetCount, 0.0);
    if (source.length == 1) return List.filled(targetCount, source.first);

    final result = <double>[];
    final ratio = (source.length - 1) / (targetCount - 1);

    for (int i = 0; i < targetCount; i++) {
      final pos = i * ratio;
      final index = pos.floor();
      final fraction = pos - index;

      if (index >= source.length - 1) {
        result.add(source.last);
      } else {
        final interpolated = source[index] * (1 - fraction) + source[index + 1] * fraction;
        result.add(interpolated);
      }
    }

    return result;
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes ||
        oldDelegate.position != position ||
        oldDelegate.duration != duration ||
        oldDelegate.color != color ||
        oldDelegate.isActive != isActive ||
        oldDelegate.barCount != barCount;
  }
}
