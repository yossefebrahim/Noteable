import 'package:flutter/foundation.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';
import 'package:noteable_app/domain/usecases/export/export_all_notes_usecase.dart';
import 'package:noteable_app/domain/usecases/export/export_folder_usecase.dart';
import 'package:noteable_app/domain/usecases/export/export_note_usecase.dart';
import 'package:noteable_app/domain/usecases/export/share_note_usecase.dart';

class ExportViewModel extends ChangeNotifier {
  ExportViewModel({
    required NoteRepository noteRepository,
  }) : _noteRepository = noteRepository;

  final NoteRepository _noteRepository;

  bool _isExporting = false;
  String? _exportError;
  String? _lastExportPath;
  String? _shareableContent;

  bool get isExporting => _isExporting;
  String? get exportError => _exportError;
  String? get lastExportPath => _lastExportPath;
  String? get shareableContent => _shareableContent;

  Future<bool> exportNote(String noteId, String format) async {
    _setExportingState(true);
    _clearError();

    try {
      final useCase = ExportNoteUseCase(
        noteRepository: _noteRepository,
        noteId: noteId,
        format: format,
      );

      final result = await useCase();

      if (result.isSuccess) {
        _lastExportPath = result.value;
        _setExportingState(false);
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Export failed');
        _setExportingState(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to export note: $e');
      _setExportingState(false);
      return false;
    }
  }

  Future<bool> exportFolder(String? folderId, String format) async {
    _setExportingState(true);
    _clearError();

    try {
      final useCase = ExportFolderUseCase(
        noteRepository: _noteRepository,
        folderId: folderId,
        format: format,
      );

      final result = await useCase();

      if (result.isSuccess) {
        _lastExportPath = result.value;
        _setExportingState(false);
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Export failed');
        _setExportingState(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to export folder: $e');
      _setExportingState(false);
      return false;
    }
  }

  Future<bool> exportAllNotes(String format) async {
    _setExportingState(true);
    _clearError();

    try {
      final useCase = ExportAllNotesUseCase(
        noteRepository: _noteRepository,
        format: format,
      );

      final result = await useCase();

      if (result.isSuccess) {
        _lastExportPath = result.value;
        _setExportingState(false);
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Export failed');
        _setExportingState(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to export all notes: $e');
      _setExportingState(false);
      return false;
    }
  }

  Future<bool> getShareableContent(String noteId) async {
    _clearError();

    try {
      final useCase = ShareNoteUseCase(
        noteRepository: _noteRepository,
        noteId: noteId,
      );

      final result = await useCase();

      if (result.isSuccess) {
        _shareableContent = result.value;
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Failed to get shareable content');
        return false;
      }
    } catch (e) {
      _setError('Failed to get shareable content: $e');
      return false;
    }
  }

  void clearShareableContent() {
    _shareableContent = null;
    notifyListeners();
  }

  void _setExportingState(bool value) {
    _isExporting = value;
    notifyListeners();
  }

  void _setError(String error) {
    _exportError = error;
    notifyListeners();
  }

  void _clearError() {
    _exportError = null;
  }
}
