import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:noteable_app/domain/entities/note_entity.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = -1;

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event, NotesViewModel vm, BuildContext context) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        if (_selectedIndex < vm.notes.length - 1) {
          _selectedIndex++;
        } else {
          _selectedIndex = 0; // Wrap to top
        }
      });
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        if (_selectedIndex > 0) {
          _selectedIndex--;
        } else if (vm.notes.isNotEmpty) {
          _selectedIndex = vm.notes.length - 1; // Wrap to bottom
        }
      });
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.enter && _selectedIndex >= 0) {
      final note = vm.notes[_selectedIndex];
      context.push('/note-detail', extra: note.id).then((_) => vm.refreshNotes());
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesViewModel>(
      builder: (BuildContext context, NotesViewModel vm, _) {
        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.keyN, control: true, meta: true):
                () => context.push('/note-detail').then((_) => vm.refreshNotes()),
            const SingleActivator(LogicalKeyboardKey.keyF, control: true, meta: true):
                () => context.push('/search'),
            const SingleActivator(LogicalKeyboardKey.slash, shift: true, control: true, meta: true):
                () => context.push('/keyboard-shortcuts'),
          },
          child: Focus(
            autofocus: true,
            onKeyEvent: (FocusNode node, KeyEvent event) => _handleKeyEvent(node, event, vm, context),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Notes'),
                actions: <Widget>[
                  IconButton(
                    onPressed: () => context.push('/keyboard-shortcuts'),
                    icon: const Icon(Icons.help_outline),
                    tooltip: 'Keyboard shortcuts',
                  ),
                  IconButton(onPressed: () => context.push('/search'), icon: const Icon(Icons.search_rounded)),
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
                        final bool isSelected = _selectedIndex == index;
                        return Dismissible(
                          key: Key(note.id),
                          direction: DismissDirection.horizontal,
                          onDismissed: (DismissDirection direction) {
                            if (direction == DismissDirection.endToStart) {
                              // Swipe left (end to start) - delete
                              _confirmDelete(context, vm, note);
                            } else if (direction == DismissDirection.startToEnd) {
                              // Swipe right (start to end) - toggle pin
                              vm.togglePin(note.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(note.isPinned ? 'Note unpinned' : 'Note pinned'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          background: _buildSwipeBackground(
                            context,
                            alignment: Alignment.centerLeft,
                            icon: note.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                            color: Colors.amber,
                            label: note.isPinned ? 'Unpin' : 'Pin',
                          ),
                          secondaryBackground: _buildSwipeBackground(
                            context,
                            alignment: Alignment.centerRight,
                            icon: Icons.delete_outline,
                            color: Colors.red,
                            label: 'Delete',
                          ),
                          child: GestureDetector(
                            onForcePressStart: Platform.isIOS
                                ? (_) {
                                    _showNotePreview(context, note, vm);
                                  }
                                : null,
                            onForcePressEnd: Platform.isIOS ? (_) {} : null,
                            child: Card(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : null,
                              elevation: isSelected ? 4 : 1,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                title: Text(note.title.isEmpty ? 'Untitled' : note.title),
                                subtitle: Text(
                                  note.content.isEmpty ? 'Start writing…' : note.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                leading: IconButton(
                                  tooltip: note.isPinned ? 'Unpin' : 'Pin',
                                  onPressed: () => vm.togglePin(note.id),
                                  icon: Text(note.isPinned ? '📌' : '📍', style: const TextStyle(fontSize: 18)),
                                ),
                                onTap: () {
                                  setState(() => _selectedIndex = index);
                                  context.push('/note-detail', extra: note.id).then((_) => vm.refreshNotes());
                                },
                                onLongPress: () => _showContextMenu(context, note, vm),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _confirmDelete(context, vm, note),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, NotesViewModel vm, NoteEntity note) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text('"${note.title.isEmpty ? 'Untitled' : note.title}" will be removed.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await vm.deleteNote(note.id);
    }
  }

  void _showContextMenu(BuildContext context, NoteEntity note, NotesViewModel vm) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                title: Text(note.isPinned ? 'Unpin' : 'Pin'),
                onTap: () {
                  Navigator.pop(context);
                  vm.togglePin(note.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('Move to folder'),
                onTap: () {
                  Navigator.pop(context);
                  _showMoveToFolderDialog(context, note, vm);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  _shareNote(context, note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, vm, note);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMoveToFolderDialog(BuildContext context, NoteEntity note, NotesViewModel vm) async {
    if (vm.folders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No folders available. Create a folder first.')),
      );
      return;
    }
    final String? selectedFolderId = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Move to folder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: vm.folders.map((folder) => ListTile(
                title: Text(folder.name),
                onTap: () => Navigator.pop(context, folder.id),
              )).toList(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (selectedFolderId != null) {
      // TODO: Implement move to folder functionality
      // This requires a MoveNoteUseCase to be added
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Move functionality coming soon')),
      );
    }
  }

  void _shareNote(BuildContext context, NoteEntity note) {
    final title = note.title.isEmpty ? 'Untitled' : note.title;
    final content = note.content;
    // Basic share using clipboard for now
    // A full implementation would use the share package
    final shareText = '$title\n\n$content';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note copied to clipboard'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showNotePreview(BuildContext context, NoteEntity note, NotesViewModel vm) {
    final title = note.title.isEmpty ? 'Untitled' : note.title;
    final content = note.content.isEmpty ? 'No content' : note.content;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(content),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.push('/note-detail', extra: note.id).then((_) => vm.refreshNotes());
              },
              child: const Text('Open'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: (alignment == Alignment.centerLeft)
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: <Widget>[
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
