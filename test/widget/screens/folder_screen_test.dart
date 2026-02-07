import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/presentation/screens/folders/folders_screen.dart';
import 'package:provider/provider.dart';

Future<NotesViewModel> _buildVm() async {
  final repo = InMemoryNotesFeatureRepository();
  await repo.createFolder('Work');
  final vm = NotesViewModel(
    getNotes: GetNotesUseCase(repo),
    deleteNote: DeleteNoteUseCase(repo),
    togglePin: TogglePinUseCase(repo),
    getFolders: GetFoldersUseCase(repo),
    createFolder: CreateFolderUseCase(repo),
    renameFolder: RenameFolderUseCase(repo),
    deleteFolder: DeleteFolderUseCase(repo),
    searchNotes: SearchNotesUseCase(repo),
  );
  await vm.load();
  return vm;
}

void main() {
  testWidgets('FolderScreen shows folders', (tester) async {
    final vm = await _buildVm();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: const MaterialApp(home: FolderScreen()),
      ),
    );

    expect(find.text('Folders'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });
}
