import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'benchmark_helper.dart';

/// Tracks and reports performance test results for CI/CD integration.
///
/// This class collects benchmark results, compares them against baselines,
/// detects regressions, and outputs metrics in CI-friendly formats.
class PerformanceTracker {
  /// Creates a new performance tracker.
  ///
  /// [baselineData] is optional baseline metrics loaded from a baselines file.
  PerformanceTracker({Map<String, dynamic>? baselineData})
      : _baselines = baselineData ?? {};

  final Map<String, dynamic> _baselines;
  final List<BenchmarkResult> _results = [];
  final Map<String, String> _metadata = {};

  /// Adds metadata about the test run (e.g., device, OS, commit hash).
  void addMetadata(String key, String value) {
    _metadata[key] = value;
  }

  /// Records a benchmark result.
  void recordResult(BenchmarkResult result) {
    _results.add(result);
  }

  /// Records a benchmark with specified parameters.
  void record({
    required String name,
    required int valueMs,
    int? thresholdMs,
    int? baselineMs,
  }) {
    recordResult(BenchmarkResult(
      name: name,
      valueMs: valueMs,
      thresholdMs: thresholdMs,
      baselineMs: baselineMs,
    ));
  }

  /// Gets the baseline value for a metric name.
  int? getBaseline(String metricName) {
    final baseline = _baselines[metricName];
    if (baseline is Map && baseline['value_ms'] is int) {
      return baseline['value_ms'] as int;
    }
    if (baseline is int) {
      return baseline;
    }
    return null;
  }

  /// Checks if all metrics pass their thresholds.
  bool get allPassed => _results.every((r) => r.passesThreshold);

  /// Checks if any metrics failed their baseline comparison.
  bool get hasBaselineFailures =>
      _results.any((r) => !r.passesBaseline && r.baselineMs != null);

  /// Gets the list of failed results.
  List<BenchmarkResult> get failedResults =>
      _results.where((r) => !r.passesThreshold).toList();

  /// Gets the list of results that regressed from baseline.
  List<BenchmarkResult> get regressedResults =>
      _results.where((r) => !r.passesBaseline && r.baselineMs != null).toList();

  /// Generates a summary report for console output.
  String generateSummary() {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════════════════');
    buffer.writeln('           Performance Test Results');
    buffer.writeln('═══════════════════════════════════════════════════');

    if (_metadata.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Metadata:');
      _metadata.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
      buffer.writeln();
    }

    buffer.writeln('Results (${_results.length} benchmarks):');
    buffer.writeln();

    for (final result in _results) {
      final status = result.passesThreshold ? '✓ PASS' : '✗ FAIL';
      final baselineStatus = result.baselineMs != null
          ? (result.passesBaseline ? ' [baseline OK]' : ' [REGRESSION]')
          : '';

      buffer.writeln('  $status${baselineStatus}: ${result.name}');
      buffer.writeln('    Value: ${result.valueMs}ms');
      if (result.thresholdMs != null) {
        buffer.writeln('    Threshold: ${result.thresholdMs}ms');
      }
      if (result.baselineMs != null) {
        final diff = result.valueMs - result.baselineMs!;
        final percent = ((diff / result.baselineMs!) * 100).toStringAsFixed(1);
        final sign = diff >= 0 ? '+' : '';
        buffer.writeln('    Baseline: ${result.baselineMs}ms ($sign$diff, $percent%)');
      }
      buffer.writeln();
    }

    if (!allPassed) {
      buffer.writeln('═══════════════════════════════════════════════════');
      buffer.writeln('FAILED BENCHMARKS:');
      for (final result in failedResults) {
        buffer.writeln('  - ${result.name} (${result.valueMs}ms)');
        if (result.thresholdMs != null) {
          buffer.writeln('    Expected: ≤ ${result.thresholdMs}ms');
        }
      }
      buffer.writeln();
    }

    if (hasBaselineFailures) {
      buffer.writeln('═══════════════════════════════════════════════════');
      buffer.writeln('REGRESSIONS DETECTED:');
      for (final result in regressedResults) {
        final diff = result.valueMs - result.baselineMs!;
        final percent = ((diff / result.baselineMs!) * 100).toStringAsFixed(1);
        buffer.writeln('  - ${result.name}');
        buffer.writeln('    Previous: ${result.baselineMs}ms');
        buffer.writeln('    Current: ${result.valueMs}ms (+$diff, +$percent%)');
      }
      buffer.writeln();
    }

    buffer.writeln('═══════════════════════════════════════════════════');
    if (allPassed && !hasBaselineFailures) {
      buffer.writeln('Overall: ✓ ALL TESTS PASSED');
    } else if (!allPassed) {
      buffer.writeln('Overall: ✗ SOME TESTS FAILED');
    } else {
      buffer.writeln('Overall: ⚠ REGRESSIONS DETECTED');
    }
    buffer.writeln('═══════════════════════════════════════════════════');

    return buffer.toString();
  }

