import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

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
      <CollectionSchema>[NoteModelSchema, FolderModelSchema],
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
}
