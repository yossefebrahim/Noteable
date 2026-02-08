import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A screen displaying all available keyboard shortcuts and gestures.
/// Shortcuts are organized by category for easy reference.
class ShortcutsHelpScreen extends StatelessWidget {
  const ShortcutsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modifier = kIsWeb ? 'Ctrl' : (Theme.of(context).platform == TargetPlatform.macOS ? 'Cmd' : 'Ctrl');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Shortcuts & Gestures'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategory(
            context,
            title: 'File Operations',
            icon: Icons.insert_drive_file_outlined,
            shortcuts: [
              _ShortcutSpec(label: 'New Note', shortcut: '$modifier+N'),
              _ShortcutSpec(label: 'Save Note', shortcut: '$modifier+S'),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategory(
            context,
            title: 'Search & Navigation',
            icon: Icons.search,
            shortcuts: [
              _ShortcutSpec(label: 'Open Search', shortcut: '$modifier+F'),
              _ShortcutSpec(label: 'Navigate Up', shortcut: '↑'),
              _ShortcutSpec(label: 'Navigate Down', shortcut: '↓'),
              _ShortcutSpec(label: 'Open Note', shortcut: 'Enter'),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategory(
            context,
            title: 'Text Formatting',
            icon: Icons.format_size,
            shortcuts: [
              _ShortcutSpec(label: 'Bold', shortcut: '$modifier+1'),
              _ShortcutSpec(label: 'Italic', shortcut: '$modifier+2'),
              _ShortcutSpec(label: 'Underline', shortcut: '$modifier+3'),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategory(
            context,
            title: 'Note Actions',
            icon: Icons.note,
            shortcuts: [
              _ShortcutSpec(label: 'Pin/Unpin Note', shortcut: '$modifier+P'),
              _ShortcutSpec(label: 'Duplicate Note', shortcut: '$modifier+Alt+D'),
              _ShortcutSpec(label: 'Delete Note', shortcut: '$modifier+Shift+D'),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategory(
            context,
            title: 'Help & Settings',
            icon: Icons.help_outline,
            shortcuts: [
              _ShortcutSpec(label: 'Show Shortcuts Help', shortcut: '$modifier+/'),
              _ShortcutSpec(label: 'Open Settings', shortcut: '$modifier+,'),
            ],
          ),
          if (!kIsWeb) ...[
            const SizedBox(height: 16),
            _buildGestureCategory(
              context,
              title: 'Mobile Gestures',
              icon: Icons.touch_app,
              gestures: [
                _GestureSpec(
                  label: 'Context Menu',
                  description: 'Long-press on a note to see options (pin, delete, move, share)',
                ),
                _GestureSpec(
                  label: 'Quick Actions',
                  description: 'Swipe left or right on a note for quick actions',
                ),
                if (Theme.of(context).platform == TargetPlatform.iOS)
                  _GestureSpec(
                    label: 'Peek Preview',
                    description: '3D Touch/Haptic Touch on a note to preview',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build a category section with keyboard shortcuts.
  Widget _buildCategory(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<_ShortcutSpec> shortcuts,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: shortcuts
                .map(
                  (spec) => ListTile(
                    dense: true,
                    title: Text(spec.label),
                    trailing: _ShortcutKey(shortcut: spec.shortcut),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Build a category section with touch gestures.
  Widget _buildGestureCategory(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<_GestureSpec> gestures,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: gestures
                .map(
                  (spec) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.gesture),
                    title: Text(spec.label),
                    subtitle: Text(spec.description),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// Specification for a keyboard shortcut entry.
class _ShortcutSpec {
  final String label;
  final String shortcut;

  const _ShortcutSpec({required this.label, required this.shortcut});
}

/// Specification for a gesture entry.
class _GestureSpec {
  final String label;
  final String description;

  const _GestureSpec({required this.label, required this.description});
}

/// Widget displaying a keyboard shortcut key combination.
class _ShortcutKey extends StatelessWidget {
  final String shortcut;

  const _ShortcutKey({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    final parts = shortcut.split('+');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: parts
          .map(
            (part) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: _KeyCap(keyLabel: part),
            ),
          )
          .toList(),
    );
  }
}

/// Individual key cap widget for displaying a key.
class _KeyCap extends StatelessWidget {
  final String keyLabel;

  const _KeyCap({required this.keyLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Text(
        keyLabel,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
