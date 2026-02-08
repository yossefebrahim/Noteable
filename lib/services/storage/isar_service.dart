import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/audio_attachment_model.dart';
import '../../data/models/deleted_note_model.dart';
import '../../data/models/folder_model.dart';
import '../../data/models/note_model.dart';
import '../../data/models/transcription_model.dart';
import 'isar_migrations.dart';

class IsarService {
  IsarService();

  static const int schemaVersion = 2;
  Isar? _isar;

  Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      <CollectionSchema>[
        NoteModelSchema,
        FolderModelSchema,
        AudioAttachmentModelSchema,
        TranscriptionModelSchema,
        DeletedNoteModelSchema,
      ],
      directory: dir.path,
      name: 'noteable_db',
      inspector: false,
    );

    await runIsarMigrations(isar: _isar!, from: 0, to: schemaVersion);
  }

  Future<Isar> get db async {
    await init();
    return _isar!;
  }

  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _isar = null;
    }
  }

  Future<Id> putNote(NoteModel note) async {
    final database = await db;
    return database.writeTxn(() => database.noteModels.put(note));
  }

  Future<List<NoteModel>> getNotes() async {
    final database = await db;
    return database.noteModels.where().sortByCreatedAtDesc().findAll();
  }

  Future<NoteModel?> getNoteById(Id id) async {
    final database = await db;
    return database.noteModels.get(id);
  }

  Future<bool> deleteNote(Id id) async {
    final database = await db;
    return database.writeTxn(() => database.noteModels.delete(id));
  }

  Future<List<NoteModel>> searchNotes(String query) async {
    final database = await db;

    // Search notes by title/content
    final notesByText = await database.noteModels
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .contentContains(query, caseSensitive: false)
        .findAll();

    // Search transcriptions by text
    final transcriptions = await database.transcriptionModels
        .filter()
        .textContains(query, caseSensitive: false)
        .findAll();

    // Get audio attachments for matching transcriptions
    final audioAttachmentIds = transcriptions.map((t) => t.audioAttachmentId).nonNulls.toSet();
    final audioAttachments = await database.audioAttachmentModels
        .filter()
        .anyOf(audioAttachmentIds.toList(), (q) => q.idEqualTo(q))
        .findAll();

    // Get notes for matching audio attachments
    final noteIds = audioAttachments.map((a) => a.noteId).nonNulls.map(int.parse).toSet();
    final notesByTranscription = await database.noteModels
        .filter()
        .anyOf(noteIds.toList(), (q) => q.idEqualTo(q))
        .findAll();

    // Combine and deduplicate results
    final allNotes = [...notesByText, ...notesByTranscription];
    final uniqueNotes = <Id, NoteModel>{for (final note in allNotes) note.id: note};

    return uniqueNotes.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Id> putFolder(FolderModel folder) async {
    final database = await db;
    return database.writeTxn(() => database.folderModels.put(folder));
  }

  Future<List<FolderModel>> getFolders() async {
    final database = await db;
    return database.folderModels.where().sortByCreatedAtDesc().findAll();
  }

  Future<FolderModel?> getFolderById(Id id) async {
    final database = await db;
    return database.folderModels.get(id);
  }

  // Audio Attachments

  Future<Id> putAudioAttachment(AudioAttachmentModel audioAttachment) async {
    final database = await db;
    return database.writeTxn(() => database.audioAttachmentModels.put(audioAttachment));
  }

  Future<List<AudioAttachmentModel>> getAudioAttachments() async {
    final database = await db;
    return database.audioAttachmentModels.where().sortByCreatedAtDesc().findAll();
  }

  Future<AudioAttachmentModel?> getAudioAttachmentById(Id id) async {
    final database = await db;
    return database.audioAttachmentModels.get(id);
  }

  Future<List<AudioAttachmentModel>> getAudioAttachmentsByNoteId(String noteId) async {
    final database = await db;
    return database.audioAttachmentModels
        .filter()
        .noteIdEqualTo(noteId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<bool> deleteAudioAttachment(Id id) async {
    final database = await db;
    return database.writeTxn(() => database.audioAttachmentModels.delete(id));
  }

  // Transcriptions

  Future<Id> putTranscription(TranscriptionModel transcription) async {
    final database = await db;
    return database.writeTxn(() => database.transcriptionModels.put(transcription));
  }

  Future<List<TranscriptionModel>> getTranscriptions() async {
    final database = await db;
    return database.transcriptionModels.where().sortByTimestampDesc().findAll();
  }

  Future<TranscriptionModel?> getTranscriptionById(Id id) async {
    final database = await db;
    return database.transcriptionModels.get(id);
  }

  Future<List<TranscriptionModel>> getTranscriptionsByAudioAttachmentId(
    int audioAttachmentId,
  ) async {
    final database = await db;
    return database.transcriptionModels
        .filter()
        .audioAttachmentIdEqualTo(audioAttachmentId)
        .sortByTimestampDesc()
        .findAll();
  }

  Future<bool> deleteTranscription(Id id) async {
    final database = await db;
    return database.writeTxn(() => database.transcriptionModels.delete(id));
  }

  Future<Id> putDeletedNote(DeletedNoteModel deletedNote) async {
    final database = await db;
    return database.writeTxn(() => database.deletedNoteModels.put(deletedNote));
  }

  Future<DeletedNoteModel?> getDeletedNote(Id id) async {
    final database = await db;
    return database.deletedNoteModels.get(id);
  }

  Future<DeletedNoteModel?> getDeletedNoteByNoteId(Id noteId) async {
    final database = await db;
    return database.deletedNoteModels.filter().noteIdEqualTo(noteId).findFirst();
  }

  Future<List<DeletedNoteModel>> getDeletedNotes() async {
    final database = await db;
    return database.deletedNoteModels.where().sortByDeletedAtDesc().findAll();
  }

  Future<bool> restoreDeletedNote(Id deletedNoteId) async {
    final database = await db;
    final deletedNote = await database.deletedNoteModels.get(deletedNoteId);

    if (deletedNote == null) return false;

    await database.writeTxn(() async {
      // Restore the note
      final restoredNote = NoteModel(
        id: deletedNote.noteId,
        title: deletedNote.title,
        content: deletedNote.content,
        createdAt: deletedNote.createdAt,
        updatedAt: deletedNote.updatedAt,
        isPinned: deletedNote.isPinned,
        folderId: deletedNote.folderId,
      );
      await database.noteModels.put(restoredNote);

      // Delete the deleted note record
      await database.deletedNoteModels.delete(deletedNoteId);
    });

    return true;
  }

  Future<bool> permanentlyDeleteNote(Id noteId) async {
    final database = await db;
    return database.writeTxn(() {
      return database.deletedNoteModels.filter().noteIdEqualTo(noteId).deleteAll() > 0;
    });
  }
}
