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

  test('updateDraft updates local note and saveNow persists', () async {
    await vm.init();

    vm.updateDraft(title: 'Hello', content: 'World');
    await vm.saveNow();

    final notes = await repo.getNotes();
    expect(notes.single.title, 'Hello');
    expect(notes.single.content, 'World');
  });

  test('dispose cancels timer safely', () async {
    await vm.init();
    vm.updateDraft(title: 'x');

    expect(() => vm.dispose(), returnsNormally);
  });
}
