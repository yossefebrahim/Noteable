import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('create/edit/delete/pin/search notes + folder flows', (tester) async {
    final note = await repo.createNote(title: 'Draft', content: 'Hello');
    await vm.load();
    expect(vm.notes.length, 1);

    await repo.updateNote(note.copyWith(title: 'Updated'));
    await vm.refreshNotes();
    expect(vm.notes.first.title, 'Updated');

    await vm.togglePin(note.id);
    expect(vm.notes.first.isPinned, isTrue);

    final search = await vm.search('updat');
    expect(search.single.id, note.id);

    await vm.createFolder('Work');
    expect(vm.folders.length, 1);

    final folderId = vm.folders.single.id;
    await vm.renameFolder(folderId, 'Office');
    expect(vm.folders.single.name, 'Office');

    await vm.deleteFolder(folderId);
    expect(vm.folders, isEmpty);

    await vm.deleteNote(note.id);
    expect(vm.notes, isEmpty);
  });

  testWidgets('repository end-to-end folder unlink on delete', (tester) async {
    final folder = await repo.createFolder('Temp');
    final created = await repo.createNote(title: 'A', content: 'B');
    final note = await repo.updateNote(created.copyWith(folderId: folder.id));

    await repo.deleteFolder(folder.id);
    final after = await repo.getNoteById(note.id);

    expect(after, isNotNull);
    expect(after!.folderId, isNull);
  });
}
