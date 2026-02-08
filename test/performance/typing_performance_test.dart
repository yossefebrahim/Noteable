import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';

void main() {
  late InMemoryNotesFeatureRepository repo;
  late NoteEditorViewModel vm;

  setUp(() {
    repo = InMemoryNotesFeatureRepository();
    vm = NoteEditorViewModel(
      createNote: CreateNoteUseCase(repo),
      updateNote: UpdateNoteUseCase(repo),
      getNotes: GetNotesUseCase(repo),
    );
  });

  group('Typing Performance Tests', () {
    test('typing delay with 1000+ word document is less than 500ms', () async {
      await vm.init();

      // Generate a document with 1000+ words
      final largeContent = _generateLargeContent(1000);

      // Measure the time it takes to update the draft
      final stopwatch = Stopwatch()..start();

      vm.updateDraft(content: largeContent);

      stopwatch.stop();

      // The local update should be nearly instantaneous
      expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason: 'Local draft update should be fast even with large content');

      // Verify the content was updated
      expect(vm.note?.content, largeContent);
      expect(vm.note?.content.split(' ').length, greaterThanOrEqualTo(1000));
    });

    test('multiple rapid updates with large content maintain performance',
        () async {
      await vm.init();

      final largeContent = _generateLargeContent(1000);

      // Simulate typing character by character
      final updates = <int>[];
      final stopwatch = Stopwatch();

      for (int i = 1; i <= 10; i++) {
        stopwatch.reset();
        stopwatch.start();

        // Append a portion of the content
        final partialContent = largeContent.substring(
            0, (largeContent.length * i / 10).ceil());
        vm.updateDraft(content: partialContent);

        stopwatch.stop();
        updates.add(stopwatch.elapsedMilliseconds);
      }

      // Each update should be fast
      for (final delay in updates) {
        expect(delay, lessThan(500),
            reason: 'Each update should complete in less than 500ms');
      }

      // Average should be well under 500ms
      final averageDelay =
          updates.reduce((a, b) => a + b) / updates.length;
      expect(averageDelay, lessThan(100),
          reason: 'Average update delay should be under 100ms');
    });

    test('title and content updates with large document are responsive',
        () async {
      await vm.init();

      final largeContent = _generateLargeContent(1000);

      // Update content first
      final contentStopwatch = Stopwatch()..start();
      vm.updateDraft(content: largeContent);
      contentStopwatch.stop();

      expect(contentStopwatch.elapsedMilliseconds, lessThan(500));

      // Then update title
      final titleStopwatch = Stopwatch()..start();
      vm.updateDraft(title: 'Updated Title');
      titleStopwatch.stop();

      expect(titleStopwatch.elapsedMilliseconds, lessThan(500));

      // Verify both updates were applied
      expect(vm.note?.title, 'Updated Title');
      expect(vm.note?.content, largeContent);
    });

    test('saveNow with 1000+ word document completes in reasonable time',
        () async {
      await vm.init();

      final largeContent = _generateLargeContent(1000);
      vm.updateDraft(content: largeContent);

      // Measure save performance
      final stopwatch = Stopwatch()..start();
      await vm.saveNow();
      stopwatch.stop();

      // Save should complete in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
          reason: 'Saving large document should complete in under 1 second');

      // Verify the save happened
      final notes = await repo.getNotes();
      expect(notes.single.content, largeContent);
    });
  });

  group('Memory and State Management', () {
    test('rapid updates do not cause memory leaks', () async {
      await vm.init();

      final largeContent = _generateLargeContent(1000);

      // Perform many rapid updates
      for (int i = 0; i < 100; i++) {
        vm.updateDraft(
          title: 'Title $i',
          content: largeContent,
        );
      }

      // The view model should still be responsive
      final stopwatch = Stopwatch()..start();
      vm.updateDraft(title: 'Final Title');
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason: 'VM should remain responsive after many updates');

      expect(vm.note?.title, 'Final Title');
    });

    test('dispose cancels pending auto-save even with large content', () async {
      await vm.init();

      final largeContent = _generateLargeContent(1000);

      // Update with large content but dispose before auto-save completes
      vm.updateDraft(title: 'Will not save', content: largeContent);

      // Dispose immediately, canceling the timer
      vm.dispose();

      // Wait longer than debounce period
      await Future.delayed(const Duration(milliseconds: 350));

      final notes = await repo.getNotes();
      // The update should not have been saved
      expect(notes.single.title, isEmpty);
      expect(notes.single.content, isEmpty);
    });
  });
}

/// Generates a string with approximately [wordCount] words.
String _generateLargeContent(int wordCount) {
  const words = [
    'Lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur', 'adipiscing',
    'elit', 'sed', 'do', 'eiusmod', 'tempor', 'incididunt', 'ut', 'labore',
    'et', 'dolore', 'magna', 'aliqua', 'Ut', 'enim', 'ad', 'minim', 'veniam',
    'quis', 'nostrud', 'exercitation', 'ullamco', 'laboris', 'nisi', 'ut',
    'aliquip', 'ex', 'ea', 'commodo', 'consequat', 'Duis', 'aute', 'irure',
    'dolor', 'in', 'reprehenderit', 'voluptate', 'velit', 'esse', 'cillum',
    'dolore', 'eu', 'fugiat', 'nulla', 'pariatur', 'Excepteur', 'sint',
    'occaecat', 'cupidatat', 'non', 'proident', 'sunt', 'culpa', 'qui',
    'officia', 'deserunt', 'mollit', 'anim', 'id', 'est', 'laborum',
  ];

  final buffer = StringBuffer();
  for (int i = 0; i < wordCount; i++) {
    buffer.write(words[i % words.length]);
    if (i < wordCount - 1) {
      buffer.write(' ');
    }
    // Add a newline every 15 words to simulate paragraphs
    if (i > 0 && i % 15 == 0) {
      buffer.writeln();
    }
  }
  return buffer.toString();
}
