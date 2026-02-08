import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/presentation/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

import 'benchmark_helper.dart';
import 'test_data_generator.dart';

/// Builds a NotesViewModel with a specified number of notes.
Future<NotesViewModel> _buildVmWithNotes(int noteCount) async {
  final repo = InMemoryNotesFeatureRepository();
  final notes = TestDataGenerator.generateNotes(count: noteCount);

  for (final note in notes) {
    await repo.createNote(
      title: note.title,
      content: note.content,
      isPinned: note.isPinned,
      folderId: note.folderId,
    );
  }

  final vm = NotesViewModel(
    getNotes: GetNotesUseCase(repo),
    deleteNote: DeleteNoteUseCase(repo),
    togglePin: TogglePinUseCase(repo),
    getFolders: GetFoldersUseCase(repo),
    createFolder: CreateFolderUseCase(repo),
    renameFolder: RenameFolderUseCase(repo),
    deleteFolder: DeleteFolderUseCase(repo),
    searchNotes: SearchNotesUseCase(repo),
  );
  await vm.load();
  return vm;
}

/// Builds the app widget with the provided NotesViewModel.
Widget _buildApp(NotesViewModel vm) {
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, __) => const HomeScreen())],
  );
  return ChangeNotifierProvider.value(
    value: vm,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('Scroll Performance Tests', () {
    testWidgets('scroll through 100 notes maintains 60fps', (tester) async {
      final vm = await _buildVmWithNotes(100);
      await tester.pumpWidget(_buildApp(vm));

      // Find the ListView
      final listFinder = find.byType(ListView);
      expect(listFinder, findsOneWidget);

      // Measure frame rate during scroll
      final fps = await BenchmarkHelper.measureFrameRate(() async {
        // Scroll through the list in increments
        for (int i = 0; i < 10; i++) {
          await tester.fling(
            find.byType(ListView),
            const Offset(0, -500),
            10000,
          );
          // Pump a few frames to allow the scroll to complete
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
        }
      });

      // Assert 60fps is maintained (allow some tolerance)
      expect(
        fps,
        greaterThanOrEqualTo(55),
        reason: 'Scroll frame rate (${fps.toStringAsFixed(1)} FPS) is below 55 FPS threshold',
      );
    });

    testWidgets('scroll through 1000 notes maintains 60fps', (tester) async {
      final vm = await _buildVmWithNotes(1000);
      await tester.pumpWidget(_buildApp(vm));

      // Find the ListView
      final listFinder = find.byType(ListView);
      expect(listFinder, findsOneWidget);

      // Measure frame rate during scroll
      final fps = await BenchmarkHelper.measureFrameRate(() async {
        // Scroll through the list in increments
        for (int i = 0; i < 15; i++) {
          await tester.fling(
            find.byType(ListView),
            const Offset(0, -500),
            10000,
          );
          // Pump frames to allow the scroll to complete
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
        }
      });

      // Assert 60fps is maintained (allow some tolerance)
      expect(
        fps,
        greaterThanOrEqualTo(55),
        reason: 'Scroll frame rate (${fps.toStringAsFixed(1)} FPS) is below 55 FPS threshold',
      );
    });

    testWidgets('rapid scroll flings maintain 60fps', (tester) async {
      final vm = await _buildVmWithNotes(500);
      await tester.pumpWidget(_buildApp(vm));

      // Find the ListView
      final listFinder = find.byType(ListView);
      expect(listFinder, findsOneWidget);

      // Measure frame rate during rapid scroll
      final fps = await BenchmarkHelper.measureFrameRate(() async {
        // Perform rapid flings
        for (int i = 0; i < 10; i++) {
          await tester.fling(
            find.byType(ListView),
            const Offset(0, -800),
            15000,
          );
          await tester.pump(const Duration(milliseconds: 16));
          await tester.pump(const Duration(milliseconds: 16));
        }
      });

      // Assert 60fps is maintained (allow some tolerance for rapid movements)
      expect(
        fps,
        greaterThanOrEqualTo(50),
        reason: 'Rapid scroll frame rate (${fps.toStringAsFixed(1)} FPS) is below 50 FPS threshold',
      );
    });

    testWidgets('scroll to bottom and back maintains 60fps', (tester) async {
      final vm = await _buildVmWithNotes(200);
      await tester.pumpWidget(_buildApp(vm));

      // Find the ListView
      final listFinder = find.byType(ListView);
      expect(listFinder, findsOneWidget);

      // Measure frame rate during full scroll
      final fps = await BenchmarkHelper.measureFrameRate(() async {
        // Scroll to bottom
        await tester.drag(
          find.byType(ListView),
          const Offset(0, -10000),
        );
        await tester.pumpAndSettle();

        // Scroll back to top
        await tester.drag(
          find.byType(ListView),
          const Offset(0, 10000),
        );
        await tester.pumpAndSettle();
      });

      // Assert 60fps is maintained
      expect(
        fps,
        greaterThanOrEqualTo(55),
        reason: 'Full scroll frame rate (${fps.toStringAsFixed(1)} FPS) is below 55 FPS threshold',
      );
    });

    testWidgets('scroll performance average (3 runs) maintains 60fps',
        (tester) async {
      final fpsValues = <double>[];

      for (int i = 0; i < 3; i++) {
        final vm = await _buildVmWithNotes(300);
        await tester.pumpWidget(_buildApp(vm));

        final listFinder = find.byType(ListView);
        expect(listFinder, findsOneWidget);

        final fps = await BenchmarkHelper.measureFrameRate(() async {
          for (int j = 0; j < 5; j++) {
            await tester.fling(
              find.byType(ListView),
              const Offset(0, -500),
              10000,
            );
            await tester.pump(const Duration(milliseconds: 50));
            await tester.pump(const Duration(milliseconds: 50));
          }
        });

        fpsValues.add(fps);
      }

      // Calculate average FPS
      final avgFps = fpsValues.reduce((a, b) => a + b) / fpsValues.length;

      // Assert average is at least 55 FPS
      expect(
        avgFps,
        greaterThanOrEqualTo(55),
        reason: 'Average scroll frame rate (${avgFps.toStringAsFixed(1)} FPS) is below 55 FPS threshold. '
            'Individual runs: ${fpsValues.map((f) => f.toStringAsFixed(1)).join(', ')} FPS',
      );
    });

    testWidgets('scroll with pinned notes at top maintains 60fps',
        (tester) async {
      final repo = InMemoryNotesFeatureRepository();

      // Create pinned notes first (they appear at the top)
      for (int i = 0; i < 10; i++) {
        await repo.createNote(
          title: 'Pinned Note $i',
          content: 'Content for pinned note $i',
          isPinned: true,
        );
      }

      // Create regular notes
      for (int i = 0; i < 200; i++) {
        await repo.createNote(
          title: 'Regular Note $i',
          content: 'Content for regular note $i',
          isPinned: false,
        );
      }

      final vm = NotesViewModel(
        getNotes: GetNotesUseCase(repo),
        deleteNote: DeleteNoteUseCase(repo),
        togglePin: TogglePinUseCase(repo),
        getFolders: GetFoldersUseCase(repo),
        createFolder: CreateFolderUseCase(repo),
        renameFolder: RenameFolderUseCase(repo),
        deleteFolder: DeleteFolderUseCase(repo),
        searchNotes: SearchNotesUseCase(repo),
      );
      await vm.load();

      await tester.pumpWidget(_buildApp(vm));

      final listFinder = find.byType(ListView);
      expect(listFinder, findsOneWidget);

      final fps = await BenchmarkHelper.measureFrameRate(() async {
        for (int i = 0; i < 8; i++) {
          await tester.fling(
            find.byType(ListView),
            const Offset(0, -500),
            10000,
          );
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
        }
      });

      expect(
        fps,
        greaterThanOrEqualTo(55),
        reason: 'Scroll with pinned notes frame rate (${fps.toStringAsFixed(1)} FPS) is below 55 FPS threshold',
      );
    });

    testWidgets('scroll stops cleanly without jank', (tester) async {
      final vm = await _buildVmWithNotes(300);
      await tester.pumpWidget(_buildApp(vm));

      final listFinder = find.byType(ListView);
      expect(listFinder, findsOneWidget);

      // Measure frame rate during scroll and stop
      final fps = await BenchmarkHelper.measureFrameRate(() async {
        // Start scroll
        await tester.fling(
          find.byType(ListView),
          const Offset(0, -800),
          12000,
        );

        // Let it scroll through multiple frames
        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        // Stop cleanly
        await tester.pumpAndSettle();
      });

      // Should maintain good frame rate even during deceleration
      expect(
        fps,
        greaterThanOrEqualTo(50),
        reason: 'Scroll stop frame rate (${fps.toStringAsFixed(1)} FPS) is below 50 FPS threshold',
      );
    });
  });
}
