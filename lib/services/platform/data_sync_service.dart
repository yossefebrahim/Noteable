import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/note_model.dart';

/// Service for syncing notes to app group storage for widget access.
///
/// On iOS, uses app group container to share data between app and widgets.
/// On Android, uses shared preferences or files accessible by widgets.
class DataSyncService {
  DataSyncService();

  static const String _appGroupIdentifier = 'group.com.example.noteable';
  static const String _notesFileName = 'widget_notes.json';
  static const String _pinnedNotesFileName = 'widget_pinned_notes.json';

  Directory? _appGroupDirectory;

  /// Initialize the data sync service and set up app group directory
  Future<void> init() async {
    if (_appGroupDirectory != null) return;

    try {
      if (Platform.isIOS) {
        // iOS: Use app group container
        final appGroupDir = await getApplicationGroupDirectory();
        _appGroupDirectory = appGroupDir;
      } else if (Platform.isAndroid) {
        // Android: Use application documents directory
        // Widgets can access this via file provider
        final appDocDir = await getApplicationDocumentsDirectory();
        _appGroupDirectory = appDocDir;
      }

      // Ensure directory exists
      if (_appGroupDirectory != null && !_appGroupDirectory!.existsSync()) {
        await _appGroupDirectory!.create(recursive: true);
      }
    } catch (e) {
      debugPrint('Failed to initialize DataSyncService: $e');
      rethrow;
    }
  }

  /// Get the app group directory
  Future<Directory> get _directory async {
    await init();
    if (_appGroupDirectory == null) {
      throw StateError('DataSyncService not initialized properly');
    }
    return _appGroupDirectory!;
  }

  /// Save all notes to app group storage
  Future<void> syncNotes(List<NoteModel> notes) async {
    try {
      final dir = await _directory;
      final file = File('${dir.path}/$_notesFileName');

      final notesJson = notes.map((note) => _noteToJson(note)).toList();
      final jsonString = jsonEncode(notesJson);

      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Failed to sync notes: $e');
      rethrow;
    }
  }

  /// Sync pinned notes separately for quick widget access
  Future<void> syncPinnedNotes(List<NoteModel> pinnedNotes) async {
    try {
      final dir = await _directory;
      final file = File('${dir.path}/$_pinnedNotesFileName');

      final notesJson = pinnedNotes.map((note) => _noteToJson(note)).toList();
      final jsonString = jsonEncode(notesJson);

      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Failed to sync pinned notes: $e');
      rethrow;
    }
  }

  /// Get all notes from app group storage
  Future<List<Map<String, dynamic>>> getNotes({int limit = 10}) async {
    try {
      final dir = await _directory;
      final file = File('${dir.path}/$_notesFileName');

      if (!file.existsSync()) {
        return <Map<String, dynamic>>[];
      }

      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      var notes = jsonList.cast<Map<String, dynamic>>();

      if (limit > 0 && notes.length > limit) {
        notes = notes.sublist(0, limit);
      }

      return notes;
    } catch (e) {
      debugPrint('Failed to get notes: $e');
      return <Map<String, dynamic>>[];
    }
  }

  /// Get pinned notes from app group storage
  Future<List<Map<String, dynamic>>> getPinnedNotes({int limit = 10}) async {
    try {
      final dir = await _directory;
      final file = File('${dir.path}/$_pinnedNotesFileName');

      if (!file.existsSync()) {
        return <Map<String, dynamic>>[];
      }

      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      var notes = jsonList.cast<Map<String, dynamic>>();

      if (limit > 0 && notes.length > limit) {
        notes = notes.sublist(0, limit);
      }

      return notes;
    } catch (e) {
      debugPrint('Failed to get pinned notes: $e');
      return <Map<String, dynamic>>[];
    }
  }

  /// Get recent notes (sorted by creation date)
  Future<List<Map<String, dynamic>>> getRecentNotes({int limit = 3}) async {
    try {
      final allNotes = await getNotes(limit: 0);

      // Sort by createdAt descending
      allNotes.sort((a, b) {
        final aDate = DateTime.parse(a['createdAt'] as String);
        final bDate = DateTime.parse(b['createdAt'] as String);
        return bDate.compareTo(aDate);
      });

      if (limit > 0 && allNotes.length > limit) {
        return allNotes.sublist(0, limit);
      }

      return allNotes;
    } catch (e) {
      debugPrint('Failed to get recent notes: $e');
      return <Map<String, dynamic>>[];
    }
  }

  /// Create a new note from widget capture
  Future<Map<String, dynamic>> createNote({
    required String title,
    required String content,
  }) async {
    try {
      final now = DateTime.now();
      final note = <String, dynamic>{
        'id': now.millisecondsSinceEpoch, // Use timestamp as temporary ID
        'title': title,
        'content': content,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isPinned': false,
        'folderId': null,
      };

      // Add to existing notes
      final existingNotes = await getNotes(limit: 0);
      existingNotes.insert(0, note);

      // Save back to storage
      await syncNotesFromJson(existingNotes);

      return note;
    } catch (e) {
      debugPrint('Failed to create note: $e');
      rethrow;
    }
  }

  /// Save notes from JSON list (used by createNote)
  Future<void> syncNotesFromJson(List<Map<String, dynamic>> notesJson) async {
    try {
      final dir = await _directory;
      final file = File('${dir.path}/$_notesFileName');

      final jsonString = jsonEncode(notesJson);
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Failed to sync notes from JSON: $e');
      rethrow;
    }
  }

  /// Clear all synced data (useful for testing or logout)
  Future<void> clearSyncedData() async {
    try {
      final dir = await _directory;
      final notesFile = File('${dir.path}/$_notesFileName');
      final pinnedFile = File('${dir.path}/$_pinnedNotesFileName');

      if (notesFile.existsSync()) {
        await notesFile.delete();
      }
      if (pinnedFile.existsSync()) {
        await pinnedFile.delete();
      }
    } catch (e) {
      debugPrint('Failed to clear synced data: $e');
      rethrow;
    }
  }

  /// Check if app group storage is available
  Future<bool> isAvailable() async {
    try {
      final dir = await _directory;
      return dir.existsSync();
    } catch (e) {
      return false;
    }
  }

  /// Convert NoteModel to JSON
  Map<String, dynamic> _noteToJson(NoteModel note) {
    return <String, dynamic>{
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt?.toIso8601String(),
      'isPinned': note.isPinned,
      'folderId': note.folderId,
    };
  }

  /// Close the service and cleanup resources
  Future<void> close() async {
    _appGroupDirectory = null;
  }
}
