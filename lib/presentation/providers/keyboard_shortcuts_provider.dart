import 'package:flutter/foundation.dart';
import 'package:noteable_app/core/models/shortcut_action.dart';
import 'package:noteable_app/core/services/keyboard_shortcut_service.dart';

/// Provider for managing keyboard shortcut preferences.
///
/// This provider wraps the KeyboardShortcutService and provides
/// a clean API for the UI layer to manage and customize shortcuts.
class KeyboardShortcutsProvider extends ChangeNotifier {
  final KeyboardShortcutService _service;

  /// Creates a new KeyboardShortcutsProvider.
  KeyboardShortcutsProvider(this._service) {
    // Listen to service changes and propagate to provider listeners
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  /// Called when the underlying service changes.
  void _onServiceChanged() {
    notifyListeners();
  }

  /// Returns all registered shortcuts.
  List<KeyboardShortcut> get shortcuts => _service.shortcuts;

  /// Returns the shortcut for a given action, or null if not registered.
  KeyboardShortcut? getShortcut(ShortcutAction action) {
    return _service.getShortcut(action);
  }

  /// Updates the shortcut for a given action.
  void updateShortcut(ShortcutAction action, KeyboardShortcut shortcut) {
    if (shortcut.action != action) {
      // Create a new shortcut with the correct action
      shortcut = KeyboardShortcut(
        action: action,
        key: shortcut.key,
        modifiers: shortcut.modifiers,
        description: shortcut.description,
      );
    }
    _service.registerShortcut(shortcut);
  }

  /// Removes the shortcut for a given action.
  void removeShortcut(ShortcutAction action) {
    _service.removeShortcut(action);
  }

  /// Resets all shortcuts to their default values.
  void resetToDefaults() {
    _service.resetToDefaults();
  }

  /// Updates multiple shortcuts at once.
  void updateShortcuts(Map<ShortcutAction, KeyboardShortcut> shortcuts) {
    _service.updateShortcuts(shortcuts);
  }

  /// Checks if a given key combination is already in use by another action.
  KeyboardShortcut? getConflict(
    KeyboardShortcut shortcut, {
    ShortcutAction? excludeAction,
  }) {
    for (final existing in _service.shortcuts) {
      if (excludeAction != null && existing.action == excludeAction) {
        continue;
      }
      if (existing.key == shortcut.key &&
          _setEquals(existing.modifiers, shortcut.modifiers)) {
        return existing;
      }
    }
    return null;
  }

  /// Compares two sets for equality.
  bool _setEquals<T>(Set<T>? a, Set<T>? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    if (a.length != b.length) return false;
    return a.every((element) => b.contains(element));
  }
}
