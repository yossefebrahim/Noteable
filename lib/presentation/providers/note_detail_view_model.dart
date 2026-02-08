import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:noteable_app/domain/entities/note_entity.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';

class NoteEditorViewModel extends ChangeNotifier {
  NoteEditorViewModel({
    required CreateNoteUseCase createNote,
    required UpdateNoteUseCase updateNote,
    required GetNotesUseCase getNotes,
  }) : _createNote = createNote,
       _updateNote = updateNote,
       _getNotes = getNotes;

  final CreateNoteUseCase _createNote;
  final UpdateNoteUseCase _updateNote;
  final GetNotesUseCase _getNotes;

  NoteEntity? _note;
  Timer? _autoSaveTimer;
  bool _isSaving = false;

  NoteEntity? get note => _note;
  bool get hasNote => _note != null;
  bool get isSaving => _isSaving;

  Future<void> init({String? noteId, String? folderId}) async {
    final List<NoteEntity> notes = await _getNotes();
    _note = noteId == null
        ? await _createNote(folderId: folderId)
        : notes.firstWhere((NoteEntity n) => n.id == noteId);
    notifyListeners();
  }

  void updateDraft({String? title, String? content, bool? isPinned}) {
    if (_note == null) return;
    _note = _note!.copyWith(
      title: title ?? _note!.title,
      content: content ?? _note!.content,
      isPinned: isPinned ?? _note!.isPinned,
      updatedAt: DateTime.now(),
    );
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 300), saveNow);
  }

  Future<void> saveNow() async {
    if (_note == null) return;
    _isSaving = true;
    notifyListeners();
    _note = await _updateNote(_note!);
    _isSaving = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
