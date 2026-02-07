import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';

void main() {
  late InMemoryNotesFeatureRepository repo;
  late NotesViewModel vm;

  setUp(() {
    repo = InMemoryNotesFeatureRepository();
    vm = NotesViewModel(
      getNotes: GetNotesUseCase(repo),
      deleteNote: DeleteNoteUseCase(repo),
      togglePin: TogglePinUseCase(repo),
      getFolders: GetFoldersUseCase(repo),
      createFolder: CreateFolderUseCase(repo),
      renameFolder: RenameFolderUseCase(repo),
      deleteFolder: DeleteFolderUseCase(repo),
      searchNotes: SearchNotesUseCase(repo),
    );
  });

  test('load fetches notes and folders', () async {
    await repo.createFolder('Work');
    await repo.createNote(title: 'A', content: 'B');

    await vm.load();

    expect(vm.notes.length, 1);
    expect(vm.folders.length, 1);
  });

  test('deleteNote removes note', () async {
    final note = await repo.createNote(title: 'T', content: 'C');
    await vm.load();

    await vm.deleteNote(note.id);

    expect(vm.notes, isEmpty);
  });

  test('togglePin flips pin status', () async {
    final note = await repo.createNote(title: 'T', content: 'C');
    await vm.load();

    await vm.togglePin(note.id);

    expect(vm.notes.first.isPinned, isTrue);
  });

  test('create/rename/delete folder flow', () async {
    await vm.createFolder('  Ideas  ');
    expect(vm.folders.single.name, 'Ideas');

    final id = vm.folders.single.id;
    await vm.renameFolder(id, '  Brainstorm  ');
    expect(vm.folders.single.name, 'Brainstorm');

    await vm.deleteFolder(id);
    expect(vm.folders, isEmpty);
  });

  test('search returns expected notes', () async {
    await repo.createNote(title: 'Shopping', content: 'Milk');
    await repo.createNote(title: 'Work', content: 'Sprint planning');

    final result = await vm.search('milk');

    expect(result.length, 1);
    expect(result.first.title, 'Shopping');
  });
}
