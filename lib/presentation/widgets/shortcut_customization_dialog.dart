import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/models/shortcut_action.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/keyboard_shortcuts_provider.dart';

/// Dialog for customizing a keyboard shortcut.
///
/// This dialog allows users to:
/// - View the current keyboard shortcut
/// - Capture a new key combination by pressing keys
/// - See warnings about conflicting shortcuts
/// - Save or cancel the changes
class ShortcutCustomizationDialog extends StatefulWidget {
  const ShortcutCustomizationDialog({
    super.key,
    required this.shortcut,
    required this.onSave,
  });

  /// The current keyboard shortcut to customize
  final KeyboardShortcut shortcut;

  /// Callback when the user saves the new shortcut
  final void Function(KeyboardShortcut) onSave;

  @override
  State<ShortcutCustomizationDialog> createState() =>
      _ShortcutCustomizationDialogState();
}

class _ShortcutCustomizationDialogState
    extends State<ShortcutCustomizationDialog> {
  late KeyboardShortcut _currentShortcut;
  LogicalKeyboardKey? _capturedKey;
  final Set<LogicalKeyboardKey> _capturedModifiers = {};
  bool _isCapturing = false;
  KeyboardShortcut? _conflict;

  @override
  void initState() {
    super.initState();
    _currentShortcut = widget.shortcut;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_getActionTitle(widget.shortcut.action)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.shortcut.description,
            style: AppTextStyles.body.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _buildCurrentShortcut(),
          const SizedBox(height: 16),
          _buildCaptureArea(),
          if (_conflict != null) ...[
            const SizedBox(height: 16),
            _buildConflictWarning(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _canSave() ? null : Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSave() ? _handleSave : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildCurrentShortcut() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Shortcut',
          style: AppTextStyles.small.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.keyboard,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                _currentShortcut.keyCombination,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureArea() {
    return Focus(
      onKeyEvent: _isCapturing ? _handleKeyEvent : null,
      child: GestureDetector(
        onTap: _startCapture,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: _isCapturing
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isCapturing
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _isCapturing ? Icons.keyboard_hide : Icons.keyboard,
                size: 32,
                color: _isCapturing
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                _isCapturing
                    ? 'Press keys now...'
                    : 'Tap to capture new shortcut',
                style: AppTextStyles.body.copyWith(
                  color: _isCapturing
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: _isCapturing ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              if (_capturedKey != null || _capturedModifiers.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _getCapturedCombination(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConflictWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This shortcut is already used for "${_conflict!.description}"',
              style: AppTextStyles.small.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startCapture() {
    setState(() {
      _isCapturing = true;
      _capturedKey = null;
      _capturedModifiers.clear();
      _conflict = null;
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_isCapturing) return KeyEventResult.ignored;

    // Only handle key down events
    if (event is! KeyDownEvent) return KeyEventResult.handled;

    final key = event.logicalKey;

    // Handle modifier keys
    if (_isModifierKey(key)) {
      setState(() {
        _capturedModifiers.add(key);
      });
      return KeyEventResult.handled;
    }

    // Handle Escape to cancel capture
    if (key == LogicalKeyboardKey.escape) {
      setState(() {
        _isCapturing = false;
        _capturedKey = null;
        _capturedModifiers.clear();
      });
      return KeyEventResult.handled;
    }

    // Capture the main key
    setState(() {
      _capturedKey = key;
      _isCapturing = false;
      _checkForConflict();
    });

    return KeyEventResult.handled;
  }

  void _checkForConflict() {
    if (_capturedKey == null) return;

    final provider = context.read<KeyboardShortcutsProvider>();
    final newShortcut = KeyboardShortcut(
      action: widget.shortcut.action,
      key: _capturedKey!,
      modifiers: Set.from(_capturedModifiers),
      description: widget.shortcut.description,
    );

    final conflict = provider.getConflict(
      newShortcut,
      excludeAction: widget.shortcut.action,
    );

    setState(() {
      _conflict = conflict;
      if (conflict == null) {
        _currentShortcut = newShortcut;
      }
    });
  }

  bool _canSave() {
    return _capturedKey != null && _conflict == null;
  }

  void _handleSave() {
    if (!_canSave()) return;

    widget.onSave(_currentShortcut);
    Navigator.of(context).pop();
  }

  String _getActionTitle(ShortcutAction action) {
    switch (action) {
      case ShortcutAction.newNote:
        return 'New Note Shortcut';
      case ShortcutAction.search:
        return 'Search Shortcut';
      case ShortcutAction.save:
        return 'Save Shortcut';
      case ShortcutAction.navigateUp:
        return 'Navigate Up Shortcut';
      case ShortcutAction.navigateDown:
        return 'Navigate Down Shortcut';
      case ShortcutAction.openNote:
        return 'Open Note Shortcut';
      case ShortcutAction.delete:
        return 'Delete Shortcut';
      case ShortcutAction.pinNote:
        return 'Pin Note Shortcut';
      case ShortcutAction.formatBold:
        return 'Format Bold Shortcut';
      case ShortcutAction.formatItalic:
        return 'Format Italic Shortcut';
      case ShortcutAction.formatUnderline:
        return 'Format Underline Shortcut';
      case ShortcutAction.showHelp:
        return 'Show Help Shortcut';
      case ShortcutAction.openSettings:
        return 'Open Settings Shortcut';
      case ShortcutAction.moveToFolder:
        return 'Move to Folder Shortcut';
      case ShortcutAction.share:
        return 'Share Shortcut';
      case ShortcutAction.duplicate:
        return 'Duplicate Shortcut';
    }
  }

  String _getCapturedCombination() {
    if (_capturedKey == null && _capturedModifiers.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();

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

    final sortedModifiers = _capturedModifiers.toList()
      ..sort((a, b) {
        final aName = modifierOrder[a] ?? '';
        final bName = modifierOrder[b] ?? '';
        return aName.compareTo(bName);
      });

    for (final modifier in sortedModifiers) {
      if (buffer.isNotEmpty) buffer.write('+');
      buffer.write(modifierOrder[modifier] ?? modifier.keyLabel);
    }

    if (_capturedKey != null) {
      if (buffer.isNotEmpty) buffer.write('+');
      buffer.write(_capturedKey!.keyLabel);
    }

    return buffer.toString();
  }

  bool _isModifierKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight;
  }
}
