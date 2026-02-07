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

  Future<List<Note>> getNotesWithAudioAttachments();
}
