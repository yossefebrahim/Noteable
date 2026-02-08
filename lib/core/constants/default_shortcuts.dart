import 'package:flutter/services.dart';
import 'package:noteable_app/core/models/shortcut_action.dart';

/// Default keyboard shortcuts for the application.
/// These shortcuts can be customized by users in settings.
class DefaultShortcuts {
  DefaultShortcuts._();

  /// Helper to create a modifier set for Cmd/Ctrl combinations.
  /// On macOS, uses Meta (Cmd); on other platforms, uses Control.
  static const _control = LogicalKeyboardKey.controlLeft;
  static const _meta = LogicalKeyboardKey.metaLeft;
  static const _shift = LogicalKeyboardKey.shiftLeft;
  static const _alt = LogicalKeyboardKey.altLeft;

  /// Default shortcuts for the application.
  /// These work with Cmd on macOS and Ctrl on Windows/Linux.
  static final List<KeyboardShortcut> all = [
    // File operations
    KeyboardShortcut(
      action: ShortcutAction.newNote,
      key: LogicalKeyboardKey.keyN,
      modifiers: {_control, _meta},
      description: 'Create a new note',
    ),
    KeyboardShortcut(
      action: ShortcutAction.save,
      key: LogicalKeyboardKey.keyS,
      modifiers: {_control, _meta},
      description: 'Save current note',
    ),

    // Search and navigation
    KeyboardShortcut(
      action: ShortcutAction.search,
      key: LogicalKeyboardKey.keyF,
      modifiers: {_control, _meta},
      description: 'Open search',
    ),
    KeyboardShortcut(
      action: ShortcutAction.navigateUp,
      key: LogicalKeyboardKey.arrowUp,
      modifiers: {},
      description: 'Navigate to previous note',
    ),
    KeyboardShortcut(
      action: ShortcutAction.navigateDown,
      key: LogicalKeyboardKey.arrowDown,
      modifiers: {},
      description: 'Navigate to next note',
    ),
    KeyboardShortcut(
      action: ShortcutAction.openNote,
      key: LogicalKeyboardKey.enter,
      modifiers: {},
      description: 'Open selected note',
    ),

    // Text formatting
    KeyboardShortcut(
      action: ShortcutAction.formatBold,
      key: LogicalKeyboardKey.digit1,
      modifiers: {_control, _meta},
      description: 'Format text as bold',
    ),
    KeyboardShortcut(
      action: ShortcutAction.formatItalic,
      key: LogicalKeyboardKey.digit2,
      modifiers: {_control, _meta},
      description: 'Format text as italic',
    ),
    KeyboardShortcut(
      action: ShortcutAction.formatUnderline,
      key: LogicalKeyboardKey.digit3,
      modifiers: {_control, _meta},
      description: 'Format text as underline',
    ),

    // Note actions
    KeyboardShortcut(
      action: ShortcutAction.delete,
      key: LogicalKeyboardKey.keyD,
      modifiers: {_control, _meta, _shift},
      description: 'Delete selected note',
    ),
    KeyboardShortcut(
      action: ShortcutAction.pinNote,
      key: LogicalKeyboardKey.keyP,
      modifiers: {_control, _meta},
      description: 'Pin/unpin note',
    ),
    KeyboardShortcut(
      action: ShortcutAction.duplicate,
      key: LogicalKeyboardKey.keyD,
      modifiers: {_control, _meta, _alt},
      description: 'Duplicate note',
    ),

    // Help and settings
    KeyboardShortcut(
      action: ShortcutAction.showHelp,
      key: LogicalKeyboardKey.slash,
      modifiers: {_control, _meta},
      description: 'Show keyboard shortcuts help',
    ),
    KeyboardShortcut(
      action: ShortcutAction.openSettings,
      key: LogicalKeyboardKey.comma,
      modifiers: {_control, _meta},
      description: 'Open settings',
    ),
  ];
}
