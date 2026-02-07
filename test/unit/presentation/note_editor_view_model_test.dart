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

  test('init without noteId creates note', () async {
    await vm.init();

    expect(vm.hasNote, isTrue);
    expect(vm.note, isNotNull);
  });

  test('init with noteId loads existing note', () async {
    final note = await repo.createNote(title: 'Existing', content: 'Body');

    await vm.init(noteId: note.id);

    expect(vm.note!.id, note.id);
    expect(vm.note!.title, 'Existing');
  });

  test('updateDraft updates local note immediately', () async {
    await vm.init();

    vm.updateDraft(title: 'Hello', content: 'World');

    expect(vm.note?.title, 'Hello');
    expect(vm.note?.content, 'World');
  });

  test('updateDraft triggers auto-save after 300ms debounce', () async {
    await vm.init();

    vm.updateDraft(title: 'Hello');

    // Note should be updated locally immediately
    expect(vm.note?.title, 'Hello');

    // But not persisted to repository yet
    var notes = await repo.getNotes();
    expect(notes.single.title, isEmpty);

    // Wait for debounce to complete
    await Future.delayed(const Duration(milliseconds: 350));

    // Now it should be persisted
    notes = await repo.getNotes();
    expect(notes.single.title, 'Hello');
  });

  test('rapid updateDraft calls debounce timer correctly', () async {
    await vm.init();

    // Make multiple rapid updates
    vm.updateDraft(title: 'A');
    vm.updateDraft(title: 'AB');
    vm.updateDraft(title: 'ABC');

    // Wait for debounce to complete
    await Future.delayed(const Duration(milliseconds: 350));

    final notes = await repo.getNotes();
    // Should only save once with the final value
    expect(notes.single.title, 'ABC');
  });

  test('saveNow persists immediately without debounce delay', () async {
    await vm.init();

    vm.updateDraft(title: 'Hello', content: 'World');

    // saveNow should persist immediately
    await vm.saveNow();

    final notes = await repo.getNotes();
    expect(notes.single.title, 'Hello');
    expect(notes.single.content, 'World');
  });

  test('isSaving reflects current save operation', () async {
    await vm.init();

    expect(vm.isSaving, isFalse);

    final saveFuture = vm.saveNow();

    expect(vm.isSaving, isTrue);

    await saveFuture;

    expect(vm.isSaving, isFalse);
  });

  test('dispose cancels pending auto-save timer', () async {
    await vm.init();

    vm.updateDraft(title: 'Will not save');

    // Dispose immediately, canceling the timer
    vm.dispose();

    // Wait longer than debounce period
    await Future.delayed(const Duration(milliseconds: 350));

    final notes = await repo.getNotes();
    // The update should not have been saved
    expect(notes.single.title, isEmpty);
  });

  test('updateDraft with null values preserves existing values', () async {
    await vm.init();

    vm.updateDraft(title: 'Title Only');

    expect(vm.note?.title, 'Title Only');
    expect(vm.note?.content, isEmpty);

    vm.updateDraft(content: 'Content Only');

    expect(vm.note?.title, 'Title Only');
    expect(vm.note?.content, 'Content Only');
  });
}
