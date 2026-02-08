import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';

import 'benchmark_helper.dart';
import 'test_data_generator.dart';

void main() {
  late InMemoryNotesFeatureRepository repository;

  setUp(() {
    repository = InMemoryNotesFeatureRepository();
  });

  group('Search Performance Benchmarks', () {
    testWidgets('search across 1000 notes must be under 300ms', (tester) async {
      // Generate and insert 1000 notes
      final notes = TestDataGenerator.generateNotes(count: 1000);
      for (final note in notes) {
        await repository.createNote(
          title: note.title,
          content: note.content,
          folderId: note.folderId,
        );
      }

      // Measure search performance for a common term
      final searchTime = await BenchmarkHelper.recordTime(() async {
        final useCase = SearchNotesUseCase(repository);
        final result = await useCase('Meeting');
        expect(result, isNotEmpty);
      });

      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Search across 1000 notes',
        metric: searchTime,
        maximum: 300,
      );
    });

    testWidgets('search with no results must be under 300ms', (tester) async {
      final notes = TestDataGenerator.generateNotes(count: 1000);
      for (final note in notes) {
        await repository.createNote(
          title: note.title,
          content: note.content,
        );
      }

      // Search for something that won't exist
      final searchTime = await BenchmarkHelper.recordTime(() async {
        final useCase = SearchNotesUseCase(repository);
        final result = await useCase('xyznonexistent123');
        expect(result, isEmpty);
      });

      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Search with no results',
        metric: searchTime,
        maximum: 300,
      );
    });

    testWidgets('search average (5 runs) across 1000 notes must be under 300ms',
        (tester) async {
      final notes = TestDataGenerator.generateNotes(count: 1000);
      for (final note in notes) {
        await repository.createNote(
          title: note.title,
          content: note.content,
        );
      }

      final avgSearchTime = await BenchmarkHelper.recordAverageTime(
        () async {
          final useCase = SearchNotesUseCase(repository);
          await useCase('Project');
        },
        runs: 5,
        warmupRuns: 1,
      );

      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Average search time',
        metric: avgSearchTime,
        maximum: 300,
      );
    });

    testWidgets('direct repository search must be under 300ms', (tester) async {
      final notes = TestDataGenerator.generateNotes(count: 1000);
      for (final note in notes) {
        await repository.createNote(
          title: note.title,
          content: note.content,
        );
      }

      // Test direct repository search
      final searchTime = await BenchmarkHelper.recordTime(() async {
        final results = await repository.searchNotes('Meeting');
        expect(results, isNotEmpty);
      });

      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Direct repository search',
        metric: searchTime,
        maximum: 300,
      );
    });

    testWidgets('multiple search queries performance test', (tester) async {
      final notes = TestDataGenerator.generateNotes(count: 1000);
      for (final note in notes) {
        await repository.createNote(
          title: note.title,
          content: note.content,
        );
      }

      // Test multiple different search queries
      final queries = ['Meeting', 'Project', 'Idea', 'Task', 'Reminder'];
      final timings = <int>[];

      for (final query in queries) {
        final searchTime = await BenchmarkHelper.recordTime(() async {
          final useCase = SearchNotesUseCase(repository);
          await useCase(query);
        });
        timings.add(searchTime);
      }

      // All searches should be under 300ms
      for (var i = 0; i < queries.length; i++) {
        BenchmarkHelper.assertMaxPerformance(
          metricName: 'Search for "${queries[i]}"',
          metric: timings[i],
          maximum: 300,
        );
      }

      // Average should also be under 300ms
      final avgTime = timings.reduce((a, b) => a + b) ~/ timings.length;
      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Average multiple search time',
        metric: avgTime,
        maximum: 300,
      );
    });

    testWidgets('search with partial matches must be under 300ms', (tester) async {
      final notes = TestDataGenerator.generateNotes(count: 1000);
      for (final note in notes) {
        await repository.createNote(
          title: note.title,
          content: note.content,
        );
      }

      // Search for partial strings that should match many results
      final searchTime = await BenchmarkHelper.recordTime(() async {
        final useCase = SearchNotesUseCase(repository);
        final result = await useCase('Notes'); // Should match "Meeting Notes", "Project Notes", etc.
        expect(result, isNotEmpty);
      });

      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Search with partial matches',
        metric: searchTime,
        maximum: 300,
      );
    });

    testWidgets('case-insensitive search must be under 300ms', (tester) async {
      final notes = TestDataGenerator.generateNotes(count: 1000);
      for (final note in notes) {
        await repository.createNote(
          title: note.title,
          content: note.content,
        );
      }

      // Test case insensitivity by searching with different cases
      final variants = ['meeting', 'MEETING', 'Meeting', 'MeEtInG'];
      final timings = <int>[];

      for (final query in variants) {
        final searchTime = await BenchmarkHelper.recordTime(() async {
          final useCase = SearchNotesUseCase(repository);
          await useCase(query);
        });
        timings.add(searchTime);
      }

      // All case variations should perform similarly
      final avgTime = timings.reduce((a, b) => a + b) ~/ timings.length;
      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Case-insensitive search average',
        metric: avgTime,
        maximum: 300,
      );
    });

    testWidgets('search performance scales linearly with dataset size',
        (tester) async {
      // Test with increasing dataset sizes
      final sizes = [100, 500, 1000];
      final timings = <int>[];

      for (final size in sizes) {
        final testRepo = InMemoryNotesFeatureRepository();
        final notes = TestDataGenerator.generateNotes(count: size);
        for (final note in notes) {
          await testRepo.createNote(
            title: note.title,
            content: note.content,
          );
        }

        final searchTime = await BenchmarkHelper.recordTime(() async {
          await testRepo.searchNotes('Meeting');
        });
        timings.add(searchTime);
      }

      // Verify 1000 note search is still under 300ms
      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Search across 1000 notes (scaling test)',
        metric: timings.last,
        maximum: 300,
      );

      // If both timings are non-zero, verify linear scaling
      if (timings.first > 0 && timings.last > 0) {
        expect(
          timings.last,
          lessThan(timings.first * 20),
          reason: 'Search time should scale roughly linearly with dataset size',
        );
      }
    });
  });
}
