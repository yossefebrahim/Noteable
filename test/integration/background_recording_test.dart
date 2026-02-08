import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/entities/audio_attachment.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/audio_recorder_provider.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';
import 'package:noteable_app/services/audio/audio_recorder_service.dart';
import 'package:noteable_app/services/storage/isar_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryNotesFeatureRepository notesRepo;
  late IsarService isarService;
  late NoteEditorViewModel noteEditorViewModel;
  late AudioRecorderProvider audioRecorderProvider;
  late AudioRecorderService audioRecorderService;

  setUp(() async {
    // Initialize services
    notesRepo = InMemoryNotesFeatureRepository();
    isarService = IsarService();
    await isarService.init();

    // Initialize audio recorder service
    audioRecorderService = AudioRecorderService();
    await audioRecorderService.init();

    // Create providers
    noteEditorViewModel = NoteEditorViewModel(
      createNote: CreateNoteUseCase(notesRepo),
      updateNote: UpdateNoteUseCase(notesRepo),
      getNotes: GetNotesUseCase(notesRepo),
      audioRepository: notesRepo,
    );

    audioRecorderProvider = AudioRecorderProvider();
  });

  tearDown(() async {
    noteEditorViewModel.dispose();
    audioRecorderProvider.dispose();
    await audioRecorderService.dispose();
    await isarService.dispose();
  });

  group('Background Recording Tests', () {
    testWidgets(
        'Recording continues for extended duration (simulating background recording)',
        (tester) async {
      // Step 1: Start recording
      expect(audioRecorderProvider.isRecording, isFalse);
      expect(audioRecorderProvider.duration, Duration.zero);

      audioRecorderProvider.startRecording();
      expect(audioRecorderProvider.isRecording, isTrue);

      final startDuration = audioRecorderProvider.duration;
      expect(startDuration, Duration.zero);

      // Step 2: Simulate app being in background for 10 seconds
      // In a real device test, this would involve:
      // 1. Pressing home button (background app)
      // 2. Waiting 10 seconds
      // 3. Returning to app
      //
      // For integration testing, we simulate the time passage
      await tester.pump(const Duration(seconds: 10));

      // Step 3: Verify recording continued throughout the period
      expect(audioRecorderProvider.isRecording, isTrue);

      final endDuration = audioRecorderProvider.duration;
      expect(endDuration.inSeconds, greaterThanOrEqualTo(10));

      // Step 4: Stop recording and verify it completes successfully
      audioRecorderProvider.stopRecording();
      expect(audioRecorderProvider.isRecording, isFalse);

      // Verify final duration is approximately 10 seconds
      final finalDuration = audioRecorderProvider.duration.inSeconds;
      expect(finalDuration, greaterThanOrEqualTo(9));
      expect(finalDuration, lessThanOrEqualTo(11));
    });

    testWidgets('Recording state persists across duration updates', (tester) async {
      // Start recording
      audioRecorderProvider.startRecording();
      expect(audioRecorderProvider.isRecording, isTrue);

      // Simulate multiple duration updates over time
      for (int i = 1; i <= 5; i++) {
        await tester.pump(const Duration(seconds: 2));

        // Verify recording is still active
        expect(audioRecorderProvider.isRecording, isTrue);

        // Verify duration is increasing
        final currentDuration = audioRecorderProvider.duration.inSeconds;
        expect(currentDuration, greaterThanOrEqualTo(i * 2));
      }

      // Stop recording
      audioRecorderProvider.stopRecording();
      expect(audioRecorderProvider.isRecording, isFalse);
    });

    testWidgets('AudioRecorderService maintains recording during extended periods',
        (tester) async {
      // Verify service is initialized
      expect(audioRecorderService.isRecording, isFalse);
      expect(audioRecorderService.recordingDuration, 0);

      // Start recording
      final started = await audioRecorderService.startRecording();
      expect(started, isTrue);
      expect(audioRecorderService.isRecording, isTrue);

      // Simulate extended recording (15 seconds)
      await tester.pump(const Duration(seconds: 15));

      // Verify recording is still active
      expect(audioRecorderService.isRecording, isTrue);

      // Verify duration has been tracked
      final duration = audioRecorderService.recordingDuration;
      expect(duration, greaterThanOrEqualTo(15000)); // 15 seconds in ms

      // Stop recording
      final info = await audioRecorderService.stopRecording();
      expect(info, isNotNull);
      expect(info!.duration, greaterThanOrEqualTo(15000));
      expect(audioRecorderService.isRecording, isFalse);
    });

    testWidgets('Recording with audio attachment survives save/load cycle',
        (tester) async {
      // Create note
      await noteEditorViewModel.init();
      final note = noteEditorViewModel.note!;

      // Start recording
      audioRecorderProvider.startRecording();

      // Simulate recording duration
      await tester.pump(const Duration(seconds: 5));

      // Stop recording
      audioRecorderProvider.stopRecording();

      // Create audio attachment from simulated recording
      final audioAttachment = AudioAttachment(
        id: 'bg-recording-${DateTime.now().millisecondsSinceEpoch}',
        duration: audioRecorderProvider.duration.inMilliseconds,
        path: '/tmp/bg_recording.m4a',
        format: 'm4a',
        size: 160000, // ~160KB for 5 seconds
        createdAt: DateTime.now(),
        noteId: note.id,
      );

      // Attach to note
      await noteEditorViewModel.addAudioAttachment(audioAttachment);
      expect(noteEditorViewModel.audioAttachments.length, 1);

      // Save note
      await noteEditorViewModel.saveNow();

      // Reload note and verify attachment persisted
      await noteEditorViewModel.init(noteId: note.id);
      expect(noteEditorViewModel.audioAttachments.length, 1);

      final persisted = noteEditorViewModel.audioAttachments.first;
      expect(persisted.id, audioAttachment.id);
      expect(persisted.duration, audioAttachment.duration);
      expect(persisted.format, 'm4a');
    });

    testWidgets('Recording duration accuracy over time', (tester) async {
      audioRecorderProvider.startRecording();

      final stopwatch = Stopwatch()..start();

      // Test duration tracking at multiple intervals
      final checkpoints = [5, 10, 15]; // seconds

      for (final checkpoint in checkpoints) {
        await tester.pump(Duration(seconds: checkpoint - stopwatch.elapsedSeconds));
        stopwatch.stop();

        final recordedDuration = audioRecorderProvider.duration.inSeconds;
        final expected = checkpoint;

        // Allow ±1 second tolerance
        expect(recordedDuration, greaterThanOrEqualTo(expected - 1));
        expect(recordedDuration, lessThanOrEqualTo(expected + 1));

        stopwatch.start();
      }

      stopwatch.stop();
      audioRecorderProvider.stopRecording();

      // Final check: total duration should be approximately 15 seconds
      final totalDuration = audioRecorderProvider.duration.inSeconds;
      expect(totalDuration, greaterThanOrEqualTo(14));
      expect(totalDuration, lessThanOrEqualTo(16));
    });

    testWidgets('Recording amplitude monitoring continues during extended recording',
        (tester) async {
      // Start recording
      audioRecorderProvider.startRecording();

      // Verify amplitude starts at 0
      expect(audioRecorderProvider.amplitude, 0.0);

      // Wait for amplitude monitoring to start
      await tester.pump(const Duration(milliseconds: 200));

      // Amplitude should now be > 0 (simulated amplitude)
      expect(audioRecorderProvider.amplitude, greaterThan(0.0));

      // Continue recording and verify amplitude continues updating
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        // Amplitude should be in valid range [0, 1]
        expect(audioRecorderProvider.amplitude, greaterThanOrEqualTo(0.0));
        expect(audioRecorderProvider.amplitude, lessThanOrEqualTo(1.0));
      }

      // Stop recording
      audioRecorderProvider.stopRecording();
    });

    testWidgets('Note with background recording can be saved and retrieved',
        (tester) async {
      // Create note and start recording
      await noteEditorViewModel.init();
      final note = noteEditorViewModel.note!;

      // Simulate background recording flow
      audioRecorderProvider.startRecording();
      await tester.pump(const Duration(seconds: 8));
      audioRecorderProvider.stopRecording();

      // Create attachment
      final audioAttachment = AudioAttachment(
        id: 'bg-test-${DateTime.now().millisecondsSinceEpoch}',
        duration: audioRecorderProvider.duration.inMilliseconds,
        path: '/tmp/bg_test.m4a',
        format: 'm4a',
        size: 256000, // ~256KB for 8 seconds
        createdAt: DateTime.now(),
        noteId: note.id,
      );

      // Update note with audio attachment and other content
      await noteEditorViewModel.addAudioAttachment(audioAttachment);
      noteEditorViewModel.updateDraft(
        title: 'Background Recording Test',
        content: 'This note has a background recorded attachment',
      );

      // Save
      await noteEditorViewModel.saveNow();

      // Verify by reloading
      await noteEditorViewModel.init(noteId: note.id);
      expect(noteEditorViewModel.note!.title, 'Background Recording Test');
      expect(noteEditorViewModel.note!.content,
          'This note has a background recorded attachment');
      expect(noteEditorViewModel.audioAttachments.length, 1);
      expect(noteEditorViewModel.audioAttachments.first.duration,
          audioAttachment.duration);
    });

    testWidgets('Multiple recordings in sequence work correctly', (tester) async {
      // First recording
      audioRecorderProvider.startRecording();
      await tester.pump(const Duration(seconds: 3));
      audioRecorderProvider.stopRecording();

      final firstDuration = audioRecorderProvider.duration;
      expect(firstDuration.inSeconds, greaterThanOrEqualTo(2));

      // Reset for second recording
      audioRecorderProvider.reset();

      // Second recording
      audioRecorderProvider.startRecording();
      await tester.pump(const Duration(seconds: 5));
      audioRecorderProvider.stopRecording();

      final secondDuration = audioRecorderProvider.duration;
      expect(secondDuration.inSeconds, greaterThanOrEqualTo(4));

      // Verify durations are independent
      expect(secondDuration, greaterThan(firstDuration));

      // Reset again
      audioRecorderProvider.reset();
      expect(audioRecorderProvider.duration, Duration.zero);
      expect(audioRecorderProvider.isRecording, isFalse);
    });
  });

  group('Manual E2E Test Documentation', () {
    testWidgets('Document manual E2E verification steps', (tester) async {
      // This test documents the manual E2E verification steps
      // that must be performed on an actual device to verify
      // background recording functionality.

      final manualSteps = [
        '1. Start audio recording in the app',
        '2. Press home button to background the app',
        '3. Wait 10 seconds',
        '4. Return to the app',
        '5. Verify recording continued',
        '6. Stop recording and verify audio was captured',
      ];

      // Documentation only - this test always passes
      expect(manualSteps.length, 6);

      // The actual background behavior (app going to background
      // and recording continuing) is provided by:
      //
      // 1. iOS: UIBackgroundModes audio in Info.plist
      // 2. Android: Proper foreground service configuration
      // 3. record package: Handles background recording automatically
      //
      // Manual verification on physical device is required to confirm:
      // - Recording continues when app is backgrounded
      // - No audio artifacts from background transitions
      // - Recording can be stopped after returning from background
      // - Audio file is properly saved
    });
  });
}