  /// Converts results to JSON format for CI consumption.
  Map<String, dynamic> toJson() {
    return {
      'summary': {
        'total_benchmarks': _results.length,
        'passed': _results.where((r) => r.passesThreshold).length,
        'failed': failedResults.length,
        'regressions': regressedResults.length,
        'all_passed': allPassed,
        'has_regressions': hasBaselineFailures,
      },
      if (_metadata.isNotEmpty) 'metadata': Map<String, dynamic>.from(_metadata),
      'results': _results.map((r) => r.toJson()).toList(),
      'baselines': _baselines,
    };
  }

  /// Writes results to a JSON file for CI artifact collection.
  ///
  /// [outputPath] is the file path to write the metrics JSON.
  /// Returns the file that was written.
  Future<File> writeResultsToJson(String outputPath) async {
    final jsonString = const JsonEncoder.withIndent('  ').convert(toJson());
    final file = File(outputPath);
    await file.writeAsString(jsonString);
    return file;
  }

  /// Writes GitHub Actions workflow annotations for CI integration.
  ///
  /// These annotations appear in the GitHub Actions UI and pull requests.
  /// Returns the annotation text.
  String generateGitHubAnnotations() {
    final buffer = StringBuffer();

    // Summary annotation
    final summary = allPassed && !hasBaselineFailures
        ? '✅ All ${_results.length} performance benchmarks passed'
        : hasBaselineFailures
            ? '⚠️ Performance regressions detected'
            : '❌ Some performance benchmarks failed';

    buffer.writeln('::notice title=Performance Test Summary::$summary');

    // Individual results
    for (final result in _results) {
      if (!result.passesThreshold) {
        final message =
            '${result.name}: ${result.valueMs}ms exceeds threshold ${result.thresholdMs}ms';
        buffer.writeln('::error title=Performance Benchmark Failed::$message');
      } else if (!result.passesBaseline && result.baselineMs != null) {
        final diff = result.valueMs - result.baselineMs!;
        final percent = ((diff / result.baselineMs!) * 100).toStringAsFixed(1);
        final message =
            '${result.name}: ${result.valueMs}ms vs baseline ${result.baselineMs}ms (+$diff, +$percent%)';
        buffer.writeln('::warning title=Performance Regression Detected::$message');
      }
    }

    return buffer.toString();
  }

  /// Prints GitHub Actions annotations to stdout.
  ///
  /// Call this in CI to make annotations appear in the GitHub Actions UI.
  void printGitHubAnnotations() {
    print(generateGitHubAnnotations());
  }

  /// Loads baseline metrics from a JSON file.
  ///
  /// Returns a new [PerformanceTracker] with the loaded baselines.
  static PerformanceTracker withBaselines(String baselinePath) {
    Map<String, dynamic> baselineData = {};

    final file = File(baselinePath);
    if (file.existsSync()) {
      try {
        final jsonString = file.readAsStringSync();
        final json = jsonDecode(jsonString) as Map<String, dynamic>;

        // Extract the baselines map if it exists
        if (json.containsKey('baselines')) {
          baselineData = json['baselines'] as Map<String, dynamic>;
        } else {
          baselineData = json;
        }
      } catch (_) {
        // If file can't be parsed, start with empty baselines
        baselineData = {};
      }
    }

    return PerformanceTracker(baselineData: baselineData);
  }

  /// Asserts that all benchmarks pass their thresholds.
  ///
  /// Throws [TestFailure] if any benchmark fails its threshold.
  void assertAllPassed() {
    if (!allPassed) {
      fail(
        'Performance benchmarks failed:\n'
        '${failedResults.map((r) => '  - ${r.name}: ${r.valueMs}ms (threshold: ${r.thresholdMs}ms)').join('\n')}',
      );
    }
  }

