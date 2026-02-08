import 'package:flutter/material.dart';

import 'empty_state.dart';

class EmptyNotesState extends StatelessWidget {
  const EmptyNotesState({super.key, this.onCreateTap});

  final VoidCallback? onCreateTap;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'No notes yet',
      subtitle: 'Create your first note to get started.',
      icon: Icons.note_alt_outlined,
      tips: const [
        'Press the + button to create your first note',
        'Notes are auto-saved locally',
        'Organize notes with folders later',
        'Use the search bar to find notes quickly',
        'Swipe notes to delete or archive them',
      ],
      action: FilledButton.icon(
        onPressed: onCreateTap,
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }
}
