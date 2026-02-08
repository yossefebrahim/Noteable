import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:noteable_app/domain/entities/audio_attachment.dart';
import 'package:noteable_app/domain/entities/note_entity.dart';
import 'package:noteable_app/domain/repositories/audio_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';

class NoteEditorViewModel extends ChangeNotifier {
  NoteEditorViewModel({
    required CreateNoteUseCase createNote,
    required UpdateNoteUseCase updateNote,
    required GetNotesUseCase getNotes,
    required AudioRepository audioRepository,
  }) : _createNote = createNote,
       _updateNote = updateNote,
       _getNotes = getNotes,
       _audioRepository = audioRepository;

  final CreateNoteUseCase _createNote;
  final UpdateNoteUseCase _updateNote;
  final GetNotesUseCase _getNotes;
  final AudioRepository _audioRepository;

  NoteEntity? _note;
  Timer? _autoSaveTimer;
  bool _isSaving = false;

  NoteEntity? get note => _note;
  bool get hasNote => _note != null;
  bool get isSaving => _isSaving;
  List<AudioAttachment> get audioAttachments => _note?.audioAttachments ?? [];

  Future<void> init({String? noteId, String? folderId}) async {
    final List<NoteEntity> notes = await _getNotes();
    _note = noteId == null
        ? await _createNote(folderId: folderId)
        : notes.firstWhere((NoteEntity n) => n.id == noteId);
    await _loadAudioAttachments();
    notifyListeners();
  }

  Future<void> _loadAudioAttachments() async {
    if (_note == null) return;
    final attachments = await _audioRepository.getAudioAttachmentsByNoteId(_note!.id);
    _note = _note!.copyWith(audioAttachments: attachments);
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
    notifyListeners();
    _scheduleAutoSave();
  }

  Future<void> addAudioAttachment(AudioAttachment attachment) async {
    if (_note == null) return;
    final updatedAttachments = [..._note!.audioAttachments, attachment];
    _note = _note!.copyWith(
      audioAttachments: updatedAttachments,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    _scheduleAutoSave();
  }

  Future<void> removeAudioAttachment(String attachmentId) async {
    if (_note == null) return;
    final updatedAttachments = _note!.audioAttachments
        .where((a) => a.id != attachmentId)
        .toList();
    _note = _note!.copyWith(
      audioAttachments: updatedAttachments,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 700), saveNow);
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
