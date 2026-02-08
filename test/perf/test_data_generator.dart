import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:noteable_app/data/models/note_model.dart';

/// Test data generator for creating large numbers of notes for performance testing.
///
/// This generator creates realistic test data with varied content to simulate
/// real-world usage patterns for performance and regression testing.
class TestDataGenerator {
  /// Generates a list of [count] note models with realistic test data.
  ///
  /// Parameters:
  /// - [count]: The number of notes to generate (typically 1000+ for perf tests)
  /// - [baseDate]: The base date for note creation timestamps (defaults to now)
  /// - [folderId]: Optional folder ID to assign to generated notes
  ///
  /// Returns a list of [NoteModel] instances ready for insertion into Isar.
  static List<NoteModel> generateNotes({
    required int count,
    DateTime? baseDate,
    String? folderId,
  }) {
    final now = baseDate ?? DateTime.now();
    final notes = <NoteModel>[];
    final random = _TestRandom();

    for (int i = 0; i < count; i++) {
      // Vary creation times across a 6-month period
      final daysOffset = random.nextInt(180);
      final createdAt = now.subtract(Duration(days: daysOffset));

      // 10% of notes are pinned
      final isPinned = random.nextDouble() < 0.1;

      // Generate title and content
      final title = _generateTitle(i, random);
      final content = _generateContent(i, random);

      notes.add(NoteModel(
        id: Isar.autoIncrement,
        title: title,
        content: content,
        createdAt: createdAt,
        updatedAt: isPinned ? createdAt.add(Duration(hours: random.nextInt(24))) : null,
        isPinned: isPinned,
        folderId: folderId,
      ));
    }

    return notes;
  }

  /// Generates a single note with specific parameters.
  ///
  /// Useful for creating specific test scenarios.
  static NoteModel generateSingleNote({
    required int index,
    DateTime? createdAt,
    String? title,
    String? content,
    bool isPinned = false,
    String? folderId,
  }) {
    final random = _TestRandom();
    return NoteModel(
      id: Isar.autoIncrement,
      title: title ?? _generateTitle(index, random),
      content: content ?? _generateContent(index, random),
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: isPinned ? DateTime.now() : null,
      isPinned: isPinned,
      folderId: folderId,
    );
  }

  /// Generates a batch of notes organized by folders.
  ///
  /// Creates notes distributed across [folderCount] folders.
  /// Returns a map of folderId to list of notes in that folder.
  static Map<String?, List<NoteModel>> generateNotesInFolders({
    required int totalNotes,
    required int folderCount,
  }) {
    final folderIds = List.generate(
      folderCount,
      (i) => 'folder-test-$i',
    );

    final notesByFolder = <String?, List<NoteModel>>{};
    final random = _TestRandom();

    // Initialize folder lists
    for (final folderId in folderIds) {
      notesByFolder[folderId] = [];
    }
    notesByFolder[null] = []; // Notes without folder

    // Distribute notes across folders
    for (int i = 0; i < totalNotes; i++) {
      final folderIndex = random.nextInt(folderCount + 1); // +1 for null folder
      final folderId = folderIndex < folderCount ? folderIds[folderIndex] : null;

      final note = generateSingleNote(
        index: i,
        folderId: folderId,
      );

      notesByFolder[folderId]!.add(note);
    }

    return notesByFolder;
  }

  /// Generates a title for a test note.
  static String _generateTitle(int index, _TestRandom random) {
    final prefixes = [
      'Meeting',
      'Project',
      'Idea',
      'Task',
      'Reminder',
      'Shopping',
      'Recipe',
      'Travel',
      'Book',
      'Movie',
    ];

    final suffixes = [
      'Notes',
      'Summary',
      'Details',
      'Plan',
      'List',
      'Ideas',
      'Thoughts',
      'Draft',
      'Outline',
      'Review',
    ];

    final prefix = prefixes[random.nextInt(prefixes.length)];
    final suffix = suffixes[random.nextInt(suffixes.length)];
    final number = random.nextInt(100);

    // Mix different title patterns
    final pattern = random.nextInt(4);
    switch (pattern) {
      case 0:
        return '$prefix $suffix #$number';
      case 1:
        return '$prefix: $suffix';
      case 2:
        return '$suffix for $prefix';
      case 3:
        return '$prefix $number - $suffix';
      default:
        return 'Note $index';
    }
  }

  /// Generates content for a test note.
  static String _generateContent(int index, _TestRandom random) {
    final shortPhrases = [
      'Quick reminder about the project deadline.',
      'Discuss the new feature requirements.',
      'Review the documentation updates.',
      'Prepare for the upcoming meeting.',
      'Follow up on the action items.',
      'Update the team on progress.',
      'Draft email to stakeholders.',
      'Summary of key points discussed.',
      'Notes from the conference call.',
      'Ideas for the next sprint.',
    ];

    final longPhrases = [
      '''Project Overview
This project aims to deliver a comprehensive solution for note-taking with advanced features including search, organization, and synchronization.

Key Features:
- Rich text editing
- Cross-platform support
- Cloud synchronization
- Offline access
- Advanced search capabilities

Next Steps:
1. Finalize UI design
2. Implement core features
3. Add testing
4. Deploy to production''',
      '''Meeting Notes - Team Standup
Date: ${DateTime.now().toLocal()}
Attendees: Development Team

Agenda:
- Sprint progress review
- Blocker discussion
- Plan for next iteration

Action Items:
- Complete API integration
- Fix navigation bug
- Update documentation''',
      '''Shopping List
Groceries:
- Milk and dairy products
- Fresh fruits and vegetables
- Bread and bakery items
- Pasta and rice
- Canned goods

Household:
- Cleaning supplies
- Paper towels
- Laundry detergent
- Light bulbs''',
      '''Book Summary: "The Pragmatic Programmer"
Key Takeaways:
- Care about your craft
- Think about your work
- Learn continuously
- Invest in your knowledge

Favorite Quotes:
- "Programming is more than just writing code."
- "The best code is no code at all."

Recommendation: Highly recommended for developers at all levels.''',
      '''Travel Itinerary: Summer Trip
Day 1: Arrival and check-in
Day 2: City tour and museums
Day 3: Outdoor activities
Day 4: Local cuisine exploration
Day 5: Departure

Packing List:
- Passport and documents
- Comfortable clothing
- Camera
- Travel adapter
- Toiletries''',
    ];

    // Mix content lengths
    final contentPattern = random.nextInt(10);
    if (contentPattern < 5) {
      // Short content (50%)
      return shortPhrases[random.nextInt(shortPhrases.length)];
    } else if (contentPattern < 8) {
      // Medium content (30%)
      return '${shortPhrases[random.nextInt(shortPhrases.length)]}\n\n'
          '${shortPhrases[random.nextInt(shortPhrases.length)]}';
    } else {
      // Long content (20%)
      return longPhrases[random.nextInt(longPhrases.length)];
    }
  }
}

