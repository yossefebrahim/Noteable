import 'package:noteable_app/domain/entities/folder_entity.dart';
import 'package:noteable_app/domain/entities/note_entity.dart';
import 'package:noteable_app/domain/repositories/notes_feature_repository.dart';

class GetNotesUseCase {
  GetNotesUseCase(this.repo);
  final NotesFeatureRepository repo;
  Future<List<NoteEntity>> call() => repo.getNotes();
}

class CreateNoteUseCase {
  CreateNoteUseCase(this.repo);
  final NotesFeatureRepository repo;
  Future<NoteEntity> call({String? folderId}) => repo.createNote(folderId: folderId);
}

class UpdateNoteUseCase {
  UpdateNoteUseCase(this.repo);
  final NotesFeatureRepository repo;
  Future<NoteEntity> call(NoteEntity note) => repo.updateNote(note);
}

class DeleteNoteUseCase {
  DeleteNoteUseCase(this.repo);
  final NotesFeatureRepository repo;
  Future<void> call(String id) => repo.deleteNote(id);
}

class TogglePinUseCase {
  TogglePinUseCase(this.repo);
  final NotesFeatureRepository repo;
  Future<NoteEntity> call(String id) => repo.togglePin(id);
}

class SearchNotesUseCase {
  SearchNotesUseCase(this.repo);
  final NotesFeatureRepository repo;
  Future<List<NoteEntity>> call(String query) => repo.searchNotes(query);
}

class GetFoldersUseCase {
  GetFoldersUseCase(this.repo);
  final NotesFeatureRepository repo;
  Future<List<FolderEntity>> call() => repo.getFolders();
}

class CreateFolderUseCase {
  CreateFolderUseCase(this.repo);
  final NotesFeatureRepository repo;
  Future<FolderEntity> call(String name) => repo.createFolder(name);
}

class RenameFolderUseCase {
  RenameFolderUseCase(this.repo);
  final NotesFeatureRepository repo;
  Future<FolderEntity> call(String id, String name) => repo.renameFolder(id, name);
}

class DeleteFolderUseCase {
  DeleteFolderUseCase(this.repo);
  final NotesFeatureRepository repo;
  Future<void> call(String id) => repo.deleteFolder(id);
}
