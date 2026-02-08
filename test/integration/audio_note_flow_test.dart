import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/entities/audio_attachment.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/audio_player_provider.dart';
import 'package:noteable_app/presentation/providers/audio_recorder_provider.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';
import 'package:noteable_app/services/audio/audio_player_service.dart';
import 'package:noteable_app/services/audio/audio_recorder_service.dart';
import 'package:noteable_app/services/storage/isar_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryNotesFeatureRepository notesRepo;
  late IsarService isarService;
  late NoteEditorViewModel noteEditorViewModel;
  late AudioRecorderProvider audioRecorderProvider;
  late AudioPlayerProvider audioPlayerProvider;

  setUp(() async {
    // Initialize services
    notesRepo = InMemoryNotesFeatureRepository();
    isarService = IsarService();
    await isarService.init();

    // Initialize audio services
    final audioRecorderService = AudioRecorderService();
    final audioPlayerService = AudioPlayerService();
    await audioRecorderService.init();
    await audioPlayerService.init();

    // Create providers
    noteEditorViewModel = NoteEditorViewModel(
      createNote: CreateNoteUseCase(notesRepo),
      updateNote: UpdateNoteUseCase(notesRepo),
      getNotes: GetNotesUseCase(notesRepo),
      audioRepository: notesRepo,
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

  testWidgets('Complete audio note flow: create note, attach audio, verify playback integration',
      (tester) async {
    // Step 1: Create a new note
    await noteEditorViewModel.init();
    expect(noteEditorViewModel.hasNote, isTrue);
    final note = noteEditorViewModel.note!;
    expect(note.audioAttachments, isEmpty);

    // Step 2: Simulate recording state changes
    expect(audioRecorderProvider.isRecording, isFalse);
    expect(audioRecorderProvider.duration, Duration.zero);

    audioRecorderProvider.startRecording();
    expect(audioRecorderProvider.isRecording, isTrue);

    // Simulate recording duration
    await tester.pump(const Duration(seconds: 1));
    expect(audioRecorderProvider.duration.inSeconds, greaterThanOrEqualTo(1));

    // Step 3: Stop recording
    audioRecorderProvider.stopRecording();
    expect(audioRecorderProvider.isRecording, isFalse);

    // Step 4: Create a simulated audio attachment
    // In a real scenario, this would come from AudioRecorderService.stopRecording()
    final now = DateTime.now();
    final audioAttachment = AudioAttachment(
      id: 'test-audio-${now.millisecondsSinceEpoch}',
      duration: 5000, // 5 seconds in milliseconds
      path: '/tmp/test_audio.m4a',
      format: 'm4a',
      size: 128000, // 128 KB
      createdAt: now,
      noteId: note.id,
    );

    // Step 5: Attach audio to note
    await noteEditorViewModel.addAudioAttachment(audioAttachment);

    // Verify attachment is in the view model
    expect(noteEditorViewModel.audioAttachments.length, 1);
    expect(noteEditorViewModel.audioAttachments.first.id, audioAttachment.id);
    expect(noteEditorViewModel.audioAttachments.first.duration, 5000);

    // Step 6: Save note with attachment
    await noteEditorViewModel.saveNow();

    // Step 7: Verify attachment persists by reloading the note
    await noteEditorViewModel.init(noteId: note.id);
    expect(noteEditorViewModel.audioAttachments.length, 1);
    final persistedAttachment = noteEditorViewModel.audioAttachments.first;
    expect(persistedAttachment.id, audioAttachment.id);
    expect(persistedAttachment.format, 'm4a');
    expect(persistedAttachment.duration, 5000);

    // Step 8: Verify audio player provider can load the attachment
    expect(audioPlayerProvider.hasAudio, isFalse);
    expect(audioPlayerProvider.isPlaying, isFalse);

    // Note: In a real device test, we would load and play the actual audio file
    // For integration testing, we verify the provider state management
    audioPlayerProvider.reset();
    expect(audioPlayerProvider.hasAudio, isFalse);
    expect(audioPlayerProvider.position, Duration.zero);
  });

  testWidgets('Audio attachment removal flow', (tester) async {
    // Create note with audio attachment
    await noteEditorViewModel.init();
    final note = noteEditorViewModel.note!;

    final audioAttachment = AudioAttachment(
      id: 'test-audio-removal',
      duration: 3000,
      path: '/tmp/test_audio_removal.m4a',
      format: 'm4a',
      size: 96000,
      createdAt: DateTime.now(),
      noteId: note.id,
    );

    await noteEditorViewModel.addAudioAttachment(audioAttachment);
    expect(noteEditorViewModel.audioAttachments.length, 1);

    // Remove attachment
    await noteEditorViewModel.removeAudioAttachment(audioAttachment.id);
    expect(noteEditorViewModel.audioAttachments.length, 0);

    // Save and verify persistence
    await noteEditorViewModel.saveNow();
    await noteEditorViewModel.init(noteId: note.id);
    expect(noteEditorViewModel.audioAttachments.length, 0);
  });

  testWidgets('Multiple audio attachments per note', (tester) async {
    // Create note
    await noteEditorViewModel.init();
    final note = noteEditorViewModel.note!;

    // Add multiple attachments
    final attachment1 = AudioAttachment(
      id: 'audio-1',
      duration: 2000,
      path: '/tmp/audio1.m4a',
      format: 'm4a',
      size: 64000,
      createdAt: DateTime.now(),
      noteId: note.id,
    );

    final attachment2 = AudioAttachment(
      id: 'audio-2',
      duration: 4000,
      path: '/tmp/audio2.m4a',
      format: 'm4a',
      size: 128000,
      createdAt: DateTime.now().add(const Duration(seconds: 1)),
      noteId: note.id,
    );

    await noteEditorViewModel.addAudioAttachment(attachment1);
    await noteEditorViewModel.addAudioAttachment(attachment2);

    expect(noteEditorViewModel.audioAttachments.length, 2);

    // Save and verify order is maintained
    await noteEditorViewModel.saveNow();
    await noteEditorViewModel.init(noteId: note.id);

    expect(noteEditorViewModel.audioAttachments.length, 2);
    expect(noteEditorViewModel.audioAttachments[0].id, 'audio-1');
    expect(noteEditorViewModel.audioAttachments[1].id, 'audio-2');
  });

  testWidgets('AudioRecorderProvider state management', (tester) async {
    // Test initial state
    expect(audioRecorderProvider.isRecording, isFalse);
    expect(audioRecorderProvider.duration, Duration.zero);
    expect(audioRecorderProvider.amplitude, 0.0);

    // Test start recording
    audioRecorderProvider.startRecording();
    expect(audioRecorderProvider.isRecording, isTrue);
    expect(audioRecorderProvider.duration, Duration.zero);

    // Wait for duration to update
    await tester.pump(const Duration(seconds: 2));
    expect(audioRecorderProvider.duration.inSeconds, greaterThanOrEqualTo(2));

    // Test amplitude changes
    expect(audioRecorderProvider.amplitude, greaterThan(0.0));

    // Test stop recording
    audioRecorderProvider.stopRecording();
    expect(audioRecorderProvider.isRecording, isFalse);

    // Test reset
    audioRecorderProvider.reset();
    expect(audioRecorderProvider.isRecording, isFalse);
    expect(audioRecorderProvider.duration, Duration.zero);
    expect(audioRecorderProvider.amplitude, 0.0);
  });

  testWidgets('AudioPlayerProvider state management', (tester) async {
    // Test initial state
    expect(audioPlayerProvider.isPlaying, isFalse);
    expect(audioPlayerProvider.hasAudio, isFalse);
    expect(audioPlayerProvider.position, Duration.zero);
    expect(audioPlayerProvider.duration, isNull);
    expect(audioPlayerProvider.playerState, 'idle');

    // Test reset
    audioPlayerProvider.reset();
    expect(audioPlayerProvider.hasAudio, isFalse);
    expect(audioPlayerProvider.position, Duration.zero);
    expect(audioPlayerProvider.duration, isNull);
  });

  testWidgets('Note updates preserve audio attachments', (tester) async {
    // Create note with audio attachment
    await noteEditorViewModel.init();
    final note = noteEditorViewModel.note!;

    final audioAttachment = AudioAttachment(
      id: 'test-preserve',
      duration: 3000,
      path: '/tmp/test_preserve.m4a',
      format: 'm4a',
      size: 96000,
      createdAt: DateTime.now(),
      noteId: note.id,
    );

    await noteEditorViewModel.addAudioAttachment(audioAttachment);
    await noteEditorViewModel.saveNow();

    // Update note title/content
    noteEditorViewModel.updateDraft(title: 'Updated Title', content: 'Updated Content');
    await noteEditorViewModel.saveNow();

    // Reload and verify attachment is preserved
    await noteEditorViewModel.init(noteId: note.id);
    expect(noteEditorViewModel.note!.title, 'Updated Title');
    expect(noteEditorViewModel.note!.content, 'Updated Content');
    expect(noteEditorViewModel.audioAttachments.length, 1);
    expect(noteEditorViewModel.audioAttachments.first.id, 'test-preserve');
  });

  testWidgets('Recording timer accuracy', (tester) async {
    audioRecorderProvider.startRecording();

    // Record for exactly 5 seconds
    final stopwatch = Stopwatch()..start();
    await tester.pump(const Duration(seconds: 5));
    stopwatch.stop();

    audioRecorderProvider.stopRecording();

    // Verify recorded duration is approximately 5 seconds (±1 second tolerance)
    final recordedDuration = audioRecorderProvider.duration.inSeconds;
    expect(recordedDuration, greaterThanOrEqualTo(4));
    expect(recordedDuration, lessThanOrEqualTo(6));
  });

  testWidgets('Concurrent note editing with audio attachment', (tester) async {
    // Create note
    await noteEditorViewModel.init();
    final note = noteEditorViewModel.note!;

    // Simulate rapid edits
    noteEditorViewModel.updateDraft(title: 'Title 1');
    await tester.pump(const Duration(milliseconds: 100));

    noteEditorViewModel.updateDraft(title: 'Title 2');
    await tester.pump(const Duration(milliseconds: 100));

    // Add audio attachment
    final audioAttachment = AudioAttachment(
      id: 'concurrent-test',
      duration: 2000,
      path: '/tmp/concurrent.m4a',
      format: 'm4a',
      size: 64000,
      createdAt: DateTime.now(),
      noteId: note.id,
    );
    await noteEditorViewModel.addAudioAttachment(audioAttachment);

    // Final edit
    noteEditorViewModel.updateDraft(title: 'Final Title');
    await tester.pump(const Duration(milliseconds: 800)); // Wait for auto-save

    // Verify all changes persisted
    await noteEditorViewModel.init(noteId: note.id);
    expect(noteEditorViewModel.note!.title, 'Final Title');
    expect(noteEditorViewModel.audioAttachments.length, 1);
    expect(noteEditorViewModel.audioAttachments.first.id, 'concurrent-test');
  });
}
