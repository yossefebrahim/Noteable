import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noteable_app/data/services/export_service.dart';
import 'package:noteable_app/domain/entities/note_entity.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/presentation/providers/export_view_model.dart';
import 'package:noteable_app/presentation/screens/export/bulk_export_bottom_sheet.dart';
import 'package:noteable_app/presentation/screens/home/widgets/empty_notes_state.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.select<NotesViewModel, bool>(
      (NotesViewModel vm) => vm.isLoading,
    );

    return Stack(
      children: <Widget>[
        Consumer<NotesViewModel>(
          builder: (BuildContext context, NotesViewModel vm, _) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Notes'),
                actions: <Widget>[
                  IconButton(
                    onPressed: () => context.push('/search'),
                    icon: const Icon(Icons.search_rounded),
                  ),
                  IconButton(
                    onPressed: () => context.push('/templates'),
                    icon: const Icon(Icons.dashboard_outlined),
                  ),
                  IconButton(
                    onPressed: () => context.push('/folders'),
                    icon: const Icon(Icons.folder_outlined),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'More options',
                    onSelected: (String choice) async {
                      if (choice == 'export') {
                        await _handleBulkExport(context);
                      } else if (choice == 'settings') {
                        context.push('/settings');
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'export',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.file_download_outlined),
                            SizedBox(width: 12),
                            Text('Export all notes'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'settings',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.settings_outlined),
                            SizedBox(width: 12),
                            Text('Settings'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => context.push('/note-detail').then((_) => vm.refreshNotes()),
                icon: const Icon(Icons.add),
                label: const Text('New note'),
              ),
              body: vm.notes.isEmpty
                  ? EmptyNotesState(
                      onCreateTap: () =>
                          context.push('/note-detail').then((_) => vm.refreshNotes()),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.notes.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 12),
                      itemBuilder: (BuildContext context, int index) {
                        final NoteEntity note = vm.notes[index];
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            title: Text(note.title.isEmpty ? 'Untitled' : note.title),
                            subtitle: Text(
                              note.content.isEmpty ? 'Start writing…' : note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: IconButton(
                              tooltip: note.isPinned ? 'Unpin' : 'Pin',
                              onPressed: isLoading ? null : () => vm.togglePin(note.id),
                              icon: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                            ),
                            onTap: () => context
                                .push('/note-detail', extra: note.id)
                                .then((_) => vm.refreshNotes()),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: isLoading ? null : () => _deleteNote(context, vm, note),
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        ),
        if (isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Future<void> _deleteNote(BuildContext context, NotesViewModel vm, NoteEntity note) async {
    final noteId = note.id;
    final noteTitle = note.title.isEmpty ? 'Untitled' : note.title;

    await vm.deleteNote(noteId);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Text('$noteTitle deleted'),
        action: SnackBarAction(label: 'Undo', onPressed: () => vm.restoreNote(noteId)),
      ),
    );
  }

  Future<void> _handleBulkExport(BuildContext context) async {
    final exportVm = context.read<ExportViewModel>();

    await BulkExportBottomSheet.show(
      context,
      onExportFormatSelected: (ExportFormat format) async {
        final success = await exportVm.exportAllNotes(format.name);
        if (!context.mounted) return;
        _showExportResultSnackBar(context, success, format.name);
      },
    );
  }

  void _showExportResultSnackBar(BuildContext context, bool success, String format) {
    final message = success ? 'All notes exported as $format (ZIP)' : 'Failed to export notes';
    final snackBar = SnackBar(content: Text(message), behavior: SnackBarBehavior.floating);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
