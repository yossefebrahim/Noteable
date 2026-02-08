import 'package:noteable_app/domain/entities/audio_attachment.dart';
import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

import '../../services/storage/isar_service.dart';
import '../models/audio_attachment_model.dart';
import '../models/deleted_note_model.dart';
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
    return await _toEntity(created!);
  }

  @override
  Future<void> deleteNote(String id) async {
    await _isarService.deleteNote(int.parse(id));
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final model = await _isarService.getNoteById(int.parse(id));
    if (model == null) return null;
    return await _toEntity(model);
  }

  @override
  Future<List<Note>> getNoteList() async {
    final notes = await _isarService.getNotes();
    return await Future.wait(notes.map(_toEntity));
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    final notes = await _isarService.searchNotes(query);
    return await Future.wait(notes.map(_toEntity));
  }

  @override
  Future<List<Note>> getNotesWithAudioAttachments() async {
    final allNotes = await _isarService.getNotes();
    final notesWithAudio = <Note>[];

    for (final model in allNotes) {
      await model.audioAttachments.load();
      if (model.audioAttachments.isNotEmpty) {
        notesWithAudio.add(await _toEntity(model));
      }
    }

    return notesWithAudio;
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
      audioAttachments: note.audioAttachments,
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
    return await _toEntity(updated!);
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
    final result = await _exportService.exportMultipleNotes(filteredNotes, exportFormat);
    return result.filePath;
  }

  @override
  Future<String> exportAllNotes(String format) async {
    final allNotes = await _isarService.getNotes();

    if (allNotes.isEmpty) {
      throw StateError('No notes to export');
    }

    final exportFormat = _parseExportFormat(format);
    final result = await _exportService.exportMultipleNotes(allNotes, exportFormat);
    return result.filePath;
  }

  @override
  Future<String> getShareableNoteContent(String id) async {
    final model = await _isarService.getNoteById(int.parse(id));
    if (model == null) throw StateError('Note not found: $id');

    return _exportService.getShareableContent(model);
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
    return await _toEntity(note!);
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

  Future<Note> _toEntity(NoteModel model) async {
    // Load audio attachments
    await model.audioAttachments.load();
    final attachmentModels = model.audioAttachments.toList();

    // Convert audio attachment models to entities
    final attachments = attachmentModels
        .map((attachmentModel) {
          return AudioAttachment(
            id: attachmentModel.id.toString(),
            duration: attachmentModel.duration,
            path: attachmentModel.path,
            format: attachmentModel.format,
            size: attachmentModel.size,
            createdAt: attachmentModel.createdAt,
            noteId: attachmentModel.noteId,
          );
        })
        .toList(growable: false);

    return Note(
      id: model.id.toString(),
      title: model.title,
      content: model.content,
      isPinned: model.isPinned,
      folderId: model.folderId,
      audioAttachments: attachments,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt ?? model.createdAt,
    );
  }

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
