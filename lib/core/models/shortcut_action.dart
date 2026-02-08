import 'package:flutter/services.dart';

/// Enum representing all available shortcut actions in the app.
enum ShortcutAction {
  /// Create a new note
  newNote,

  /// Open search
  search,

  /// Save current note
  save,

  /// Navigate to previous note in list
  navigateUp,

  /// Navigate to next note in list
  navigateDown,

  /// Open note in editor
  openNote,

  /// Delete selected note
  delete,

  /// Pin/unpin note
  pinNote,

  /// Format text as bold
  formatBold,

  /// Format text as italic
  formatItalic,

  /// Format text as underline
  formatUnderline,

  /// Show keyboard shortcuts help
  showHelp,

  /// Open settings
  openSettings,

  /// Move note to folder
  moveToFolder,

  /// Share note
  share,

  /// Duplicate note
  duplicate,
}

/// Data model representing a keyboard shortcut.
class KeyboardShortcut {
  const KeyboardShortcut({
    required this.action,
    required this.key,
    required this.modifiers,
    required this.description,
  });

  /// The action this shortcut triggers
  final ShortcutAction action;

  /// The physical key that triggers this shortcut
  final LogicalKeyboardKey key;

  /// Modifier keys required (Control, Meta, Shift, Alt)
  final Set<LogicalKeyboardKey> modifiers;

  /// Human-readable description for display in UI
  final String description;

  /// Creates a copy of this shortcut with optional new values
  KeyboardShortcut copyWith({
    ShortcutAction? action,
    LogicalKeyboardKey? key,
    Set<LogicalKeyboardKey>? modifiers,
    String? description,
  }) {
    return KeyboardShortcut(
      action: action ?? this.action,
      key: key ?? this.key,
      modifiers: modifiers ?? this.modifiers,
      description: description ?? this.description,
    );
  }

  /// Returns the key combination as a string for display (e.g., "Cmd+N")
  String get keyCombination {
    final buffer = StringBuffer();

    // Add modifiers in standard order
    final modifierOrder = {
      LogicalKeyboardKey.controlLeft: 'Ctrl',
      LogicalKeyboardKey.controlRight: 'Ctrl',
      LogicalKeyboardKey.metaLeft: 'Cmd',
      LogicalKeyboardKey.metaRight: 'Cmd',
      LogicalKeyboardKey.shiftLeft: 'Shift',
      LogicalKeyboardKey.shiftRight: 'Shift',
      LogicalKeyboardKey.altLeft: 'Alt',
      LogicalKeyboardKey.altRight: 'Alt',
    };

    final sortedModifiers = modifiers.toList()
      ..sort((a, b) {
        final aName = modifierOrder[a] ?? '';
        final bName = modifierOrder[b] ?? '';
        return aName.compareTo(bName);
      });

    for (final modifier in sortedModifiers) {
      if (buffer.isNotEmpty) buffer.write('+');
      buffer.write(modifierOrder[modifier] ?? modifier.keyLabel);
    }

    if (buffer.isNotEmpty) buffer.write('+');
    buffer.write(key.keyLabel);

    return buffer.toString();
  }

  @override
  String toString() {
    return 'KeyboardShortcut(action: $action, key: $keyCombination)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is KeyboardShortcut &&
        other.action == action &&
        other.key == key &&
        _setEquals(other.modifiers, modifiers);
  }

  @override
  int get hashCode => Object.hash(action, key, modifiers);

  /// Compares two sets for equality
  bool _setEquals<T>(Set<T>? a, Set<T>? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    if (a.length != b.length) return false;
    return a.every((element) => b.contains(element));
  }
}
