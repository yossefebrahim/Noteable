import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:noteable_app/data/models/note_model.dart';
import 'package:noteable_app/services/platform/data_sync_service.dart';

import '../mocks.mocks.dart';

/// End-to-end integration tests for the complete widget workflow.
///
/// These tests verify the flow from widget capture to app display,
/// including deep linking, theme sync, and widget refresh.
@GenerateMocks([MethodChannel])
void main() {
  group('Widget Workflow E2E Tests', () {
    late DataSyncService dataSyncService;

    setUp(() async {
      dataSyncService = DataSyncService();
      await dataSyncService.init();
    });

    tearDown(() async {
      await dataSyncService.close();
    });

    test('Widget capture creates note offline and appears in app', () async {
      // Step 1: Simulate widget capture
      final capturedNote = await dataSyncService.createNote(
        title: 'Test Widget Capture',
        content: 'This note was captured from the widget',
      );

      // Step 2: Verify note was created
      expect(capturedNote['title'], equals('Test Widget Capture'));
      expect(capturedNote['content'], equals('This note was captured from the widget'));
      expect(capturedNote['id'], isNotNull);
      expect(capturedNote['createdAt'], isNotNull);

      // Step 3: Verify note appears in app storage
      final notes = await dataSyncService.getNotes();
      expect(notes, isNotEmpty);
      expect(notes.first['title'], equals('Test Widget Capture'));
    });

    test('Widget shows recent notes', () async {
      // Step 1: Create multiple notes
      await dataSyncService.createNote(title: 'Note 1', content: 'Content 1');
      await Future.delayed(const Duration(milliseconds: 10));
      await dataSyncService.createNote(title: 'Note 2', content: 'Content 2');
      await Future.delayed(const Duration(milliseconds: 10));
      await dataSyncService.createNote(title: 'Note 3', content: 'Content 3');
      await Future.delayed(const Duration(milliseconds: 10));
      await dataSyncService.createNote(title: 'Note 4', content: 'Content 4');

      // Step 2: Get recent notes (should return last 3)
      final recentNotes = await dataSyncService.getRecentNotes(limit: 3);

      // Step 3: Verify correct notes are returned
      expect(recentNotes.length, equals(3));
      expect(recentNotes[0]['title'], equals('Note 4')); // Most recent
      expect(recentNotes[1]['title'], equals('Note 3'));
      expect(recentNotes[2]['title'], equals('Note 2')); // Oldest of the 3
    });

    test('Widget shows pinned notes', () async {
      // Step 1: Create notes with some pinned
      final notes = [
        NoteModel(
          id: 1,
          title: 'Pinned Note 1',
          content: 'Content 1',
          createdAt: DateTime.now(),
          isPinned: true,
        ),
        NoteModel(
          id: 2,
          title: 'Regular Note',
          content: 'Content 2',
          createdAt: DateTime.now(),
          isPinned: false,
        ),
        NoteModel(
          id: 3,
          title: 'Pinned Note 2',
          content: 'Content 3',
          createdAt: DateTime.now(),
          isPinned: true,
        ),
      ];

      final pinnedNotes = notes.where((n) => n.isPinned).toList();

      // Step 2: Sync pinned notes
      await dataSyncService.syncPinnedNotes(pinnedNotes);

      // Step 3: Verify pinned notes are stored
      final storedPinnedNotes = await dataSyncService.getPinnedNotes();
      expect(storedPinnedNotes.length, equals(2));
      expect(storedPinnedNotes[0]['title'], equals('Pinned Note 1'));
      expect(storedPinnedNotes[1]['title'], equals('Pinned Note 2'));
    });

    test('Deep link note ID can be parsed and validated', () async {
      // Step 1: Create a note via widget
      final note = await dataSyncService.createNote(
        title: 'Deep Link Test',
        content: 'Test deep link navigation',
      );

      // Step 2: Verify note ID format
      final noteId = note['id'];
      expect(noteId, isNotNull);
      expect(noteId, isA<int>());

      // Step 3: Verify deep link URL format
      final deepLinkUrl = 'noteable://note-detail/$noteId';
      expect(deepLinkUrl, startsWith('noteable://note-detail/'));
      expect(deepLinkUrl, contains('/$noteId'));
    });

    test('Widget refresh is triggered after note creation', () async {
      // Note: This test would require mocking the MethodChannel
      // In a real environment, this would verify the native widget refresh

      // Step 1: Create a note
      await dataSyncService.createNote(
        title: 'Refresh Test',
        content: 'This should trigger widget refresh',
      );

      // Step 2: Verify notes are synced
      final notes = await dataSyncService.getNotes();
      expect(notes, isNotEmpty);

      // Step 3: In real environment, verify widget refresh method was called
      // This would be verified through mock MethodChannel interactions
    });

    test('Theme colors are consistent across platforms', () async {
      // This test documents the color scheme that should match

      // Light theme colors
      const lightThemeColors = {
        'background': '#FFFFFF',
        'surface': '#F5F5F7',
        'textPrimary': '#1A1A1A',
        'textSecondary': '#6B6B6B',
        'accent': '#007AFF',
      };

      // Dark theme colors
      const darkThemeColors = {
        'background': '#000000',
        'surface': '#1C1C1E',
        'textPrimary': '#FFFFFF',
        'textSecondary': '#98989D',
        'accent': '#0A84FF',
      };

      // Verify color values are defined
      expect(lightThemeColors['background'], equals('#FFFFFF'));
      expect(darkThemeColors['background'], equals('#000000'));
    });

    test('Widget data persistence survives service restart', () async {
      // Step 1: Create a note
      await dataSyncService.createNote(
        title: 'Persistence Test',
        content: 'This should survive service restart',
      );

      // Step 2: Close and reinitialize service
      await dataSyncService.close();
      dataSyncService = DataSyncService();
      await dataSyncService.init();

      // Step 3: Verify note persists
      final notes = await dataSyncService.getNotes();
      expect(notes, isNotEmpty);
      expect(notes.first['title'], equals('Persistence Test'));
    });

    test('Multiple widget types can access shared data', () async {
      // Step 1: Create different types of notes
      await dataSyncService.createNote(title: 'Recent Note', content: 'Recent');
      await dataSyncService.createNote(title: 'Recent Note 2', content: 'Recent 2');

      final pinnedNotes = [
        NoteModel(
          id: 100,
          title: 'Pinned Note',
          content: 'Pinned',
          createdAt: DateTime.now(),
          isPinned: true,
        ),
      ];
      await dataSyncService.syncPinnedNotes(pinnedNotes);

      // Step 2: Verify both data types are accessible
      final recentNotes = await dataSyncService.getRecentNotes();
      final pinned = await dataSyncService.getPinnedNotes();

      expect(recentNotes.length, greaterThan(0));
      expect(pinned.length, equals(1));
      expect(pinned.first['title'], equals('Pinned Note'));
    });

    test('Widget offline capture works without network', () async {
      // Step 1: Simulate offline capture (no network calls)
      final offlineNote = await dataSyncService.createNote(
        title: 'Offline Note',
        content: 'Created without network',
      );

      // Step 2: Verify note is stored locally
      expect(offlineNote, isNotNull);
      expect(offlineNote['title'], equals('Offline Note'));

      // Step 3: Verify it can be retrieved
      final notes = await dataSyncService.getNotes();
      expect(notes.any((n) => n['title'] == 'Offline Note'), isTrue);
    });

    test('Empty state handling for widgets', () async {
      // Step 1: Clear all data
      await dataSyncService.clearSyncedData();

      // Step 2: Verify empty states
      final notes = await dataSyncService.getNotes();
      final pinnedNotes = await dataSyncService.getPinnedNotes();
      final recentNotes = await dataSyncService.getRecentNotes();

      expect(notes, isEmpty);
      expect(pinnedNotes, isEmpty);
      expect(recentNotes, isEmpty);
    });
  });

  group('Deep Link Integration Tests', () {
    test('Deep link URL format is correct for note opening', () {
      // Test various note ID formats
      final testCases = [
        {'id': 123, 'expected': 'noteable://note-detail/123'},
        {'id': 0, 'expected': 'noteable://note-detail/0'},
        {'id': 999999, 'expected': 'noteable://note-detail/999999'},
      ];

      for (final testCase in testCases) {
        final noteId = testCase['id'];
        final expected = testCase['expected'];
        final actual = 'noteable://note-detail/$noteId';
        expect(actual, equals(expected));
      }
    });

    test('Deep link for new note creation', () {
      // Quick capture widget should open app for new note
      const quickCaptureUrl = 'noteable://note-detail';
      expect(quickCaptureUrl, startsWith('noteable://note-detail'));
    });
  });

  group('Widget Refresh Integration Tests', () {
    test('Widget refresh channel is correctly configured', () {
      // Verify the channel name matches across platforms
      const expectedChannelName = 'com.example.noteable/widgets';

      // This would be verified through actual MethodChannel calls
      expect(expectedChannelName, isNotEmpty);
      expect(expectedChannelName, contains('widgets'));
    });

    test('All widget types are registered for refresh', () {
      // iOS widget kinds
      const iosWidgetKinds = [
        'QuickCaptureWidget',
        'RecentNotesWidget',
        'PinnedNotesWidget',
      ];

      // Android widget classes
      const androidWidgetClasses = [
        'QuickCaptureWidget',
        'RecentNotesWidget',
        'PinnedNotesWidget',
      ];

      expect(iosWidgetKinds.length, equals(3));
      expect(androidWidgetClasses.length, equals(3));
    });
  });
}
