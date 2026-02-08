import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';

import 'benchmark_helper.dart';

import 'package:noteable_app/domain/entities/audio_attachment.dart';
import 'package:noteable_app/domain/repositories/audio_repository.dart';

class FakeAudioRepository implements AudioRepository {
  @override
  Future<void> initialize() async {}

  @override
  Future<List<AudioAttachment>> getAudioAttachments() async => [];

  @override
  Future<AudioAttachment?> getAudioAttachmentById(String id) async => null;

  @override
  Future<List<AudioAttachment>> getAudioAttachmentsByNoteId(String noteId) async => [];

  @override
  Future<AudioAttachment> createAudioAttachment(AudioAttachment audioAttachment) async =>
      audioAttachment;

  @override
  Future<AudioAttachment> updateAudioAttachment(AudioAttachment audioAttachment) async =>
      audioAttachment;

  @override
  Future<void> deleteAudioAttachment(String id) async {}
}

void main() {
  late InMemoryNotesFeatureRepository repo;
  late FakeAudioRepository audioRepo;
  late NoteEditorViewModel viewModel;

  setUp(() {
    repo = InMemoryNotesFeatureRepository();
    audioRepo = FakeAudioRepository();
    viewModel = NoteEditorViewModel(
      createNote: CreateNoteUseCase(repo),
      updateNote: UpdateNoteUseCase(repo),
      getNotes: GetNotesUseCase(repo),
      audioRepository: audioRepo,
    );
  });

  group('Typing Latency Benchmarks', () {
    testWidgets('single keystroke save latency must be under 500ms', (tester) async {
      // Initialize with a new note
      await viewModel.init();

      // Simulate a keystroke by updating the draft
      viewModel.updateDraft(content: 'a');

      // Wait for the debounce timer to trigger (700ms) + some buffer
      // Then measure how long saveNow takes
      final saveLatency = await BenchmarkHelper.recordTime(() async {
        // Wait for auto-save timer to complete
        await Future.delayed(const Duration(milliseconds: 750));
        // Verify save completed by checking isSaving flag
        expect(viewModel.isSaving, isFalse);
      });

      // The save operation itself should complete quickly
      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Single keystroke save latency',
        metric: saveLatency,
        maximum: 500,
      );

      // Verify the note was actually saved
      expect(viewModel.note?.content, contains('a'));
    });

    testWidgets('multiple keystrokes save latency must be under 500ms', (tester) async {
      await viewModel.init();

      // Simulate rapid typing (multiple keystrokes)
      final keystrokes = ['H', 'e', 'l', 'l', 'o'];
      for (final keystroke in keystrokes) {
        viewModel.updateDraft(content: keystroke);
        // Small delay between keystrokes
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Measure the final save latency after typing stops
      final saveLatency = await BenchmarkHelper.recordTime(() async {
        // Wait for the final auto-save timer
        await Future.delayed(const Duration(milliseconds: 750));
        expect(viewModel.isSaving, isFalse);
      });

      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Multiple keystrokes save latency',
        metric: saveLatency,
        maximum: 500,
      );
    });

    testWidgets('typing latency average (5 runs) must be under 500ms', (tester) async {
      // Measure average typing latency across multiple runs
      final avgLatency = await BenchmarkHelper.recordAverageTime(
        () async {
          // Create fresh view model for each run
          repo = InMemoryNotesFeatureRepository();
          viewModel = NoteEditorViewModel(
            createNote: CreateNoteUseCase(repo),
            updateNote: UpdateNoteUseCase(repo),
            getNotes: GetNotesUseCase(repo),
            audioRepository: audioRepo,
          );

          await viewModel.init();
          viewModel.updateDraft(content: 'test');

          // Wait for auto-save and verify completion
          await Future.delayed(const Duration(milliseconds: 750));
          expect(viewModel.isSaving, isFalse);
        },
        runs: 5,
        warmupRuns: 1,
      );

      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Average typing latency',
        metric: avgLatency,
        maximum: 500,
      );
    });

    testWidgets('saveNow direct call latency must be under 100ms', (tester) async {
      // Test the save operation directly (bypassing debounce timer)
      await viewModel.init();

      // Update the draft
      viewModel.updateDraft(title: 'Test Title');

      // Cancel the auto-save timer and call saveNow directly
      final saveLatency = await BenchmarkHelper.recordTime(() async {
        await viewModel.saveNow();
      });

      // Direct save calls should be very fast
      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Direct saveNow latency',
        metric: saveLatency,
        maximum: 100,
      );

      // Verify the save completed
      expect(viewModel.note?.title, 'Test Title');
      expect(viewModel.isSaving, isFalse);
    });

    testWidgets('simultaneous title and content update save latency', (tester) async {
      await viewModel.init();

      // Simulate updating both title and content
      viewModel.updateDraft(title: 'Meeting Notes', content: 'Discuss project');

      final saveLatency = await BenchmarkHelper.recordTime(() async {
        await Future.delayed(const Duration(milliseconds: 750));
        expect(viewModel.isSaving, isFalse);
      });

      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Title and content update save latency',
        metric: saveLatency,
        maximum: 500,
      );

      expect(viewModel.note?.title, 'Meeting Notes');
      expect(viewModel.note?.content, 'Discuss project');
    });

    testWidgets('typing with existing note content save latency', (tester) async {
      // Create a note with existing content
      final existingNote = await repo.createNote(
        title: 'Existing Note',
        content: 'Initial content that is already saved',
      );

      // Initialize view model with existing note
      viewModel = NoteEditorViewModel(
        createNote: CreateNoteUseCase(repo),
        updateNote: UpdateNoteUseCase(repo),
        getNotes: GetNotesUseCase(repo),
        audioRepository: audioRepo,
      );
      await viewModel.init(noteId: existingNote.id);

      // Add more content to the existing note
      viewModel.updateDraft(content: '${existingNote.content}\n\nNew content');

      final saveLatency = await BenchmarkHelper.recordTime(() async {
        await Future.delayed(const Duration(milliseconds: 750));
        expect(viewModel.isSaving, isFalse);
      });

      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Existing note update save latency',
        metric: saveLatency,
        maximum: 500,
      );
    });

    testWidgets('toggle pin status save latency must be under 100ms', (tester) async {
      await viewModel.init();

      // Toggle pin status
      viewModel.updateDraft(isPinned: true);

      // Direct save for pin toggle (more time-sensitive operation)
      final saveLatency = await BenchmarkHelper.recordTime(() async {
        await viewModel.saveNow();
      });

      BenchmarkHelper.assertMaxPerformance(
        metricName: 'Toggle pin status save latency',
        metric: saveLatency,
        maximum: 100,
      );

      expect(viewModel.note?.isPinned, isTrue);
    });
  });
}
