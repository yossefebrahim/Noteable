import 'package:flutter/foundation.dart';

import 'note_provider.dart';

class NoteDetailViewModel extends ChangeNotifier {
  NoteDetailViewModel();

  String? noteId;
  String title = '';
  String content = '';
  bool isPinned = false;
  String? folderName;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool get isEditing => noteId != null;

  void setFromNote(NoteItem note) {
    noteId = note.id;
    title = note.title;
    content = note.content;
    isPinned = note.isPinned;
    folderName = note.folderName;
    notifyListeners();
  }

  void createNew({String? initialFolder}) {
    noteId = null;
    title = '';
    content = '';
    isPinned = false;
    folderName = initialFolder;
    notifyListeners();
  }

  void updateTitle(String value) {
    title = value;
    notifyListeners();
  }

  void updateContent(String value) {
    content = value;
    notifyListeners();
  }

  void togglePin() {
    isPinned = !isPinned;
    notifyListeners();
  }

  Future<NoteItem> save() async {
    _isSaving = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 300));

    final item = NoteItem(
      id: noteId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim().isEmpty ? 'Untitled Note' : title.trim(),
      content: content,
      updatedAt: DateTime.now(),
      isPinned: isPinned,
      folderName: folderName,
    );

    _isSaving = false;
    notifyListeners();
    return item;
  }
}