/// Simple random number generator for consistent test data generation.
///
/// Uses a simple LCG algorithm for predictable but varied output.
class _TestRandom {
  static const int _a = 1664525;
  static const int _c = 1013904223;
  static const int _m = 1 << 32;

  int _state = DateTime.now().millisecondsSinceEpoch;

  /// Returns the next random integer in range [0, max).
  int nextInt(int max) {
    _state = (_a * _state + _c) % _m;
    return _state % max;
  }

  /// Returns the next random double in range [0, 1).
  double nextDouble() {
    return nextInt(_m) / _m;
  }
}

void main() {
  group('TestDataGenerator', () {
    test('generates specified number of notes', () {
      final notes = TestDataGenerator.generateNotes(count: 100);
      expect(notes, hasLength(100));
    });

    test('generates notes with required fields', () {
      final notes = TestDataGenerator.generateNotes(count: 10);
      for (final note in notes) {
        expect(note.title, isNotEmpty);
        expect(note.content, isNotEmpty);
        expect(note.createdAt, isNotNull);
      }
    });

    test('generates 1000+ notes for performance testing', () {
      final notes = TestDataGenerator.generateNotes(count: 1000);
      expect(notes, hasLength(greaterThanOrEqualTo(1000)));

      // Verify all notes have valid data
      for (final note in notes) {
        expect(note.title, isNotEmpty);
        expect(note.content, isNotEmpty);
        expect(note.createdAt.isBefore(DateTime.now()), isTrue);
      }
    });

    test('generates notes with varied content', () {
      final notes = TestDataGenerator.generateNotes(count: 100);
      final titles = notes.map((n) => n.title).toSet();
      final contents = notes.map((n) => n.content).toSet();

      // Should have variety in titles and content
      expect(titles.length, greaterThan(10));
      expect(contents.length, greaterThan(10));
    });

    test('generates notes with folder assignment', () {
      final notes = TestDataGenerator.generateNotes(
        count: 50,
        folderId: 'test-folder',
      );

      for (final note in notes) {
        expect(note.folderId, 'test-folder');
      }
    });

    test('generates single note with custom parameters', () {
      final note = TestDataGenerator.generateSingleNote(
        index: 1,
        title: 'Custom Title',
        content: 'Custom Content',
        isPinned: true,
        folderId: 'custom-folder',
      );

      expect(note.title, 'Custom Title');
      expect(note.content, 'Custom Content');
      expect(note.isPinned, isTrue);
      expect(note.folderId, 'custom-folder');
    });

    test('generates notes distributed across folders', () {
      final notesByFolder = TestDataGenerator.generateNotesInFolders(
        totalNotes: 100,
        folderCount: 5,
      );

      // Should have 5 folders plus null folder
      expect(notesByFolder.keys, hasLength(6));

      // Total notes should match
      final totalNotes = notesByFolder.values.fold<int>(
        0,
        (sum, notes) => sum + notes.length,
      );
      expect(totalNotes, 100);
    });

    test('generates notes with pinned status distribution', () {
      final notes = TestDataGenerator.generateNotes(count: 1000);
      final pinnedCount = notes.where((n) => n.isPinned).length;

      // Approximately 10% should be pinned (allowing some variance)
      expect(pinnedCount, greaterThan(50));
      expect(pinnedCount, lessThan(150));
    });

    test('generates notes with valid date range', () {
      final baseDate = DateTime(2026, 1, 15);
      final notes = TestDataGenerator.generateNotes(
        count: 100,
        baseDate: baseDate,
      );

      for (final note in notes) {
        // All notes should be within 180 days before baseDate
        final daysDiff = baseDate.difference(note.createdAt).inDays;
        expect(daysDiff, greaterThanOrEqualTo(0));
        expect(daysDiff, lessThanOrEqualTo(180));
      }
    });

    test('generates realistic long content for performance testing', () {
      final notes = TestDataGenerator.generateNotes(count: 100);

      // Some notes should have longer content (multi-line)
      final longContentNotes = notes.where(
        (n) => n.content.contains('\n'),
      );

      expect(longContentNotes.length, greaterThan(20));
    });

    test('handles edge case of single note generation', () {
      final notes = TestDataGenerator.generateNotes(count: 1);
      expect(notes, hasLength(1));
      expect(notes.first.title, isNotEmpty);
      expect(notes.first.content, isNotEmpty);
    });

    test('handles edge case of zero notes', () {
      final notes = TestDataGenerator.generateNotes(count: 0);
      expect(notes, isEmpty);
    });
  });
}
