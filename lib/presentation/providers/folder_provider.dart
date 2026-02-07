import 'package:flutter/foundation.dart';

class FolderItem {
  FolderItem({
    required this.id,
    required this.name,
    required this.noteCount,
    required this.colorHex,
  });

  final String id;
  final String name;
  final int noteCount;
  final String colorHex;
}

class FolderViewModel extends ChangeNotifier {
  final List<FolderItem> _folders = <FolderItem>[
    FolderItem(id: 'f1', name: 'Work', noteCount: 12, colorHex: '#007AFF'),
    FolderItem(id: 'f2', name: 'Personal', noteCount: 8, colorHex: '#34C759'),
    FolderItem(id: 'f3', name: 'Ideas', noteCount: 3, colorHex: '#AF52DE'),
    FolderItem(id: 'f4', name: 'Archive', noteCount: 24, colorHex: '#FF9500'),
  ];

  List<FolderItem> get folders => List.unmodifiable(_folders);

  void addFolder(String name, {String colorHex = '#007AFF'}) {
    if (name.trim().isEmpty) return;
    _folders.add(
      FolderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        noteCount: 0,
        colorHex: colorHex,
      ),
    );
    notifyListeners();
  }
}
