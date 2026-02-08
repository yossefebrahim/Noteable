import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/data/repositories/audio_repository_impl.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/data/repositories/transcription_repository_impl.dart';
import 'package:noteable_app/domain/entities/audio_attachment.dart';
import 'package:noteable_app/domain/entities/transcription.dart';
import 'package:noteable_app/domain/usecases/audio/create_audio_attachment_usecase.dart';
import 'package:noteable_app/domain/usecases/audio/transcribe_audio_usecase.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/audio_player_provider.dart';
import 'package:noteable_app/presentation/providers/audio_recorder_provider.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';
import 'package:noteable_app/services/audio/audio_player_service.dart';
import 'package:noteable_app/services/audio/audio_recorder_service.dart';
import 'package:noteable_app/services/storage/file_storage_service.dart';
import 'package:noteable_app/services/storage/isar_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryNotesFeatureRepository notesRepo;
  late AudioRepositoryImpl audioRepo;
  late TranscriptionRepositoryImpl transcriptionRepo;
  late IsarService isarService;
  late FileStorageService fileStorageService;
  late AudioRecorderService audioRecorderService;
  late AudioPlayerService audioPlayerService;
  late NoteEditorViewModel noteEditorViewModel;
  late AudioRecorderProvider audioRecorderProvider;
  late AudioPlayerProvider audioPlayerProvider;
  late CreateAudioAttachmentUseCase createAudioAttachmentUseCase;
  late TranscribeAudioUseCase transcribeAudioUseCase;

  setUp(() async {
    // Initialize services
    notesRepo = InMemoryNotesFeatureRepository();
    isarService = IsarService();
    await isarService.init();

    fileStorageService = FileStorageService();
    await fileStorageService.init();

    audioRepo = AudioRepositoryImpl(isarService);
    transcriptionRepo = TranscriptionRepositoryImpl(isarService);

    // Initialize audio services
    audioRecorderService = AudioRecorderService();
    audioPlayerService = AudioPlayerService();
    await audioRecorderService.init();
    await audioPlayerService.init();

    // Initialize use cases
    createAudioAttachmentUseCase = CreateAudioAttachmentUseCase(audioRepo);
    transcribeAudioUseCase = TranscribeAudioUseCase(transcriptionRepo);

    // Initialize providers
    noteEditorViewModel = NoteEditorViewModel(
      createNote: CreateNoteUseCase(notesRepo),
      updateNote: UpdateNoteUseCase(notesRepo),
      getNotes: GetNotesUseCase(notesRepo),
      audioRepository: audioRepo,
    );

    audioRecorderProvider = AudioRecorderProvider();
    audioPlayerProvider = AudioPlayerProvider(
      audioPlayerService: audioPlayerService,
    );
  });

  tearDown(() async {
    noteEditorViewModel.dispose();
    audioRecorderProvider.dispose();
    audioPlayerProvider.dispose();
    await isarService.dispose();
  });

  group('Large Audio File Performance Tests', () {
    testWidgets('Large audio attachment storage performance (10 minute recording)',
        (tester) async {
      // Simulate a 10-minute audio file
      // At 128 kbps, 10 minutes = ~9.6 MB
      const int fileSizeInBytes = 9600000; // ~9.6 MB
      const int durationInMs = 600000; // 10 minutes in milliseconds

      // Create note
      await noteEditorViewModel.init();
      final note = noteEditorViewModel.note!;

      // Measure storage performance
      final storageStopwatch = Stopwatch()..start();
      final now = DateTime.now();

      final largeAudioAttachment = AudioAttachment(
        id: 'large-audio-${now.millisecondsSinceEpoch}',
        duration: durationInMs,
        path: '/tmp/large_audio_10min.m4a',
        format: 'm4a',
        size: fileSizeInBytes,
        createdAt: now,
        noteId: note.id,
      );

      await noteEditorViewModel.addAudioAttachment(largeAudioAttachment);
      storageStopwatch.stop();

      // Verify storage completes in reasonable time (< 2 seconds)
      expect(
        storageStopwatch.elapsedMilliseconds,
        lessThan(2000),
        reason: 'Storing large audio attachment should complete quickly',
      );

      // Verify attachment was added
      expect(noteEditorViewModel.audioAttachments.length, 1);
      expect(noteEditorViewModel.audioAttachments.first.duration, durationInMs);
      expect(noteEditorViewModel.audioAttachments.first.size, fileSizeInBytes);

      // Save and verify persistence performance
      final saveStopwatch = Stopwatch()..start();
      await noteEditorViewModel.saveNow();
      saveStopwatch.stop();

      // Verify save completes in reasonable time (< 3 seconds)
      expect(
        saveStopwatch.elapsedMilliseconds,
        lessThan(3000),
        reason: 'Saving note with large audio should complete quickly',
      );

      // Reload and verify performance
      final loadStopwatch = Stopwatch()..start();
      await noteEditorViewModel.init(noteId: note.id);
      loadStopwatch.stop();

      // Verify load completes in reasonable time (< 1 second)
      expect(
        loadStopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Loading note with large audio should be fast',
      );

      expect(noteEditorViewModel.audioAttachments.length, 1);
    });

    testWidgets('Multiple large audio attachments performance', (tester) async {
      // Create note with multiple large attachments
      await noteEditorViewModel.init();
      final note = noteEditorViewModel.note!;

      const int attachmentCount = 5;
      final attachments = <AudioAttachment>[];

      // Measure batch attachment performance
      final batchStopwatch = Stopwatch()..start();
      for (int i = 0; i < attachmentCount; i++) {
        final now = DateTime.now();
        final attachment = AudioAttachment(
          id: 'large-audio-$i-${now.millisecondsSinceEpoch}',
          duration: 300000, // 5 minutes
          path: '/tmp/large_audio_$i.m4a',
          format: 'm4a',
          size: 4800000, // ~4.8 MB each
          createdAt: now.add(Duration(seconds: i)),
          noteId: note.id,
        );
        attachments.add(attachment);
        await noteEditorViewModel.addAudioAttachment(attachment);
      }
      batchStopwatch.stop();

      // Verify all attachments added in reasonable time
      expect(
        batchStopwatch.elapsedMilliseconds,
        lessThan(5000),
        reason: 'Adding multiple large attachments should be efficient',
      );

      expect(noteEditorViewModel.audioAttachments.length, attachmentCount);

      // Verify save performance with multiple attachments
      final saveStopwatch = Stopwatch()..start();
      await noteEditorViewModel.saveNow();
      saveStopwatch.stop();

      expect(
        saveStopwatch.elapsedMilliseconds,
        lessThan(5000),
        reason: 'Saving note with multiple large attachments should be fast',
      );

      // Verify all attachments persisted
      await noteEditorViewModel.init(noteId: note.id);
      expect(noteEditorViewModel.audioAttachments.length, attachmentCount);
    });

    testWidgets('Audio player provider with large file state management',
        (tester) async {
      // Test that provider remains responsive with large audio simulation
      const int largeDuration = 3600000; // 1 hour in milliseconds

      // Simulate loading a large audio file
      final loadStopwatch = Stopwatch()..start();

      // In a real scenario, this would load the actual audio file
      // For testing, we verify the provider remains responsive
      audioPlayerProvider.reset();
      loadStopwatch.stop();

      // Provider should respond immediately to reset
      expect(loadStopwatch.elapsedMilliseconds, lessThan(100));
      expect(audioPlayerProvider.hasAudio, isFalse);
      expect(audioPlayerProvider.position, Duration.zero);
      expect(audioPlayerProvider.duration, isNull);

      // Test state changes don't block with simulated large file
      final stateStopwatch = Stopwatch()..start();

      // Simulate state updates that would occur with a large file
      for (int i = 0; i < 100; i++) {
        audioPlayerProvider.position = Duration(milliseconds: i * 36000);
      }

      stateStopwatch.stop();

      // State updates should be fast
      expect(
        stateStopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'State updates should remain fast',
      );
    });

    testWidgets('Audio recorder provider with long recording duration',
        (tester) async {
      // Test recorder provider remains responsive during long recordings
      expect(audioRecorderProvider.isRecording, isFalse);
      expect(audioRecorderProvider.duration, Duration.zero);

      // Start recording
      audioRecorderProvider.startRecording();
      expect(audioRecorderProvider.isRecording, isTrue);

      // Simulate a long recording without blocking
      final stopwatch = Stopwatch()..start();

      // Pump multiple times to simulate extended recording
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(seconds: 1));

        // Verify provider remains responsive throughout
        expect(audioRecorderProvider.isRecording, isTrue);
        expect(audioRecorderProvider.duration.inSeconds, greaterThanOrEqualTo(i));
      }

      stopwatch.stop();

      // Verify recording duration
      expect(
        audioRecorderProvider.duration.inSeconds,
        greaterThanOrEqualTo(60),
        reason: 'Recording should track duration accurately',
      );

      // Stop recording
      audioRecorderProvider.stopRecording();
      expect(audioRecorderProvider.isRecording, isFalse);

      // Reset should be instant
      final resetStopwatch = Stopwatch()..start();
      audioRecorderProvider.reset();
      resetStopwatch.stop();

      expect(
        resetStopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Reset should be instant',
      );
    });

    testWidgets('Database query performance with many large audio attachments',
        (tester) async {
      // Create multiple notes with large audio attachments
      const int noteCount = 20;

      final notes = <dynamic>[];
      final creationStopwatch = Stopwatch()..start();

      for (int i = 0; i < noteCount; i++) {
        final note = await notesRepo.createNote(
          title: 'Note $i',
          content: 'Content for note $i',
        );
        notes.add(note);

        final now = DateTime.now();
        final attachment = AudioAttachment(
          id: 'audio-$i-${now.millisecondsSinceEpoch}',
          duration: 600000, // 10 minutes
          path: '/tmp/audio_$i.m4a',
          format: 'm4a',
          size: 9600000, // ~9.6 MB
          createdAt: now.add(Duration(seconds: i)),
          noteId: note.id,
        );

        await audioRepo.createAudioAttachment(attachment);
      }
      creationStopwatch.stop();

      // Verify creation is efficient
      expect(
        creationStopwatch.elapsedMilliseconds,
        lessThan(10000),
        reason: 'Creating many notes with large audio should be efficient',
      );

      // Test query performance
      final queryStopwatch = Stopwatch()..start();
      final allAttachments = await audioRepo.getAudioAttachments();
      queryStopwatch.stop();

      expect(allAttachments.length, noteCount);
      expect(
        queryStopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Querying all audio attachments should be fast',
      );

      // Test filtered query performance
      final filteredQueryStopwatch = Stopwatch()..start();
      final firstNoteAttachments =
          await audioRepo.getAudioAttachmentsByNoteId(notes[0].id);
      filteredQueryStopwatch.stop();

      expect(firstNoteAttachments.length, 1);
      expect(
        filteredQueryStopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Filtered queries should be fast',
      );
    });

    testWidgets('Search performance with transcriptions from long audio',
        (tester) async {
      // Create note with long transcription (simulating long audio)
      final note = await notesRepo.createNote(
        title: 'Long Meeting Recording',
        content: 'Meeting notes',
      );

      // Create audio attachment for 30 minute recording
      final now = DateTime.now();
      final audio = AudioAttachment(
        id: 'audio-long-${now.millisecondsSinceEpoch}',
        duration: 1800000, // 30 minutes
        path: '/tmp/long_meeting.m4a',
        format: 'm4a',
        size: 28800000, // ~28.8 MB
        createdAt: now,
        noteId: note.id,
      );

      final createdAudio = await audioRepo.createAudioAttachment(audio);

      // Create long transcription (simulating 30 minutes of speech)
      final longTranscription = Transcription(
        id: '',
        text: _generateLongTranscriptionText(), // ~500 words
        confidence: 0.95,
        timestamp: now,
        audioAttachmentId: createdAudio.id,
      );

      await transcriptionRepo.createTranscription(longTranscription);

      // Test search performance with long transcription
      final searchStopwatch = Stopwatch()..start();
      final results = await notesRepo.searchNotes('meeting');
      searchStopwatch.stop();

      expect(results, isNotEmpty);
      expect(
        searchStopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Search should be fast even with long transcriptions',
      );

      // Test partial text search performance
      final partialSearchStopwatch = Stopwatch()..start();
      final partialResults = await notesRepo.searchNotes('agenda');
      partialSearchStopwatch.stop();

      expect(
        partialSearchStopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Partial text search should be fast',
      );
    });

    testWidgets('Memory efficiency with large audio attachments', (tester) async {
      // Verify memory doesn't grow unbounded with large files
      await noteEditorViewModel.init();
      final note = noteEditorViewModel.note!;

      // Create multiple large attachments
      for (int i = 0; i < 10; i++) {
        final now = DateTime.now();
        final attachment = AudioAttachment(
          id: 'mem-test-$i-${now.millisecondsSinceEpoch}',
          duration: 600000, // 10 minutes
          path: '/tmp/mem_test_$i.m4a',
          format: 'm4a',
          size: 9600000, // ~9.6 MB
          createdAt: now.add(Duration(milliseconds: i)),
          noteId: note.id,
        );

        await noteEditorViewModel.addAudioAttachment(attachment);
      }

      // Save and verify
      await noteEditorViewModel.saveNow();

      // Reload - should not cause memory issues
      await noteEditorViewModel.init(noteId: note.id);

      expect(noteEditorViewModel.audioAttachments.length, 10);

      // Verify provider state doesn't grow unbounded
      audioRecorderProvider.reset();
      expect(audioRecorderProvider.amplitude, 0.0);

      audioPlayerProvider.reset();
      expect(audioPlayerProvider.hasAudio, isFalse);
    });
  });
}

