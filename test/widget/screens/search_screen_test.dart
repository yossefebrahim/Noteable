import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/presentation/screens/search/search_screen.dart';
import 'package:provider/provider.dart';

Future<NotesViewModel> _buildVm() async {
  final repo = InMemoryNotesFeatureRepository();
  await repo.createNote(title: 'Shopping', content: 'Milk');
  await repo.createNote(title: 'Work', content: 'Planning');
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
  testWidgets('SearchScreen filters notes', (tester) async {
    final vm = await _buildVm();
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, __) => const SearchScreen())]);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(find.text('Shopping'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Milk');
    await tester.pumpAndSettle();
    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Work'), findsNothing);
  });
}
