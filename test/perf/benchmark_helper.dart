import 'dart:async';
import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for performance benchmarking operations.
///
/// Provides utilities for timing operations, measuring frame rates,
/// and tracking performance metrics for regression testing.
class BenchmarkHelper {
  /// Records the execution time of an [operation].
  ///
  /// Returns the duration in milliseconds.
  static Future<int> recordTime(Future<void> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  /// Records the execution time of a synchronous [operation].
  ///
  /// Returns the duration in milliseconds.
  static int recordSyncTime(void Function() operation) {
    final stopwatch = Stopwatch()..start();
    operation();
    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  /// Runs an [operation] multiple times and returns the average duration in ms.
  ///
  /// Useful for reducing noise in performance measurements.
  /// [warmupRuns] are executed before timing (not included in average).
  static Future<int> recordAverageTime(
    Future<void> Function() operation, {
    int runs = 10,
    int warmupRuns = 2,
  }) async {
    // Warmup runs to allow JIT compilation
    for (int i = 0; i < warmupRuns; i++) {
      await operation();
    }

    final timings = <int>[];
    for (int i = 0; i < runs; i++) {
      final elapsed = await recordTime(operation);
      timings.add(elapsed);
    }

    // Calculate average
    final sum = timings.reduce((a, b) => a + b);
    return sum ~/ timings.length;
  }

  /// Measures frame rate during a scrolling operation.
  ///
  /// Returns the average frames per second (FPS) during the operation.
  /// Use with widget tests that involve scrolling.
  static Future<double> measureFrameRate(
    Future<void> Function() operation,
  ) async {
    final frameTimings = <FrameTiming>[];
    final completer = Completer<void>();

    // Record frame timings using the scheduler binding
    void onFrame(List<FrameTiming> timings) {
      frameTimings.addAll(timings);
      if (!completer.isCompleted) {
        SchedulerBinding.instance.scheduleFrame();
      }
    }

    SchedulerBinding.instance.addTimingsCallback(onFrame);

    try {
      await operation();
      // Allow a few more frames to complete
      await Future.delayed(const Duration(milliseconds: 100));
    } finally {
      SchedulerBinding.instance.removeTimingsCallback(onFrame);
      completer.complete();
    }

    if (frameTimings.isEmpty) return 0.0;

    // Calculate FPS based on frame timings
    final totalDuration = frameTimings.last.totalSpan.inMicroseconds -
        frameTimings.first.totalSpan.inMicroseconds;
    if (totalDuration <= 0) return 0.0;

    final seconds = totalDuration / 1000000.0;
    final fps = frameTimings.length / seconds;
    return fps;
  }

  /// Asserts that a performance [metric] is within [threshold] ms of [baseline].
  ///
  /// Throws [TestFailure] if the metric exceeds the baseline by more than
  /// the allowed threshold percentage.
  static void assertWithinThreshold({
    required String metricName,
    required int metric,
    required int baseline,
    required double thresholdPercentage,
  }) {
    final threshold = (baseline * thresholdPercentage).ceil();
    final difference = (metric - baseline).abs();

    if (difference > threshold) {
      final regression = metric > baseline;
      final percentChange = ((difference / baseline) * 100).toStringAsFixed(1);
      fail(
        '$metricName performance ${regression ? "regression" : "improvement"} detected:\n'
        '  Baseline: ${baseline}ms\n'
        '  Current: ${metric}ms\n'
        '  Difference: ${difference}ms ($percentChange%)\n'
        '  Threshold: ${thresholdPercentage * 100}%\n'
        '  ${regression ? "FAIL: Performance degraded beyond threshold" : "Note: Performance improved"}',
      );
    }
  }

  /// Asserts that a performance [metric] does not exceed [maximum] ms.
  static void assertMaxPerformance({
    required String metricName,
    required int metric,
    required int maximum,
  }) {
    expect(
      metric,
      lessThanOrEqualTo(maximum),
      reason: '$metricName (${metric}ms) exceeds maximum allowed (${maximum}ms)',
    );
  }
}

/// Simple data class for tracking benchmark results.
class BenchmarkResult {
  const BenchmarkResult({
    required this.name,
    required this.valueMs,
    this.thresholdMs,
    this.baselineMs,
  });

  final String name;
  final int valueMs;
  final int? thresholdMs;
  final int? baselineMs;

  bool get passesThreshold =>
      thresholdMs == null || valueMs <= thresholdMs!;

  bool get passesBaseline =>
      baselineMs == null || valueMs <= baselineMs!;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$name: ${valueMs}ms');
    if (thresholdMs != null) {
      buffer.write(' (threshold: ${thresholdMs}ms)');
    }
    if (baselineMs != null) {
      final diff = valueMs - baselineMs!;
      final percent = ((diff / baselineMs!) * 100).toStringAsFixed(1);
      buffer.write(' (baseline: ${baselineMs}ms, ');
      buffer.write(diff >= 0 ? '+' : '');
      buffer.write('${diff}ms / $percent%)');
    }
    return buffer.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value_ms': valueMs,
      if (thresholdMs != null) 'threshold_ms': thresholdMs,
      if (baselineMs != null) 'baseline_ms': baselineMs,
      'passes_threshold': passesThreshold,
      'passes_baseline': passesBaseline,
    };
  }
}
