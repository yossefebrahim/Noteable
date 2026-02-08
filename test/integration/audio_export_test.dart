import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/entities/audio_attachment.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';
import 'package:noteable_app/services/storage/isar_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryNotesFeatureRepository notesRepo;
  late IsarService isarService;
  late NoteEditorViewModel noteEditorViewModel;

  setUp(() async {
    // Initialize services
    notesRepo = InMemoryNotesFeatureRepository();
    isarService = IsarService();
    await isarService.init();

    // Create provider
    noteEditorViewModel = NoteEditorViewModel(
      createNote: CreateNoteUseCase(notesRepo),
      updateNote: UpdateNoteUseCase(notesRepo),
      getNotes: GetNotesUseCase(notesRepo),
      audioRepository: notesRepo,
    );
  });

  tearDown(() async {
    noteEditorViewModel.dispose();
    await isarService.dispose();
  });

  group('Audio Export Tests', () {
    testWidgets('Note with single audio attachment contains all metadata for export',
        (tester) async {
      // Step 1: Create a new note
      await noteEditorViewModel.init();
      expect(noteEditorViewModel.hasNote, isTrue);
      final note = noteEditorViewModel.note!;
      expect(note.audioAttachments, isEmpty);

      // Step 2: Update note with content
      noteEditorViewModel.updateDraft(
        title: 'Export Test Note',
        content: 'This note has an audio attachment for export testing.',
      );

      // Step 3: Create audio attachment
      final now = DateTime.now();
      final audioAttachment = AudioAttachment(
        id: 'export-audio-1',
        duration: 10000, // 10 seconds in milliseconds
        path: '/var/mobile/Containers/Data/Application/Library/recordings/voice_note_20250208_120000.m4a',
        format: 'm4a',
        size: 256000, // 256 KB
        createdAt: now,
        noteId: note.id,
      );

      // Step 4: Attach audio to note
      await noteEditorViewModel.addAudioAttachment(audioAttachment);
      expect(noteEditorViewModel.audioAttachments.length, 1);

      // Step 5: Save note with attachment
      await noteEditorViewModel.saveNow();

      // Step 6: Reload to verify persistence
      await noteEditorViewModel.init(noteId: note.id);
      final reloadedNote = noteEditorViewModel.note!;
      final reloadedAttachment = noteEditorViewModel.audioAttachments.first;

      // Step 7: Verify all metadata needed for export is present
      expect(reloadedNote.title, 'Export Test Note');
      expect(reloadedNote.content, contains('audio attachment'));
      expect(reloadedAttachment.id, 'export-audio-1');
      expect(reloadedAttachment.duration, 10000);
      expect(reloadedAttachment.format, 'm4a');
      expect(reloadedAttachment.size, 256000);
      expect(reloadedAttachment.path, isNotEmpty);
      expect(reloadedAttachment.createdAt, isNotNull);
      expect(reloadedAttachment.noteId, note.id);

      // Verify export metadata completeness
      final exportMetadata = {
        'noteId': reloadedNote.id,
        'title': reloadedNote.title,
        'content': reloadedNote.content,
        'audioAttachments': reloadedNote.audioAttachments.map((attachment) => {
          'id': attachment.id,
          'duration': attachment.duration,
          'path': attachment.path,
          'format': attachment.format,
          'size': attachment.size,
          'createdAt': attachment.createdAt.toIso8601String(),
        }).toList(),
      };

      expect(exportMetadata['audioAttachments'], isNotEmpty);
      expect((exportMetadata['audioAttachments'] as List).length, 1);
      expect((exportMetadata['audioAttachments'] as List).first['format'], 'm4a');
      expect((exportMetadata['audioAttachments'] as List).first['size'], 256000);
    });

    testWidgets('Note with multiple audio attachments contains all metadata for export',
        (tester) async {
      // Create note
      await noteEditorViewModel.init();
      final note = noteEditorViewModel.note!;

      noteEditorViewModel.updateDraft(
        title: 'Multiple Audio Export Test',
        content: 'This note has multiple audio attachments.',
      );

      // Create multiple audio attachments
      final now = DateTime.now();
      final attachment1 = AudioAttachment(
        id: 'export-audio-multi-1',
        duration: 5000,
        path: '/recordings/voice_1.m4a',
        format: 'm4a',
        size: 128000,
        createdAt: now,
        noteId: note.id,
      );

      final attachment2 = AudioAttachment(
        id: 'export-audio-multi-2',
        duration: 15000,
        path: '/recordings/voice_2.m4a',
        format: 'm4a',
        size: 384000,
        createdAt: now.add(const Duration(seconds: 30)),
        noteId: note.id,
      );

      final attachment3 = AudioAttachment(
        id: 'export-audio-multi-3',
        duration: 8000,
        path: '/recordings/voice_3.m4a',
        format: 'm4a',
        size: 204800,
        createdAt: now.add(const Duration(minutes: 1)),
        noteId: note.id,
      );

      await noteEditorViewModel.addAudioAttachment(attachment1);
      await noteEditorViewModel.addAudioAttachment(attachment2);
      await noteEditorViewModel.addAudioAttachment(attachment3);

      expect(noteEditorViewModel.audioAttachments.length, 3);

      // Save note
      await noteEditorViewModel.saveNow();

      // Reload and verify all attachments are present
      await noteEditorViewModel.init(noteId: note.id);
      final reloadedAttachments = noteEditorViewModel.audioAttachments;

      expect(reloadedAttachments.length, 3);

      // Verify export contains all attachments
      final exportMetadata = {
        'noteId': note.id,
        'title': noteEditorViewModel.note!.title,
        'audioAttachments': reloadedAttachments.map((attachment) => {
          'id': attachment.id,
          'duration': attachment.duration,
          'path': attachment.path,
          'format': attachment.format,
          'size': attachment.size,
        }).toList(),
      };

      expect((exportMetadata['audioAttachments'] as List).length, 3);

      // Verify total audio size for export
      final totalAudioSize = reloadedAttachments.fold<int>(
        0,
        (sum, attachment) => sum + attachment.size,
      );
      expect(totalAudioSize, 128000 + 384000 + 204800);
    });

    testWidgets('Note without audio attachments exports without audio section',
        (tester) async {
      // Create note without audio
      await noteEditorViewModel.init();
      final note = noteEditorViewModel.note!;

      noteEditorViewModel.updateDraft(
        title: 'Text Only Note',
        content: 'This note has no audio attachments.',
      );

      await noteEditorViewModel.saveNow();

      // Reload
      await noteEditorViewModel.init(noteId: note.id);

      expect(noteEditorViewModel.audioAttachments, isEmpty);

      // Verify export metadata does not include audio section
      final exportMetadata = {
        'noteId': note.id,
        'title': noteEditorViewModel.note!.title,
        'content': noteEditorViewModel.note!.content,
        'hasAudioAttachments': noteEditorViewModel.audioAttachments.isNotEmpty,
        'audioAttachments': noteEditorViewModel.audioAttachments,
      };

      expect(exportMetadata['hasAudioAttachments'], isFalse);
      expect(exportMetadata['audioAttachments'], isEmpty);
    });

    testWidgets('Audio attachment path is preserved for export file location',
        (tester) async {
      // Create note with audio attachment
      await noteEditorViewModel.init();
      final note = noteEditorViewModel.note!;

      final audioAttachment = AudioAttachment(
        id: 'path-test-audio',
        duration: 12000,
        path: '/var/mobile/Containers/Data/Application/Library/recordings/lecture_physics_20250208_140500.m4a',
        format: 'm4a',
        size: 307200,
        createdAt: DateTime.now(),
        noteId: note.id,
      );

      await noteEditorViewModel.addAudioAttachment(audioAttachment);
      await noteEditorViewModel.saveNow();

      // Reload
      await noteEditorViewModel.init(noteId: note.id);
      final reloadedAttachment = noteEditorViewModel.audioAttachments.first;

      // Verify path is preserved for export (needed to locate actual audio file)
      expect(reloadedAttachment.path, contains('recordings'));
      expect(reloadedAttachment.path, contains('.m4a'));
      expect(reloadedAttachment.path, isNotEmpty);

      // Verify export includes file location information
      final exportFileInfo = {
        'audioId': reloadedAttachment.id,
        'sourcePath': reloadedAttachment.path,
        'fileFormat': reloadedAttachment.format,
        'fileSize': reloadedAttachment.size,
        'fileName': reloadedAttachment.path.split('/').last,
      };

      expect(exportFileInfo['fileName'], 'lecture_physics_20250208_140500.m4a');
      expect(exportFileInfo['fileFormat'], 'm4a');
      expect(exportFileInfo['fileSize'], 307200);
    });

    testWidgets('Export metadata includes audio timestamps for chronological ordering',
        (tester) async {
      // Create note
      await noteEditorViewModel.init();
      final note = noteEditorViewModel.note!;

      // Create attachments with different timestamps
      final now = DateTime.now();
      final earlyAttachment = AudioAttachment(
        id: 'early-audio',
        duration: 3000,
        path: '/recordings/early.m4a',
        format: 'm4a',
        size: 96000,
        createdAt: now.subtract(const Duration(hours: 2)),
        noteId: note.id,
      );

      final middleAttachment = AudioAttachment(
        id: 'middle-audio',
        duration: 5000,
        path: '/recordings/middle.m4a',
        format: 'm4a',
        size: 160000,
        createdAt: now.subtract(const Duration(hours: 1)),
        noteId: note.id,
      );

      final lateAttachment = AudioAttachment(
        id: 'late-audio',
        duration: 4000,
        path: '/recordings/late.m4a',
        format: 'm4a',
        size: 128000,
        createdAt: now,
        noteId: note.id,
      );

      await noteEditorViewModel.addAudioAttachment(earlyAttachment);
      await noteEditorViewModel.addAudioAttachment(middleAttachment);
      await noteEditorViewModel.addAudioAttachment(lateAttachment);
      await noteEditorViewModel.saveNow();

      // Reload
      await noteEditorViewModel.init(noteId: note.id);
      final attachments = noteEditorViewModel.audioAttachments;

      // Verify timestamps are preserved for export
      final exportTimeline = attachments.map((attachment) => {
        'id': attachment.id,
        'createdAt': attachment.createdAt.toIso8601String(),
        'duration': attachment.duration,
      }).toList();

      // Verify chronological order can be established
      expect(exportTimeline.length, 3);
      expect(exportTimeline[0]['id'], 'early-audio');
      expect(exportTimeline[1]['id'], 'middle-audio');
      expect(exportTimeline[2]['id'], 'late-audio');

      // Verify timestamps are in ascending order
      final time1 = DateTime.parse(exportTimeline[0]['createdAt'] as String);
      final time2 = DateTime.parse(exportTimeline[1]['createdAt'] as String);
      final time3 = DateTime.parse(exportTimeline[2]['createdAt'] as String);

      expect(time1.isBefore(time2), isTrue);
      expect(time2.isBefore(time3), isTrue);
    });

    testWidgets('Audio attachment survives note content updates for export consistency',
        (tester) async {
      // Create note with audio
      await noteEditorViewModel.init();
      final note = noteEditorViewModel.note!;

      final audioAttachment = AudioAttachment(
        id: 'update-test-audio',
        duration: 7000,
        path: '/recordings/update_test.m4a',
        format: 'm4a',
        size: 224000,
        createdAt: DateTime.now(),
        noteId: note.id,
      );

      await noteEditorViewModel.addAudioAttachment(audioAttachment);

      noteEditorViewModel.updateDraft(
        title: 'Original Title',
        content: 'Original content.',
      );
      await noteEditorViewModel.saveNow();

      // Update note content multiple times
      await noteEditorViewModel.init(noteId: note.id);
      noteEditorViewModel.updateDraft(title: 'Updated Title');
      await noteEditorViewModel.saveNow();

      await noteEditorViewModel.init(noteId: note.id);
      noteEditorViewModel.updateDraft(content: 'Updated content with more details.');
      await noteEditorViewModel.saveNow();

      // Final reload
      await noteEditorViewModel.init(noteId: note.id);
      final finalNote = noteEditorViewModel.note!;
      final finalAttachment = noteEditorViewModel.audioAttachments.first;

      // Verify audio attachment survived all updates
      expect(finalNote.title, 'Updated Title');
      expect(finalNote.content, contains('more details'));
      expect(finalAttachment.id, 'update-test-audio');
      expect(finalAttachment.duration, 7000);
      expect(finalAttachment.format, 'm4a');

      // Verify export consistency
      final exportMetadata = {
        'note': {
          'title': finalNote.title,
          'content': finalNote.content,
          'lastModified': finalNote.updatedAt.toIso8601String(),
        },
        'audio': {
          'id': finalAttachment.id,
          'duration': finalAttachment.duration,
          'createdAt': finalAttachment.createdAt.toIso8601String(),
        },
      };

      expect(exportMetadata['audio']['id'], 'update-test-audio');
      expect(exportMetadata['note']['title'], 'Updated Title');
    });
  });
}
