import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/presentation/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

Future<NotesViewModel> _buildVm() async {
  final repo = InMemoryNotesFeatureRepository();
  await repo.createNote(title: 'First', content: 'Body');
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

Widget _app(NotesViewModel vm) {
  final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, __) => const HomeScreen())]);
  return ChangeNotifierProvider.value(
    value: vm,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('HomeScreen renders notes and new note button', (tester) async {
    final vm = await _buildVm();
    await tester.pumpWidget(_app(vm));

    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('New note'), findsOneWidget);
  });

  testWidgets('HomeScreen pin button toggles tooltip', (tester) async {
    final vm = await _buildVm();
    await tester.pumpWidget(_app(vm));

    expect(find.byTooltip('Pin'), findsOneWidget);
    await tester.tap(find.byTooltip('Pin'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Unpin'), findsOneWidget);
  });
}