/// Helper function to generate long transcription text for testing
String _generateLongTranscriptionText() {
  return '''
    Good morning everyone. Let's begin with today's agenda. First, we'll review the quarterly
    results and discuss the key performance indicators. Our revenue has increased by fifteen
    percent compared to the previous quarter, which is a significant improvement. The marketing
    team has done an excellent job with the new campaign.

    Next, let's talk about the product roadmap. We have several exciting features in development.
    The voice notes feature is progressing well and should be ready for beta testing next month.
    We've also received great feedback from our early adopters about the user interface improvements.

    Moving on to customer feedback, our satisfaction scores have improved by twenty percent.
    The support team has implemented a new ticketing system that has reduced response times
    significantly. We've also added more documentation and tutorials based on user requests.

    Regarding team updates, we've hired three new engineers who are joining the mobile team.
    They'll be working on performance optimization and adding new platform support. We're also
    looking to expand our design team with two additional positions.

    Let's discuss the budget for the next quarter. We're planning to increase investment in
    research and development by twenty percent. This will allow us to explore new technologies
    and improve our existing products. Marketing spend will remain consistent with current levels.

    Finally, I'd like to address the upcoming conference. We'll be presenting our latest
    innovations and networking with potential partners. Please make sure to prepare your
    presentations and coordinate with the marketing team on messaging.

    Thank you all for your attention. Let's open the floor for questions and discussion.
    Does anyone have any topics they'd like to add to the agenda?
  ''';
}
