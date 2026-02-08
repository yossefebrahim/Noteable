import 'package:flutter/foundation.dart';

class NoteItem {
  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.isPinned = false,
    this.folderName,
    this.audioAttachmentCount = 0,
  });

  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;
  final bool isPinned;
  final String? folderName;
  final int audioAttachmentCount;

  NoteItem copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? updatedAt,
    bool? isPinned,
    String? folderName,
    int? audioAttachmentCount,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      folderName: folderName ?? this.folderName,
      audioAttachmentCount: audioAttachmentCount ?? this.audioAttachmentCount,
    );
  }
}

/// ViewModel for Home note list.
class NoteListViewModel extends ChangeNotifier {
  NoteListViewModel();

  final List<NoteItem> _notes = <NoteItem>[
    NoteItem(
      id: '1',
      title: 'Meeting Notes',
      content: 'Discussed Q1 targets and assigned ownership.',
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isPinned: true,
      folderName: 'Work',
    ),
    NoteItem(
      id: '2',
      title: 'Shopping List',
      content: 'Milk, eggs, coffee, avocados.',
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      folderName: 'Personal',
    ),
  ];

  bool _isLoading = false;

  List<NoteItem> get notes {
    final sorted = List<NoteItem>.from(_notes)
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
    return sorted;
  }

  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _isLoading = false;
    notifyListeners();
  }

  NoteItem? getById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  void addOrUpdate(NoteItem note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) {
      _notes.add(note);
    } else {
      _notes[index] = note;
    }
    notifyListeners();
  }

  void delete(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void togglePin(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;
    final current = _notes[index];
    _notes[index] = current.copyWith(isPinned: !current.isPinned);
    notifyListeners();
  }
}
