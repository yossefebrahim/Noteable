import 'package:noteable_app/domain/entities/folder_entity.dart';
import 'package:noteable_app/domain/entities/note_entity.dart';
import 'package:noteable_app/domain/repositories/notes_feature_repository.dart';

class InMemoryNotesFeatureRepository implements NotesFeatureRepository {
  final Map<String, NoteEntity> _notes = <String, NoteEntity>{};
  final Map<String, FolderEntity> _folders = <String, FolderEntity>{};
  final Map<String, NoteEntity> _deletedNotes = <String, NoteEntity>{};

  int _noteSeed = 0;
  int _folderSeed = 0;

  @override
  Future<NoteEntity> createNote({
    String? folderId,
    String title = '',
    String content = '',
    bool isPinned = false,
  }) async {
    final String id = 'n_${++_noteSeed}';
    final NoteEntity note = NoteEntity(
      id: id,
      title: title,
      content: content,
      folderId: folderId,
      isPinned: isPinned,
    );
    _notes[id] = note;
    return note;
  }

  @override
  Future<void> deleteNote(String id) async {
    final note = _notes.remove(id);
    if (note != null) {
      _deletedNotes[id] = note;
    }
  }

  /// Soft delete a note (move to deleted notes collection)
  Future<void> softDeleteNote(String id) async {
    await deleteNote(id);
  }

  /// Restore a note from deleted notes collection
  Future<void> restoreNote(String id) async {
    final note = _deletedNotes.remove(id);
    if (note != null) {
      _notes[id] = note;
    }
  }

  @override
  Future<NoteEntity?> getNoteById(String id) async => _notes[id];

  @override
  Future<List<NoteEntity>> getNotes() async {
    final List<NoteEntity> notes = _notes.values.toList()
      ..sort((NoteEntity a, NoteEntity b) {
        if (a.isPinned != b.isPinned) {
          return b.isPinned ? 1 : -1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
    return notes;
  }

  @override
  Future<List<NoteEntity>> searchNotes(String query) async {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return getNotes();
    }
    return (await getNotes())
        .where(
          (NoteEntity n) =>
              n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Future<NoteEntity> togglePin(String id) async {
    final NoteEntity note = _notes[id]!;
    final NoteEntity updated = note.copyWith(isPinned: !note.isPinned, updatedAt: DateTime.now());
    _notes[id] = updated;
    return updated;
  }

  @override
  Future<NoteEntity> updateNote(NoteEntity note) async {
    final NoteEntity updated = note.copyWith(updatedAt: DateTime.now());
    _notes[note.id] = updated;
    return updated;
  }

  @override
  Future<FolderEntity> createFolder(String name) async {
    final String id = 'f_${++_folderSeed}';
    final FolderEntity folder = FolderEntity(id: id, name: name);
    _folders[id] = folder;
    return folder;
  }

  @override
  Future<void> deleteFolder(String id) async {
    _folders.remove(id);
    for (final MapEntry<String, NoteEntity> entry in _notes.entries.toList()) {
      if (entry.value.folderId == id) {
        _notes[entry.key] = entry.value.copyWith(clearFolderId: true);
      }
    }
  }

  @override
  Future<List<FolderEntity>> getFolders() async {
    final List<FolderEntity> list = _folders.values.toList()
      ..sort(
        (FolderEntity a, FolderEntity b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    return list;
  }

  @override
  Future<FolderEntity> renameFolder(String id, String newName) async {
    final FolderEntity folder = _folders[id]!;
    final FolderEntity updated = folder.copyWith(name: newName);
    _folders[id] = updated;
    return updated;
  }
}
