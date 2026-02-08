import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/main.dart' as app;
import 'package:noteable_app/services/di/service_locator.dart';

import 'benchmark_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Ensure clean state before each test
    await resetServiceLocator();
  });

  testWidgets('app launch time must be under 2000ms', (tester) async {
    final launchTime = await BenchmarkHelper.recordTime(() async {
      // Measure from service locator setup to first frame
      await setupServiceLocator();
      await tester.pumpWidget(const app.NoteableApp());
      await tester.pumpAndSettle();
    });

    BenchmarkHelper.assertMaxPerformance(
      metricName: 'App launch time',
      metric: launchTime,
      maximum: 2000,
    );
  });

  testWidgets('app launch time average (3 runs) must be under 2000ms',
      (tester) async {
    final avgLaunchTime = await BenchmarkHelper.recordAverageTime(
      () async {
        await resetServiceLocator();
        await setupServiceLocator();
        await tester.pumpWidget(const app.NoteableApp());
        await tester.pumpAndSettle();
      },
      runs: 3,
      warmupRuns: 1,
    );

    BenchmarkHelper.assertMaxPerformance(
      metricName: 'Average app launch time',
      metric: avgLaunchTime,
      maximum: 2000,
    );
  });

  testWidgets('app first render time must be under 1500ms', (tester) async {
    await setupServiceLocator();

    final renderTime = BenchmarkHelper.recordSyncTime(() {
      tester.pumpWidget(const app.NoteableApp());
      // Pump once to trigger initial build
      tester.pump();
    });

    BenchmarkHelper.assertMaxPerformance(
      metricName: 'App first render time',
      metric: renderTime,
      maximum: 1500,
    );
  });
}
