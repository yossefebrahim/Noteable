import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/deleted_note_model.dart';
import '../../data/models/folder_model.dart';
import '../../data/models/note_model.dart';
import 'isar_migrations.dart';

class IsarService {
  IsarService();

  static const int schemaVersion = 1;
  Isar? _isar;

  Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      <CollectionSchema>[
        NoteModelSchema,
        FolderModelSchema,
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
    return database.noteModels
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .contentContains(query, caseSensitive: false)
        .findAll();
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
    return database.deletedNoteModels
        .filter()
        .noteIdEqualTo(noteId)
        .findFirst();
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
      return database.deletedNoteModels
          .filter()
          .noteIdEqualTo(noteId)
          .deleteAll() > 0;
    });
  }
}
