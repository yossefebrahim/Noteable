import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

import '../../services/storage/isar_service.dart';
import '../models/note_model.dart';
import '../services/export_service.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl(this._isarService, [ExportService? exportService])
      : _exportService = exportService ?? ExportService();

  final IsarService _isarService;
  final ExportService _exportService;

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
  Future<String> exportNote(String id, String format) async {
    final model = await _isarService.getNoteById(int.parse(id));
    if (model == null) throw StateError('Note not found: $id');

    final exportFormat = _parseExportFormat(format);
    final result = await _exportService.exportSingleNote(model, exportFormat);
    return result.filePath;
  }

  @override
  Future<String> exportFolder(String? folderId, String format) async {
    final allNotes = await _isarService.getNotes();
    final filteredNotes = folderId == null
        ? allNotes
        : allNotes.where((note) => note.folderId == folderId).toList();

    if (filteredNotes.isEmpty) {
      throw StateError('No notes found in folder');
    }

    final exportFormat = _parseExportFormat(format);
    final result = await _exportService.exportMultipleNotes(
      filteredNotes,
      exportFormat,
    );
    return result.filePath;
  }

  @override
  Future<String> exportAllNotes(String format) async {
    final allNotes = await _isarService.getNotes();

    if (allNotes.isEmpty) {
      throw StateError('No notes to export');
    }

    final exportFormat = _parseExportFormat(format);
    final result = await _exportService.exportMultipleNotes(
      allNotes,
      exportFormat,
    );
    return result.filePath;
  }

  @override
  Future<String> getShareableNoteContent(String id) async {
    final model = await _isarService.getNoteById(int.parse(id));
    if (model == null) throw StateError('Note not found: $id');

    return _exportService.getShareableContent(model);
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

  ExportFormat _parseExportFormat(String format) {
    switch (format.toLowerCase()) {
      case 'markdown':
      case 'md':
        return ExportFormat.markdown;
      case 'txt':
      case 'text':
        return ExportFormat.txt;
      case 'pdf':
        return ExportFormat.pdf;
      case 'json':
        return ExportFormat.json;
      default:
        throw ArgumentError('Unsupported export format: $format');
    }
  }
}
