import 'package:flutter/foundation.dart';

import 'note_provider.dart';

class SearchViewModel extends ChangeNotifier {
  String _query = '';
  List<NoteItem> _allNotes = <NoteItem>[];

  String get query => _query;

  void bindNotes(List<NoteItem> notes) {
    _allNotes = notes;
    notifyListeners();
  }

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  List<NoteItem> get results {
    if (_query.trim().isEmpty) return _allNotes;
    final q = _query.toLowerCase();
    return _allNotes.where((note) {
      return note.title.toLowerCase().contains(q) || note.content.toLowerCase().contains(q);
    }).toList();
  }

  bool get hasQuery => _query.trim().isNotEmpty;
}
