import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

import '../../services/storage/isar_service.dart';
import '../models/deleted_note_model.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl(this._isarService);

  final IsarService _isarService;

  @override
  Future<void> initialize() => _isarService.init();

  @override
  Future<Note> createNote(Note note) async {
    final model = _toModel(note);
    final id = await _isarService.putNote(model);
    final created = await _isarService.getNoteById(id);
    return _toEntity(created!);
  }

  @override
  Future<void> deleteNote(String id) async {
    await _isarService.deleteNote(int.parse(id));
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final model = await _isarService.getNoteById(int.parse(id));
    if (model == null) return null;
    return _toEntity(model);
  }

  @override
  Future<List<Note>> getNoteList() async {
    final notes = await _isarService.getNotes();
    return notes.map(_toEntity).toList(growable: false);
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    final notes = await _isarService.searchNotes(query);
    return notes.map(_toEntity).toList(growable: false);
  }

  @override
  Future<Note> togglePinNote(String id) async {
    final note = await getNoteById(id);
    if (note == null) throw StateError('Note not found: $id');

    final updated = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      isPinned: !note.isPinned,
      folderId: note.folderId,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
    );

    return updateNote(updated);
  }

  @override
  Future<Note> updateNote(Note note) async {
    final model = _toModel(note);
    await _isarService.putNote(model);
    final updated = await _isarService.getNoteById(model.id);
    return _toEntity(updated!);
  }

  @override
  Future<Note> softDeleteNote(String id) async {
    final note = await getNoteById(id);
    if (note == null) throw StateError('Note not found: $id');

    final noteId = int.parse(id);
    final deletedNote = DeletedNoteModel(
      noteId: noteId,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      isPinned: note.isPinned,
      folderId: note.folderId,
      deletedAt: DateTime.now(),
    );

    await _isarService.putDeletedNote(deletedNote);
    await _isarService.deleteNote(noteId);

    return note;
  }

  @override
  Future<Note> restoreNote(String id) async {
    final noteId = int.parse(id);
    final deletedNote = await _isarService.getDeletedNoteByNoteId(noteId);

    if (deletedNote == null) {
      throw StateError('Deleted note not found for note ID: $id');
    }

    final restored = await _isarService.restoreDeletedNote(deletedNote.id);
    if (!restored) {
      throw StateError('Failed to restore note: $id');
    }

    final note = await _isarService.getNoteById(noteId);
    return _toEntity(note!);
  }

  @override
  Future<Note?> getDeletedNote(String id) async {
    final noteId = int.parse(id);
    final deletedNote = await _isarService.getDeletedNoteByNoteId(noteId);

    if (deletedNote == null) return null;

    return Note(
      id: deletedNote.noteId.toString(),
      title: deletedNote.title,
      content: deletedNote.content,
      isPinned: deletedNote.isPinned,
      folderId: deletedNote.folderId,
      createdAt: deletedNote.createdAt,
      updatedAt: deletedNote.updatedAt ?? deletedNote.createdAt,
    );
  }

  NoteModel _toModel(Note note) => NoteModel(
        id: int.tryParse(note.id) ?? 0,
        title: note.title,
        content: note.content,
        createdAt: note.createdAt,
        updatedAt: note.updatedAt,
        isPinned: note.isPinned,
        folderId: note.folderId,
      );

  Note _toEntity(NoteModel model) => Note(
        id: model.id.toString(),
        title: model.title,
        content: model.content,
        isPinned: model.isPinned,
        folderId: model.folderId,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt ?? model.createdAt,
      );
}
