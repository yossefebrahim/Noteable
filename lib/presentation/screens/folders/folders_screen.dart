import 'package:flutter/material.dart';
import 'package:noteable_app/domain/entities/folder_entity.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:provider/provider.dart';

class FolderScreen extends StatelessWidget {
  const FolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesViewModel>(
      builder: (BuildContext context, NotesViewModel vm, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Folders')),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _folderNameDialog(context, title: 'Create folder', onConfirm: vm.createFolder),
            child: const Icon(Icons.create_new_folder_outlined),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.folders.length,
            itemBuilder: (BuildContext context, int index) {
              final FolderEntity folder = vm.folders[index];
              return Card(
                child: ListTile(
                  title: Text(folder.name),
                  leading: const Icon(Icons.folder_outlined),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _folderNameDialog(
                          context,
                          title: 'Rename folder',
                          initial: folder.name,
                          onConfirm: (String n) => vm.renameFolder(folder.id, n),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => vm.deleteFolder(folder.id)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _folderNameDialog(
    BuildContext context, {
    required String title,
    required Future<void> Function(String) onConfirm,
    String initial = '',
  }) async {
    final TextEditingController controller = TextEditingController(text: initial);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Folder name')),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) {
      await onConfirm(controller.text);
    }
  }
}
