import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noteable_app/domain/entities/note_entity.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/presentation/screens/home/widgets/empty_notes_state.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.select<NotesViewModel, bool>((NotesViewModel vm) => vm.isLoading);

    return Stack(
      children: <Widget>[
        Consumer<NotesViewModel>(
          builder: (BuildContext context, NotesViewModel vm, _) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Notes'),
                actions: <Widget>[
                  IconButton(onPressed: () => context.push('/search'), icon: const Icon(Icons.search_rounded)),
                  IconButton(onPressed: () => context.push('/templates'), icon: const Icon(Icons.dashboard_outlined)),
                  IconButton(onPressed: () => context.push('/folders'), icon: const Icon(Icons.folder_outlined)),
                  IconButton(onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings_outlined)),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => context.push('/note-detail').then((_) => vm.refreshNotes()),
                icon: const Icon(Icons.add),
                label: const Text('New note'),
              ),
              body: vm.notes.isEmpty
                  ? const Center(child: Text('No notes yet. Tap "New note"'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.notes.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 12),
                      itemBuilder: (BuildContext context, int index) {
                        final NoteEntity note = vm.notes[index];
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            title: Text(note.title.isEmpty ? 'Untitled' : note.title),
                            subtitle: Text(note.content.isEmpty ? 'Start writing…' : note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                            leading: IconButton(
                              tooltip: note.isPinned ? 'Unpin' : 'Pin',
                              onPressed: isLoading ? null : () => vm.togglePin(note.id),
                              icon: Text(note.isPinned ? '📌' : '📍', style: const TextStyle(fontSize: 18)),
                            ),
                            onTap: () => context.push('/note-detail', extra: note.id).then((_) => vm.refreshNotes()),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: isLoading ? null : () => _confirmDelete(context, vm, note),
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
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          body: vm.notes.isEmpty
              ? EmptyNotesState(
                  onCreateTap: () => context.push('/note-detail').then((_) => vm.refreshNotes()),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.notes.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final NoteEntity note = vm.notes[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(note.title.isEmpty ? 'Untitled' : note.title),
                        subtitle: Text(note.content.isEmpty ? 'Start writing…' : note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                        leading: IconButton(
                          tooltip: note.isPinned ? 'Unpin' : 'Pin',
                          onPressed: () => vm.togglePin(note.id),
                          icon: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                        ),
                        onTap: () => context.push('/note-detail', extra: note.id).then((_) => vm.refreshNotes()),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteNote(context, vm, note),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
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
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => vm.restoreNote(noteId),
        ),
      ),
    );
  }
}
