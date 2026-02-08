import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

class DebouncedTextField extends StatefulWidget {
  const DebouncedTextField({
    super.key,
    this.controller,
    this.hintText,
    this.maxLines = 1,
    this.onChanged,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.prefixIcon,
  });

  final TextEditingController? controller;
  final String? hintText;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final Duration debounceDelay;
  final Widget? prefixIcon;

  @override
  State<DebouncedTextField> createState() => _DebouncedTextFieldState();
}

class _DebouncedTextFieldState extends State<DebouncedTextField> {
  Timer? _debounceTimer;

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDelay, () {
      if (widget.onChanged != null) {
        widget.onChanged!(value);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: widget.controller,
      maxLines: widget.maxLines,
      onChanged: _onChanged,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        hintStyle: AppTextStyles.caption.copyWith(color: Theme.of(context).hintColor),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
