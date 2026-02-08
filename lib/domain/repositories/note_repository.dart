import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/domain/repositories/base_repository.dart';

abstract interface class NoteRepository implements BaseRepository {
  Future<List<Note>> getNoteList();

  Future<Note?> getNoteById(String id);

  Future<Note> createNote(Note note);

  Future<Note> updateNote(Note note);

  Future<void> deleteNote(String id);

  Future<Note> togglePinNote(String id);

  Future<List<Note>> searchNotes(String query);

  Future<String> exportNote(String id, String format);

  Future<String> exportFolder(String? folderId, String format);

  Future<String> exportAllNotes(String format);

  Future<String> getShareableNoteContent(String id);

  Future<Note> softDeleteNote(String id);

  Future<Note> restoreNote(String id);

  Future<Note?> getDeletedNote(String id);
}
