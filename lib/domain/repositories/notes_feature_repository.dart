import 'package:noteable_app/domain/entities/folder_entity.dart';
import 'package:noteable_app/domain/entities/note_entity.dart';

abstract class NotesFeatureRepository {
  Future<List<NoteEntity>> getNotes();
  Future<NoteEntity?> getNoteById(String id);
  Future<NoteEntity> createNote({String? folderId, String title = '', String content = ''});
  Future<NoteEntity> updateNote(NoteEntity note);
  Future<void> deleteNote(String id);
  Future<NoteEntity> togglePin(String id);
  Future<List<NoteEntity>> searchNotes(String query);

  Future<List<FolderEntity>> getFolders();
  Future<FolderEntity> createFolder(String name);
  Future<FolderEntity> renameFolder(String id, String newName);
  Future<void> deleteFolder(String id);
}
