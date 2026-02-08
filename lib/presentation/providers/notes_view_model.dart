import 'package:flutter/foundation.dart';
import 'package:noteable_app/domain/entities/folder_entity.dart';
import 'package:noteable_app/domain/entities/note_entity.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';

class NotesViewModel extends ChangeNotifier {
  NotesViewModel({
    required GetNotesUseCase getNotes,
    required DeleteNoteUseCase deleteNote,
    required TogglePinUseCase togglePin,
    required GetFoldersUseCase getFolders,
    required CreateFolderUseCase createFolder,
    required RenameFolderUseCase renameFolder,
    required DeleteFolderUseCase deleteFolder,
    required SearchNotesUseCase searchNotes,
    required RestoreNoteUseCase restoreNote,
  }) : _getNotes = getNotes,
       _deleteNote = deleteNote,
       _togglePin = togglePin,
       _getFolders = getFolders,
       _createFolder = createFolder,
       _renameFolder = renameFolder,
       _deleteFolder = deleteFolder,
       _searchNotes = searchNotes,
       _restoreNote = restoreNote;

  final GetNotesUseCase _getNotes;
  final DeleteNoteUseCase _deleteNote;
  final TogglePinUseCase _togglePin;
  final GetFoldersUseCase _getFolders;
  final CreateFolderUseCase _createFolder;
  final RenameFolderUseCase _renameFolder;
  final DeleteFolderUseCase _deleteFolder;
  final SearchNotesUseCase _searchNotes;
  final RestoreNoteUseCase _restoreNote;

  List<NoteEntity> _notes = <NoteEntity>[];
  List<FolderEntity> _folders = <FolderEntity>[];

  List<NoteEntity> get notes => _notes;
  List<FolderEntity> get folders => _folders;

  Future<void> load() async {
    _notes = await _getNotes();
    _folders = await _getFolders();
    notifyListeners();
  }

  Future<void> refreshNotes() async {
    _notes = await _getNotes();
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await _deleteNote(id);
    await refreshNotes();
  }

  Future<void> togglePin(String id) async {
    await _togglePin(id);
    await refreshNotes();
  }

  Future<void> restoreNote(String id) async {
    await _restoreNote(id);
    await refreshNotes();
  }

  Future<void> createFolder(String name) async {
    if (name.trim().isEmpty) return;
    await _createFolder(name.trim());
    _folders = await _getFolders();
    notifyListeners();
  }

  Future<void> renameFolder(String id, String name) async {
    if (name.trim().isEmpty) return;
    await _renameFolder(id, name.trim());
    _folders = await _getFolders();
    notifyListeners();
  }

  Future<void> deleteFolder(String id) async {
    await _deleteFolder(id);
    _folders = await _getFolders();
    await refreshNotes();
  }

  Future<List<NoteEntity>> search(String query) => _searchNotes(query);
}
