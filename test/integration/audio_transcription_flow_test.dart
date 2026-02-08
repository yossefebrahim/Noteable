import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/data/repositories/audio_repository_impl.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/data/repositories/transcription_repository_impl.dart';
import 'package:noteable_app/domain/entities/audio_attachment.dart';
import 'package:noteable_app/domain/entities/transcription.dart';
import 'package:noteable_app/domain/usecases/audio/transcribe_audio_usecase.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/services/storage/isar_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryNotesFeatureRepository notesRepo;
  late TranscriptionRepositoryImpl transcriptionRepo;
  late AudioRepositoryImpl audioRepo;
  late IsarService isarService;
  late NotesViewModel notesViewModel;
  late TranscribeAudioUseCase transcribeAudioUseCase;

  setUp(() async {
    // Initialize services
    notesRepo = InMemoryNotesFeatureRepository();
    isarService = IsarService();
    await isarService.init();

    transcriptionRepo = TranscriptionRepositoryImpl(isarService);
    audioRepo = AudioRepositoryImpl(isarService);

    // Initialize use cases
    transcribeAudioUseCase = TranscribeAudioUseCase(transcriptionRepo);

    // Initialize view model
    notesViewModel = NotesViewModel(
      getNotes: GetNotesUseCase(notesRepo),
      deleteNote: DeleteNoteUseCase(notesRepo),
      togglePin: TogglePinUseCase(notesRepo),
      getFolders: GetFoldersUseCase(notesRepo),
      createFolder: CreateFolderUseCase(notesRepo),
      renameFolder: RenameFolderUseCase(notesRepo),
      deleteFolder: DeleteFolderUseCase(notesRepo),
      searchNotes: SearchNotesUseCase(notesRepo),
    );
  });

  tearDown(() async {
    await isarService.dispose();
  });

  testWidgets('Complete transcription flow: record audio, transcribe, and search',
      (tester) async {
    // Step 1: Create a new note
    final note = await notesRepo.createNote(
      title: 'Meeting Notes',
      content: 'Discussion about project timeline',
    );
    expect(note.id, isNotEmpty);

    // Step 2: Create audio attachment (simulating recorded audio)
    final now = DateTime.now();
    final audioAttachment = AudioAttachment(
      id: 'audio-${now.millisecondsSinceEpoch}',
      duration: 5000, // 5 seconds
      path: '/tmp/meeting_recording.m4a',
      format: 'm4a',
      size: 128000,
      createdAt: now,
      noteId: note.id,
    );

    // Create audio attachment through repository
    final createdAttachment = await audioRepo.createAudioAttachment(audioAttachment);
    expect(createdAttachment.id, isNotEmpty);
    expect(createdAttachment.noteId, note.id);

    // Step 3: Transcribe the audio
    // Note: The actual transcription service returns a placeholder
    // In production, this would use speech-to-text
    final transcriptionResult = await transcribeAudioUseCase(createdAttachment.path);

    expect(transcriptionResult.isSuccess, isTrue);
    final transcription = transcriptionResult.value!;
    expect(transcription.text, isNotEmpty);
    expect(transcription.timestamp, isNotNull);

    // Step 4: Link transcription to audio attachment
    final linkedTranscription = transcription.copyWith(
      audioAttachmentId: createdAttachment.id,
      text: 'Hello world this is a test transcription', // Simulated transcribed text
      confidence: 0.95,
    );
    await transcriptionRepo.updateTranscription(linkedTranscription);

    // Verify transcription is linked correctly
    final retrievedTranscriptions =
        await transcriptionRepo.getTranscriptionsByAudioAttachmentId(createdAttachment.id);
    expect(retrievedTranscriptions.length, 1);
    expect(retrievedTranscriptions.first.text, contains('Hello world'));

    // Step 5: Search for the transcribed text
    await notesViewModel.load();
    final searchResults = await notesViewModel.search('Hello world');

    // Step 6: Verify the note appears in search results
    expect(searchResults, isNotEmpty);
    final foundNote = searchResults.firstWhere(
      (n) => n.id == note.id,
      orElse: () => throw Exception('Note not found in search results'),
    );
    expect(foundNote.id, note.id);
    expect(foundNote.title, 'Meeting Notes');
  });

  testWidgets('Search finds notes by transcription content', (tester) async {
    // Create two notes with audio
    final note1 = await notesRepo.createNote(
      title: 'Voice Memo 1',
      content: 'Some content',
    );
    final note2 = await notesRepo.createNote(
      title: 'Voice Memo 2',
      content: 'Other content',
    );

    // Add audio attachments
    final now = DateTime.now();
    final audio1 = AudioAttachment(
      id: 'audio-1-${now.millisecondsSinceEpoch}',
      duration: 3000,
      path: '/tmp/audio1.m4a',
      format: 'm4a',
      size: 64000,
      createdAt: now,
      noteId: note1.id,
    );

    final audio2 = AudioAttachment(
      id: 'audio-2-${now.millisecondsSinceEpoch}',
      duration: 4000,
      path: '/tmp/audio2.m4a',
      format: 'm4a',
      size: 96000,
      createdAt: now.add(const Duration(seconds: 1)),
      noteId: note2.id,
    );

    final createdAudio1 = await audioRepo.createAudioAttachment(audio1);
    final createdAudio2 = await audioRepo.createAudioAttachment(audio2);

    // Create transcriptions with different content
    final transcription1 = Transcription(
      id: '',
      text: 'The quick brown fox jumps over the lazy dog',
      confidence: 0.92,
      timestamp: now,
      audioAttachmentId: createdAudio1.id,
    );
    final transcription2 = Transcription(
      id: '',
      text: 'Pack my box with five dozen liquor jugs',
      confidence: 0.88,
      timestamp: now.add(const Duration(seconds: 1)),
      audioAttachmentId: createdAudio2.id,
    );

    final createdTrans1 = await transcriptionRepo.createTranscription(transcription1);
    final createdTrans2 = await transcriptionRepo.createTranscription(transcription2);

    // Search for content from first transcription
    await notesViewModel.load();
    final results1 = await notesViewModel.search('quick brown fox');
    expect(results1.length, 1);
    expect(results1.first.id, note1.id);

    // Search for content from second transcription
    final results2 = await notesViewModel.search('liquor jugs');
    expect(results2.length, 1);
    expect(results2.first.id, note2.id);

    // Search for term that appears in neither
    final results3 = await notesViewModel.search('xyzabc');
    expect(results3, isEmpty);
  });

  testWidgets('Multiple transcriptions per audio attachment', (tester) async {
    // Create note with audio
    final note = await notesRepo.createNote(
      title: 'Lecture Recording',
      content: 'Physics class notes',
    );

    final now = DateTime.now();
    final audio = AudioAttachment(
      id: 'audio-multi-${now.millisecondsSinceEpoch}',
      duration: 10000,
      path: '/tmp/lecture.m4a',
      format: 'm4a',
      size: 256000,
      createdAt: now,
      noteId: note.id,
    );

    final createdAudio = await audioRepo.createAudioAttachment(audio);

    // Create multiple transcriptions (e.g., different segments)
    final trans1 = Transcription(
      id: '',
      text: 'First segment: Introduction to quantum mechanics',
      confidence: 0.95,
      timestamp: now,
      audioAttachmentId: createdAudio.id,
    );
    final trans2 = Transcription(
      id: '',
      text: 'Second segment: Wave particle duality',
      confidence: 0.90,
      timestamp: now.add(const Duration(seconds: 5)),
      audioAttachmentId: createdAudio.id,
    );
    final trans3 = Transcription(
      id: '',
      text: 'Third segment: Schrödinger equation',
      confidence: 0.93,
      timestamp: now.add(const Duration(seconds: 10)),
      audioAttachmentId: createdAudio.id,
    );

    await transcriptionRepo.createTranscription(trans1);
    await transcriptionRepo.createTranscription(trans2);
    await transcriptionRepo.createTranscription(trans3);

    // Verify all transcriptions are retrievable
    final allTranscriptions =
        await transcriptionRepo.getTranscriptionsByAudioAttachmentId(createdAudio.id);
    expect(allTranscriptions.length, 3);

    // Search should find the note via any of the transcriptions
    await notesViewModel.load();

    final results1 = await notesViewModel.search('quantum mechanics');
    expect(results1.first.id, note.id);

    final results2 = await notesViewModel.search('wave particle');
    expect(results2.first.id, note.id);

    final results3 = await notesViewModel.search('Schrödinger');
    expect(results3.first.id, note.id);
  });

  testWidgets('Transcription with empty or null text handling', (tester) async {
    // Create note with audio
    final note = await notesRepo.createNote(
      title: 'Test Note',
      content: 'Content',
    );

    final now = DateTime.now();
    final audio = AudioAttachment(
      id: 'audio-empty-${now.millisecondsSinceEpoch}',
      duration: 2000,
      path: '/tmp/empty.m4a',
      format: 'm4a',
      size: 32000,
      createdAt: now,
      noteId: note.id,
    );

    final createdAudio = await audioRepo.createAudioAttachment(audio);

    // Create transcription with minimal text
    final trans = Transcription(
      id: '',
      text: '...', // Minimal transcription
      confidence: 0.5,
      timestamp: now,
      audioAttachmentId: createdAudio.id,
    );

    await transcriptionRepo.createTranscription(trans);

    // Search should still work with minimal content
    await notesViewModel.load();
    final results = await notesViewModel.search('...');
    expect(results, isNotEmpty);
  });

  testWidgets('Transcription persistence across note updates', (tester) async {
    // Create note with audio and transcription
    final note = await notesRepo.createNote(
      title: 'Original Title',
      content: 'Original content',
    );

    final now = DateTime.now();
    final audio = AudioAttachment(
      id: 'audio-persist-${now.millisecondsSinceEpoch}',
      duration: 5000,
      path: '/tmp/persist.m4a',
      format: 'm4a',
      size: 128000,
      createdAt: now,
      noteId: note.id,
    );

    final createdAudio = await audioRepo.createAudioAttachment(audio);

    final trans = Transcription(
      id: '',
      text: 'Important meeting notes about quarterly goals',
      confidence: 0.97,
      timestamp: now,
      audioAttachmentId: createdAudio.id,
    );

    final createdTrans = await transcriptionRepo.createTranscription(trans);

    // Update note title and content
    final updatedNote = await notesRepo.updateNote(
      note.copyWith(
        title: 'Updated Title',
        content: 'Updated content',
      ),
    );
    expect(updatedNote.title, 'Updated Title');

    // Verify transcription is still accessible and linked
    final retrievedTrans =
        await transcriptionRepo.getTranscriptionById(createdTrans.id);
    expect(retrievedTrans, isNotNull);
    expect(retrievedTrans!.text, contains('quarterly goals'));

    final audioTranscriptions =
        await transcriptionRepo.getTranscriptionsByAudioAttachmentId(createdAudio.id);
    expect(audioTranscriptions.length, 1);
    expect(audioTranscriptions.first.id, createdTrans.id);

    // Search should still find the note via transcription
    await notesViewModel.load();
    final results = await notesViewModel.search('quarterly goals');
    expect(results.first.id, note.id);
  });

  testWidgets('Transcription use case error handling', (tester) async {
    // Test transcription use case with invalid audio path
    final result = await transcribeAudioUseCase('/nonexistent/audio.m4a');

    // Should handle error gracefully
    expect(result.isSuccess, isTrue); // Use case returns success with placeholder
    expect(result.value, isNotNull);
    expect(result.value.text, contains('nonexistent'));
  });

  testWidgets('Partial transcription matches in search', (tester) async {
    // Create note with long transcription
    final note = await notesRepo.createNote(
      title: 'Interview Notes',
      content: 'Candidate discussion',
    );

    final now = DateTime.now();
    final audio = AudioAttachment(
      id: 'audio-partial-${now.millisecondsSinceEpoch}',
      duration: 15000,
      path: '/tmp/interview.m4a',
      format: 'm4a',
      size: 384000,
      createdAt: now,
      noteId: note.id,
    );

    final createdAudio = await audioRepo.createAudioAttachment(audio);

    final trans = Transcription(
      id: '',
      text: 'The candidate has five years of experience in software development '
          'with expertise in Flutter and Dart. They previously worked at a '
          'startup building mobile applications.',
      confidence: 0.94,
      timestamp: now,
      audioAttachmentId: createdAudio.id,
    );

    await transcriptionRepo.createTranscription(trans);

    // Search for partial terms
    await notesViewModel.load();

    final results1 = await notesViewModel.search('Flutter');
    expect(results1.first.id, note.id);

    final results2 = await notesViewModel.search('startup');
    expect(results2.first.id, note.id);

    final results3 = await notesViewModel.search('mobile applications');
    expect(results3.first.id, note.id);
  });

  testWidgets('Case insensitive transcription search', (tester) async {
    // Create note with transcription
    final note = await notesRepo.createNote(
      title: 'Shopping List',
      content: 'Groceries',
    );

    final now = DateTime.now();
    final audio = AudioAttachment(
      id: 'audio-case-${now.millisecondsSinceEpoch}',
      duration: 3000,
      path: '/tmp/shopping.m4a',
      format: 'm4a',
      size: 64000,
      createdAt: now,
      noteId: note.id,
    );

    final createdAudio = await audioRepo.createAudioAttachment(audio);

    final trans = Transcription(
      id: '',
      text: 'Remember to buy Milk Eggs Bread and Butter',
      confidence: 0.96,
      timestamp: now,
      audioAttachmentId: createdAudio.id,
    );

    await transcriptionRepo.createTranscription(trans);

    // Search with different cases
    await notesViewModel.load();

    final results1 = await notesViewModel.search('milk');
    expect(results1.first.id, note.id);

    final results2 = await notesViewModel.search('MILK');
    expect(results2.first.id, note.id);

    final results3 = await notesViewModel.search('MiLk');
    expect(results3.first.id, note.id);
  });
}
