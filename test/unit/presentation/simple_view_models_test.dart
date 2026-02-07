import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/presentation/providers/app_provider.dart';
import 'package:noteable_app/presentation/providers/folder_provider.dart';
import 'package:noteable_app/presentation/providers/note_detail_provider.dart';
import 'package:noteable_app/presentation/providers/note_provider.dart';
import 'package:noteable_app/presentation/providers/search_provider.dart';

void main() {
  group('AppProvider', () {
    test('toggleDarkMode updates theme mode', () {
      final vm = AppProvider();
      vm.toggleDarkMode(true);
      expect(vm.themeMode, ThemeMode.dark);
      vm.toggleDarkMode(false);
      expect(vm.themeMode, ThemeMode.light);
    });
  });

  group('FolderViewModel', () {
    test('addFolder adds trimmed name', () {
      final vm = FolderViewModel();
      final initial = vm.folders.length;
      vm.addFolder('  New Folder  ');
      expect(vm.folders.length, initial + 1);
      expect(vm.folders.last.name, 'New Folder');
    });
  });

  group('SearchViewModel', () {
    test('results filtered by title/content and hasQuery', () {
      final vm = SearchViewModel();
      vm.bindNotes([
        NoteItem(id: '1', title: 'Alpha', content: 'first', updatedAt: DateTime.now()),
        NoteItem(id: '2', title: 'Beta', content: 'contains magic', updatedAt: DateTime.now()),
      ]);
      vm.updateQuery('magic');
      expect(vm.hasQuery, isTrue);
      expect(vm.results.single.id, '2');
    });
  });

  group('NoteListViewModel', () {
    test('add/update/delete/togglePin flow', () {
      final vm = NoteListViewModel();
      vm.addOrUpdate(NoteItem(id: 'x', title: 'x', content: 'x', updatedAt: DateTime.now()));
      expect(vm.getById('x'), isNotNull);
      vm.togglePin('x');
      expect(vm.getById('x')!.isPinned, isTrue);
      vm.delete('x');
      expect(vm.getById('x'), isNull);
    });
  });

  group('NoteDetailViewModel', () {
    test('createNew and save generate untitled when title empty', () async {
      final vm = NoteDetailViewModel();
      vm.createNew(initialFolder: 'Work');
      vm.updateContent('body');
      final saved = await vm.save();
      expect(saved.title, 'Untitled Note');
      expect(saved.folderName, 'Work');
    });

    test('setFromNote toggles editing mode', () {
      final vm = NoteDetailViewModel();
      vm.setFromNote(
        NoteItem(id: '1', title: 't', content: 'c', updatedAt: DateTime.now(), isPinned: true),
      );
      expect(vm.isEditing, isTrue);
      expect(vm.isPinned, isTrue);
      vm.togglePin();
      expect(vm.isPinned, isFalse);
    });
  });
}
