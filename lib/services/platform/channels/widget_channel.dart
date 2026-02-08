import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:noteable_app/services/di/service_locator.dart';

import '../../../data/models/note_model.dart';
import '../data_sync_service.dart';

class WidgetChannel {
  WidgetChannel();

  static const MethodChannel _channel = MethodChannel('com.example.noteable/widget');
  static const EventChannel _updateChannel = EventChannel('com.example.noteable/widget_updates');

  Stream<Map<String, dynamic>>? _widgetUpdateStream;
  DataSyncService? _dataSyncService;

  /// Initialize the widget channel and set up method handlers
  Future<void> init() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    _widgetUpdateStream = _updateChannel.receiveBroadcastStream().map(
      (dynamic event) => Map<String, dynamic>.from(event as Map),
    );

    // Get DataSyncService from service locator
    _dataSyncService = sl<DataSyncService>();
    await _dataSyncService!.init();
  }

  /// Stream of widget update requests from native side
  Stream<Map<String, dynamic>> get widgetUpdates {
    if (_widgetUpdateStream == null) {
      throw StateError('WidgetChannel not initialized. Call init() first.');
    }
    return _widgetUpdateStream!;
  }

  /// Handle method calls from native widget code
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getNotes':
        return _getNotes(call.arguments as Map<String, dynamic>?);
      case 'createNote':
        return _createNote(call.arguments as Map<String, dynamic>?);
      case 'getPinnedNotes':
        return _getPinnedNotes(call.arguments as Map<String, dynamic>?);
      case 'getRecentNotes':
        return _getRecentNotes(call.arguments as Map<String, dynamic>?);
      case 'openNote':
        return _openNote(call.arguments as Map<String, dynamic>?);
      default:
        throw MissingPluginException('Unknown method: ${call.method}');
    }
  }

  /// Get notes requested by widget
  Future<Map<String, dynamic>> _getNotes(Map<String, dynamic>? args) async {
    try {
      final limit = args?['limit'] as int? ?? 10;
      final notes = await _dataSyncService!.getNotes(limit: limit);
      return {'status': 'success', 'notes': notes};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Create a note from widget capture
  Future<Map<String, dynamic>> _createNote(Map<String, dynamic>? args) async {
    try {
      if (args == null) {
        return {'status': 'error', 'message': 'Missing note data'};
      }

      final title = args['title'] as String? ?? '';
      final content = args['content'] as String? ?? '';

      if (title.isEmpty && content.isEmpty) {
        return {'status': 'error', 'message': 'Note cannot be empty'};
      }

      final note = await _dataSyncService!.createNote(title: title, content: content);
      return {'status': 'success', 'note': note};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Get pinned notes for widget display
  Future<Map<String, dynamic>> _getPinnedNotes(Map<String, dynamic>? args) async {
    try {
      final limit = args?['limit'] as int? ?? 10;
      final notes = await _dataSyncService!.getPinnedNotes(limit: limit);
      return {'status': 'success', 'notes': notes};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Get recent notes for widget display
  Future<Map<String, dynamic>> _getRecentNotes(Map<String, dynamic>? args) async {
    try {
      final limit = args?['limit'] as int? ?? 3;
      final notes = await _dataSyncService!.getRecentNotes(limit: limit);
      return {'status': 'success', 'notes': notes};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Open a note in the app from widget (deep link)
  Future<Map<String, dynamic>> _openNote(Map<String, dynamic>? args) async {
    try {
      if (args == null) {
        return {'status': 'error', 'message': 'Missing note ID'};
      }

      final noteId = args['noteId'] as dynamic;
      // This will trigger navigation in the app
      return {'status': 'success', 'noteId': noteId};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Notify widgets that data has changed and they should refresh
  Future<void> notifyWidgetsChanged() async {
    try {
      await _channel.invokeMethod('onDataChanged');
    } catch (e) {
      debugPrint('Failed to notify widgets: $e');
    }
  }

  /// Request widgets to update their display
  Future<void> requestWidgetUpdate() async {
    try {
      await _channel.invokeMethod('requestUpdate');
    } catch (e) {
      debugPrint('Failed to request widget update: $e');
    }
  }

  /// Send note data to widget for display
  Future<void> sendNotesToWidget(List<NoteModel> notes) async {
    try {
      final notesJson = notes.map((note) => _noteToJson(note)).toList();
      await _channel.invokeMethod('updateNotes', <String, dynamic>{'notes': notesJson});
    } catch (e) {
      debugPrint('Failed to send notes to widget: $e');
    }
  }

  /// Convert NoteModel to JSON for platform channel
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

  /// Dispose of the channel handlers
  void dispose() {
    _channel.setMethodCallHandler(null);
  }
}