  /// Asserts that no regressions exist compared to baseline.
  ///
  /// Throws [TestFailure] if any metric regressed beyond acceptable variance.
  /// [regressionThreshold] is the maximum allowed regression as a percentage (0.2 = 20%).
  void assertNoRegressions({double regressionThreshold = 0.2}) {
    final regressions = <String>[];

    for (final result in _results) {
      if (result.baselineMs != null) {
        final threshold = (result.baselineMs! * regressionThreshold).ceil();
        final difference = result.valueMs - result.baselineMs!;

        if (difference > threshold) {
          final percent = ((difference / result.baselineMs!) * 100).toStringAsFixed(1);
          regressions.add(
            '  - ${result.name}: ${result.valueMs}ms vs baseline ${result.baselineMs}ms '
            '(+$difference, +$percent% exceeds ${regressionThreshold * 100}% threshold)',
          );
        }
      }
    }

    if (regressions.isNotEmpty) {
      fail(
        'Performance regressions detected:\n'
        '${regressions.join('\n')}',
      );
    }
  }

  /// Creates a baselines JSON file from the current results.
  ///
  /// Use this to establish new baselines after intentional improvements.
  /// [outputPath] is the file path to write the baselines JSON.
  Future<File> writeBaselines(String outputPath) async {
    final baselines = <String, dynamic>{};

    for (final result in _results) {
      baselines[result.name] = {
        'value_ms': result.valueMs,
        if (result.thresholdMs != null) 'threshold_ms': result.thresholdMs,
      };
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(baselines);
    final file = File(outputPath);
    await file.writeAsString(jsonString);
    return file;
  }

  /// Clears all recorded results.
  void clear() {
    _results.clear();
    _metadata.clear();
  }

  /// Gets all recorded results.
  List<BenchmarkResult> get results => List.unmodifiable(_results);

  /// Gets the number of recorded results.
  int get resultCount => _results.length;
}

/// Extension to add performance tracking convenience methods to tests.
extension PerformanceTracking on WidgetTester {
  /// Tracks execution time of an async operation and records it.
  ///
  /// Returns the elapsed time in milliseconds.
  Future<int> trackPerformance(
    String name,
    Future<void> Function() operation, {
    PerformanceTracker? tracker,
    int? thresholdMs,
    int? baselineMs,
  }) async {
    final elapsed = await BenchmarkHelper.recordTime(operation);

    tracker?.record(
      name: name,
      valueMs: elapsed,
      thresholdMs: thresholdMs,
      baselineMs: baselineMs,
    );

    return elapsed;
  }
}

void main() {
  group('PerformanceTracker', () {
    test('creates empty tracker', () {
      final tracker = PerformanceTracker();
      expect(tracker.resultCount, 0);
      expect(tracker.allPassed, isTrue);
      expect(tracker.hasBaselineFailures, isFalse);
    });

    test('records benchmark results', () {
      final tracker = PerformanceTracker();
      tracker.record(
        name: 'test_metric',
        valueMs: 100,
        thresholdMs: 200,
      );

      expect(tracker.resultCount, 1);
      expect(tracker.allPassed, isTrue);
    });

    test('detects failed benchmarks', () {
      final tracker = PerformanceTracker();
      tracker.record(
        name: 'slow_metric',
        valueMs: 300,
        thresholdMs: 200,
      );

      expect(tracker.allPassed, isFalse);
      expect(tracker.failedResults.length, 1);
      expect(tracker.failedResults.first.name, 'slow_metric');
    });

    test('detects regressions from baseline', () {
      final tracker = PerformanceTracker();
      tracker.record(
        name: 'regressed_metric',
        valueMs: 300,
        baselineMs: 200,
      );

      expect(tracker.hasBaselineFailures, isTrue);
      expect(tracker.regressedResults.length, 1);
    });

    test('tracks improvements from baseline', () {
      final tracker = PerformanceTracker();
      tracker.record(
        name: 'improved_metric',
        valueMs: 150,
        baselineMs: 200,
      );

      expect(tracker.hasBaselineFailures, isFalse);
    });

    test('adds and retrieves metadata', () {
      final tracker = PerformanceTracker();
      tracker.addMetadata('device', 'test-device');
      tracker.addMetadata('os', 'test-os');

      final json = tracker.toJson();
      expect(json['metadata']['device'], 'test-device');
      expect(json['metadata']['os'], 'test-os');
    });

    test('generates valid JSON output', () {
      final tracker = PerformanceTracker();
      tracker.record(
        name: 'test_metric',
        valueMs: 100,
        thresholdMs: 200,
        baselineMs: 150,
      );
      tracker.addMetadata('test_key', 'test_value');

      final json = tracker.toJson();

      expect(json['summary']['total_benchmarks'], 1);
      expect(json['summary']['passed'], 1);
      expect(json['results'].length, 1);
      expect(json['metadata']['test_key'], 'test_value');
    });

    test('generates summary text', () {
      final tracker = PerformanceTracker();
      tracker.record(
        name: 'test_metric',
        valueMs: 100,
        thresholdMs: 200,
      );

      final summary = tracker.generateSummary();

      expect(summary, contains('Performance Test Results'));
      expect(summary, contains('test_metric'));
      expect(summary, contains('100ms'));
      expect(summary, contains('✓ PASS'));
    });

    test('generates GitHub Actions annotations', () {
      final tracker = PerformanceTracker();
      tracker.record(
        name: 'good_metric',
        valueMs: 100,
        thresholdMs: 200,
      );
      tracker.record(
        name: 'bad_metric',
        valueMs: 300,
        thresholdMs: 200,
      );

      final annotations = tracker.generateGitHubAnnotations();

      expect(annotations, contains('::notice'));
      expect(annotations, contains('::error'));
      expect(annotations, contains('bad_metric'));
    });

    test('assertAllPassed throws when benchmarks fail', () {
      final tracker = PerformanceTracker();
      tracker.record(
        name: 'slow_metric',
        valueMs: 300,
        thresholdMs: 200,
      );

      expect(
        () => tracker.assertAllPassed(),
        throwsA(isA<TestFailure>()),
      );
    });

    test('assertAllPassed does not throw when all pass', () {
      final tracker = PerformanceTracker();
      tracker.record(
        name: 'fast_metric',
        valueMs: 100,
        thresholdMs: 200,
      );

      expect(() => tracker.assertAllPassed(), returnsNormally);
    });

    test('assertNoRegressions detects regressions above threshold', () {
      final tracker = PerformanceTracker();
      tracker.record(
        name: 'regressed_metric',
        valueMs: 300, // 50% regression
        baselineMs: 200,
      );

      expect(
        () => tracker.assertNoRegressions(regressionThreshold: 0.2),
        throwsA(isA<TestFailure>()),
      );
    });

    test('assertNoRegressions allows small variance', () {
      final tracker = PerformanceTracker();
      tracker.record(
        name: 'slightly_slow_metric',
        valueMs: 220, // 10% regression
        baselineMs: 200,
      );

      expect(
        () => tracker.assertNoRegressions(regressionThreshold: 0.2),
        returnsNormally,
      );
    });

    test('gets baseline from loaded data', () {
      final tracker = PerformanceTracker(
        baselineData: {'test_metric': {'value_ms': 150}},
      );

      expect(tracker.getBaseline('test_metric'), 150);
      expect(tracker.getBaseline('unknown_metric'), isNull);
    });

    test('clears results and metadata', () {
      final tracker = PerformanceTracker();
      tracker.record(name: 'test', valueMs: 100);
      tracker.addMetadata('key', 'value');

      expect(tracker.resultCount, 1);

      tracker.clear();

      expect(tracker.resultCount, 0);
      expect(tracker.toJson()['metadata'], isEmpty);
    });

    test('calculates summary statistics correctly', () {
      final tracker = PerformanceTracker();
      tracker.record(name: 'pass1', valueMs: 100, thresholdMs: 200);
      tracker.record(name: 'pass2', valueMs: 150, thresholdMs: 200);
      tracker.record(name: 'fail', valueMs: 300, thresholdMs: 200);
      tracker.record(name: 'regression', valueMs: 250, baselineMs: 200);

      final json = tracker.toJson();
      final summary = json['summary'];

      expect(summary['total_benchmarks'], 4);
      expect(summary['passed'], 3);
      expect(summary['failed'], 1);
      expect(summary['regressions'], 1);
      expect(summary['all_passed'], isFalse);
      expect(summary['has_regressions'], isTrue);
    });

    test('handles baseline with direct integer values', () {
      final tracker = PerformanceTracker(
        baselineData: {'metric': 100},
      );

      expect(tracker.getBaseline('metric'), 100);
    });

    test('handles missing baseline file gracefully', () {
      final tracker = PerformanceTracker.withBaselines('nonexistent.json');

      expect(tracker.resultCount, 0);
      expect(tracker.getBaseline('any_metric'), isNull);
    });
  });

  group('BenchmarkResult', () {
    test('calculates passesThreshold correctly', () {
      const result1 = BenchmarkResult(
        name: 'test',
        valueMs: 100,
        thresholdMs: 200,
      );
      expect(result1.passesThreshold, isTrue);

      const result2 = BenchmarkResult(
        name: 'test',
        valueMs: 300,
        thresholdMs: 200,
      );
      expect(result2.passesThreshold, isFalse);

      const result3 = BenchmarkResult(
        name: 'test',
        valueMs: 100,
      );
      expect(result3.passesThreshold, isTrue); // No threshold = passes
    });

    test('calculates passesBaseline correctly', () {
      const result1 = BenchmarkResult(
        name: 'test',
        valueMs: 150,
        baselineMs: 200,
      );
      expect(result1.passesBaseline, isTrue);

      const result2 = BenchmarkResult(
        name: 'test',
        valueMs: 250,
        baselineMs: 200,
      );
      expect(result2.passesBaseline, isFalse);
    });

    test('converts to JSON correctly', () {
      const result = BenchmarkResult(
        name: 'test_metric',
        valueMs: 150,
        thresholdMs: 200,
        baselineMs: 100,
      );

      final json = result.toJson();

      expect(json['name'], 'test_metric');
      expect(json['value_ms'], 150);
      expect(json['threshold_ms'], 200);
      expect(json['baseline_ms'], 100);
      expect(json['passes_threshold'], isTrue);
      expect(json['passes_baseline'], isFalse);
    });

    test('toString includes all relevant data', () {
      const result = BenchmarkResult(
        name: 'test_metric',
        valueMs: 150,
        thresholdMs: 200,
        baselineMs: 100,
      );

      final str = result.toString();

      expect(str, contains('test_metric'));
      expect(str, contains('150ms'));
      expect(str, contains('threshold: 200ms'));
      expect(str, contains('baseline: 100ms'));
      expect(str, contains('+50')); // difference from baseline
    });
  });
}
    test('calculates passesThreshold correctly', () {
      const result1 = BenchmarkResult(
        name: 'test',
        valueMs: 100,
        thresholdMs: 200,
      );
      expect(result1.passesThreshold, isTrue);

      const result2 = BenchmarkResult(
        name: 'test',
        valueMs: 300,
        thresholdMs: 200,
      );
      expect(result2.passesThreshold, isFalse);

      const result3 = BenchmarkResult(
        name: 'test',
        valueMs: 100,
      );
      expect(result3.passesThreshold, isTrue); // No threshold = passes
    });

