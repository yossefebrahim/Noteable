import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/data/models/note_model.dart';
import 'package:noteable_app/data/services/export_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ExportService exportService;
  late NoteModel testNote;

  setUp(() {
    exportService = ExportService();

    // Create a test note with title and content
    testNote = NoteModel(
      id: 1,
      title: 'Share Test Note',
      content: 'This is a note meant for sharing.\nIt has multiple lines of content.',
      createdAt: DateTime(2024, 1, 15, 10, 30),
      updatedAt: DateTime(2024, 1, 16, 14, 20),
      isPinned: false,
      folderId: null,
    );
  });

  group('Native Share - Shareable Content Generation', () {
    testWidgets('generates shareable content with title and content', (tester) async {
      final content = await exportService.getShareableContent(testNote);

      // Verify title and content are both included
      expect(content, contains('Share Test Note'));
      expect(content, contains('This is a note meant for sharing.'));

      // Verify separator between title and content (double newline)
      expect(content, contains('\n\n'));
    });

    testWidgets('generates shareable content for title-only note', (tester) async {
      final titleOnlyNote = NoteModel(
        id: 2,
        title: 'Only Title Note',
        content: '',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(titleOnlyNote);

      expect(content, contains('Only Title Note'));
      expect(content, isNot(contains('\n\n')));
    });

    testWidgets('generates shareable content for content-only note', (tester) async {
      final contentOnlyNote = NoteModel(
        id: 3,
        title: '',
        content: 'Only content without title',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(contentOnlyNote);

      expect(content, contains('Only content without title'));
      expect(content, isNot(contains('\n\n')));
    });

    testWidgets('handles empty note for shareable content', (tester) async {
      final emptyNote = NoteModel(
        id: 4,
        title: '',
        content: '',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(emptyNote);

      expect(content, isEmpty);
    });

    testWidgets('preserves multiline content in shareable format', (tester) async {
      final multilineNote = NoteModel(
        id: 5,
        title: 'Multiline Note',
        content: 'Line 1\nLine 2\nLine 3\nLine 4',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(multilineNote);

      expect(content, contains('Multiline Note'));
      expect(content, contains('Line 1\nLine 2\nLine 3\nLine 4'));
      expect(content, contains('\n\n')); // Separator between title and content
    });

    testWidgets('handles special characters in shareable content', (tester) async {
      final specialCharNote = NoteModel(
        id: 6,
        title: 'Note with <special> & "characters"',
        content: 'Content with special chars: @#\$%^&*()',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(specialCharNote);

      expect(content, contains('Note with <special> & "characters"'));
      expect(content, contains('Content with special chars'));
    });

    testWidgets('handles unicode characters in shareable content', (tester) async {
      final unicodeNote = NoteModel(
        id: 7,
        title: 'Unicode Note 🌍',
        content: 'Hello 世界\nПривет мир\nمرحبا بالعالم',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(unicodeNote);

      expect(content, contains('Unicode Note 🌍'));
      expect(content, contains('Hello 世界'));
      expect(content, contains('Привет мир'));
      expect(content, contains('مرحبا بالعالم'));
    });

    testWidgets('handles very long content for sharing', (tester) async {
      final longContent = 'Line of content\n' * 100; // 100 lines
      final longContentNote = NoteModel(
        id: 8,
        title: 'Long Content Note',
        content: longContent,
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(longContentNote);

      expect(content, contains('Long Content Note'));
      expect(content.length, greaterThan(1000));
    });
  });

  group('Native Share - Edge Cases', () {
    testWidgets('handles pinned notes for sharing', (tester) async {
      final pinnedNote = NoteModel(
        id: 9,
        title: 'Pinned Note',
        content: 'This note is pinned',
        createdAt: DateTime.now(),
        isPinned: true,
      );

      final content = await exportService.getShareableContent(pinnedNote);

      expect(content, contains('Pinned Note'));
      expect(content, contains('This note is pinned'));
    });

    testWidgets('handles notes with folder assignment for sharing', (tester) async {
      final folderNote = NoteModel(
        id: 10,
        title: 'Folder Note',
        content: 'Note in a folder',
        createdAt: DateTime.now(),
        isPinned: false,
        folderId: 'work_folder',
      );

      final content = await exportService.getShareableContent(folderNote);

      expect(content, contains('Folder Note'));
      expect(content, contains('Note in a folder'));
      // Folder ID should not appear in shareable content
      expect(content, isNot(contains('work_folder')));
    });

    testWidgets('handles notes with different timestamps for sharing', (tester) async {
      final oldNote = NoteModel(
        id: 11,
        title: 'Old Note',
        content: 'Created long ago',
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2021, 5, 15),
        isPinned: false,
      );

      final recentNote = NoteModel(
        id: 12,
        title: 'Recent Note',
        content: 'Just created',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPinned: false,
      );

      final oldContent = await exportService.getShareableContent(oldNote);
      final recentContent = await exportService.getShareableContent(recentNote);

      expect(oldContent, contains('Old Note'));
      expect(recentContent, contains('Recent Note'));
      // Timestamps should not appear in shareable content
      expect(oldContent, isNot(contains('2020')));
      expect(recentContent, isNot(contains(DateTime.now().year.toString())));
    });

    testWidgets('handles notes with null updatedAt for sharing', (tester) async {
      final noUpdateNote = NoteModel(
        id: 13,
        title: 'Never Updated',
        content: 'Created but never modified',
        createdAt: DateTime.now(),
        updatedAt: null,
        isPinned: false,
      );

      final content = await exportService.getShareableContent(noUpdateNote);

      expect(content, contains('Never Updated'));
      expect(content, contains('Created but never modified'));
    });

    testWidgets('handles very long title for sharing', (tester) async {
      final longTitleNote = NoteModel(
        id: 14,
        title: 'A' * 500,
        content: 'Content',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(longTitleNote);

      expect(content.length, greaterThan(500));
      expect(content, contains('Content'));
    });

    testWidgets('handles content with special formatting', (tester) async {
      final formattedNote = NoteModel(
        id: 15,
        title: 'Formatted Note',
        content: '• Bullet point\n\t- Indented\n\nDouble newline',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(formattedNote);

      expect(content, contains('• Bullet point'));
      expect(content, contains('\t- Indented'));
      // Note: Double newlines in content are preserved
      expect(content, contains('\n\n'));
    });
  });

  group('Native Share - Content Format Verification', () {
    testWidgets('shareable content format matches expected pattern', (tester) async {
      final content = await exportService.getShareableContent(testNote);

      // Verify content structure: Title + separator + Content
      final expectedPattern = 'Share Test Note\\n\\nThis is a note meant for sharing';
      expect(content, matches(RegExp(expectedPattern)));
    });

    testWidgets('shareable content is plain text (no markdown)', (tester) async {
      final markdownNote = NoteModel(
        id: 16,
        title: '# Markdown Title',
        content: '**Bold** and *italic*',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(markdownNote);

      // Content should be plain text, not markdown formatted
      expect(content, contains('# Markdown Title')); // Title preserved as-is
      expect(content, contains('**Bold** and *italic*')); // Content preserved as-is
      // No markdown processing/sharing specific formatting applied
    });

    testWidgets('shareable content suitable for email sharing', (tester) async {
      final emailNote = NoteModel(
        id: 17,
        title: 'Meeting Notes',
        content: 'Discussed project timeline\nAction items:\n1. Review docs\n2. Update design',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(emailNote);

      // Content should be readable and suitable for email body
      expect(content, contains('Meeting Notes'));
      expect(content, contains('Discussed project timeline'));
      expect(content, contains('Action items:'));
      expect(content, contains('\n')); // Newlines preserved for readability
    });

    testWidgets('shareable content suitable for messaging apps', (tester) async {
      final messageNote = NoteModel(
        id: 18,
        title: 'Quick reminder',
        content: 'Buy milk\nCall mom\n3pm meeting',
        createdAt: DateTime.now(),
        isPinned: false,
      );

      final content = await exportService.getShareableContent(messageNote);

      // Content should be concise and suitable for messaging
      expect(content, contains('Quick reminder'));
      expect(content, contains('Buy milk'));
      expect(content, contains('Call mom'));
    });
  });

  group('Native Share - Use Case Integration', () {
    testWidgets('ShareNoteUseCase returns correct result format', (tester) async {
      // This test verifies the format that ShareNoteUseCase would return
      // The use case calls ExportService.getShareableContent() internally
      final content = await exportService.getShareableContent(testNote);

      // Verify content is non-empty string
      expect(content, isA<String>());
      expect(content, isNotEmpty);

      // Verify content contains expected elements
      expect(content, contains(testNote.title));
      expect(content, contains(testNote.content));
    });

    testWidgets('shareable content can be passed to Share.share()', (tester) async {
      final content = await exportService.getShareableContent(testNote);

      // Verify the content format is compatible with Share.share()
      // Share.share() expects a String, so we verify type and non-empty
      expect(content, isA<String>());
      expect(content, isNotEmpty);

      // Note: We cannot actually call Share.share() in tests as it requires
      // platform-specific code. However, the content format is verified to be
      // compatible with the Share.share() API.
      // In production, the code in note_detail_screen.dart will call:
      // await Share.share(exportVm.shareableContent!);
    });
  });
}
