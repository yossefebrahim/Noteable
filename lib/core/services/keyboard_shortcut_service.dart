import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:noteable_app/core/constants/default_shortcuts.dart';
import 'package:noteable_app/core/models/shortcut_action.dart';

/// Service for managing keyboard shortcuts in the application.
///
/// This service maintains a registry of keyboard shortcuts, allows
/// customization, and provides methods to match key events to actions.
class KeyboardShortcutService extends ChangeNotifier {
  /// Internal map of actions to their shortcuts
  final Map<ShortcutAction, KeyboardShortcut> _shortcuts;

  /// Creates a new KeyboardShortcutService with optional custom shortcuts.
  KeyboardShortcutService({Map<ShortcutAction, KeyboardShortcut>? shortcuts})
      : _shortcuts = Map.from(
          shortcuts ?? _buildDefaultShortcuts(),
        );

  /// Builds the default shortcuts map from DefaultShortcuts constants.
  static Map<ShortcutAction, KeyboardShortcut> _buildDefaultShortcuts() {
    final map = <ShortcutAction, KeyboardShortcut>{};
    for (final shortcut in DefaultShortcuts.all) {
      map[shortcut.action] = shortcut;
    }
    return map;
  }

  /// Returns all registered shortcuts.
  List<KeyboardShortcut> get shortcuts => _shortcuts.values.toList();

  /// Returns the shortcut for a given action, or null if not registered.
  KeyboardShortcut? getShortcut(ShortcutAction action) {
    return _shortcuts[action];
  }

  /// Returns the action for a given key combination, or null if not found.
  ShortcutAction? getActionForKey(LogicalKeyboardKey key, Set<LogicalKeyboardKey> modifiers) {
    for (final entry in _shortcuts.entries) {
      final shortcut = entry.value;
      if (shortcut.key == key && _setEquals(shortcut.modifiers, modifiers)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Checks if the given key event matches any registered shortcut.
  ShortcutAction? matchKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return null;

    final key = event.logicalKey;
    final modifiers = _extractModifiers(event);

    return getActionForKey(key, modifiers);
  }

  /// Registers or updates a shortcut for the given action.
  void registerShortcut(KeyboardShortcut shortcut) {
    final existing = _shortcuts[shortcut.action];
    if (existing != shortcut) {
      _shortcuts[shortcut.action] = shortcut;
      notifyListeners();
    }
  }

  /// Removes a shortcut for the given action.
  void removeShortcut(ShortcutAction action) {
    if (_shortcuts.containsKey(action)) {
      _shortcuts.remove(action);
      notifyListeners();
    }
  }

  /// Resets all shortcuts to defaults.
  void resetToDefaults() {
    _shortcuts.clear();
    _shortcuts.addAll(_buildDefaultShortcuts());
    notifyListeners();
  }

  /// Updates multiple shortcuts at once.
  void updateShortcuts(Map<ShortcutAction, KeyboardShortcut> newShortcuts) {
    var changed = false;
    for (final entry in newShortcuts.entries) {
      final existing = _shortcuts[entry.key];
      if (existing != entry.value) {
        _shortcuts[entry.key] = entry.value;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Extracts modifier keys from a key event.
  Set<LogicalKeyboardKey> _extractModifiers(KeyEvent event) {
    final modifiers = <LogicalKeyboardKey>{};

    if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight)) {
      modifiers.add(LogicalKeyboardKey.controlLeft);
    }

    if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.metaLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.metaRight)) {
      modifiers.add(LogicalKeyboardKey.metaLeft);
    }

    if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight)) {
      modifiers.add(LogicalKeyboardKey.shiftLeft);
    }

    if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.altLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.altRight)) {
      modifiers.add(LogicalKeyboardKey.altLeft);
    }

    return modifiers;
  }

  /// Compares two sets for equality.
  bool _setEquals<T>(Set<T>? a, Set<T>? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    if (a.length != b.length) return false;
    return a.every((element) => b.contains(element));
  }
}