    test('calculates passesBaseline correctly', () {
      const result1 = BenchmarkResult(
        name: 'test',
        valueMs: 150,
        baselineMs: 200,
      );
      expect(result1.passesBaseline, isTrue);

      const result2 = BenchmarkResult(
        name: 'test',
        valueMs: 250,
        baselineMs: 200,
      );
      expect(result2.passesBaseline, isFalse);
    });

    test('converts to JSON correctly', () {
      const result = BenchmarkResult(
        name: 'test_metric',
        valueMs: 150,
        thresholdMs: 200,
        baselineMs: 100,
      );

      final json = result.toJson();

      expect(json['name'], 'test_metric');
      expect(json['value_ms'], 150);
      expect(json['threshold_ms'], 200);
      expect(json['baseline_ms'], 100);
      expect(json['passes_threshold'], isTrue);
      expect(json['passes_baseline'], isFalse);
    });

    test('toString includes all relevant data', () {
      const result = BenchmarkResult(
        name: 'test_metric',
        valueMs: 150,
        thresholdMs: 200,
        baselineMs: 100,
      );

      final str = result.toString();

      expect(str, contains('test_metric'));
      expect(str, contains('150ms'));
      expect(str, contains('threshold: 200ms'));
      expect(str, contains('baseline: 100ms'));
      expect(str, contains('+50')); // difference from baseline
    });
  });
}
