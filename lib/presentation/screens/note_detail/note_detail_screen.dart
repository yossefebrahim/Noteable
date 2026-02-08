import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/export_view_model.dart';
import '../../providers/note_detail_view_model.dart';
import '../../providers/notes_view_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../export/export_options_bottom_sheet.dart';
import '../../../data/services/export_service.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key, this.noteId});

  final String? noteId;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final NoteEditorViewModel vm = context.read<NoteEditorViewModel>();
      await vm.init(noteId: widget.noteId);
      final note = vm.note;
      if (!mounted || note == null) return;
      _titleController.text = note.title;
      _contentController.text = note.content;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = context.select<NoteEditorViewModel, bool>((NoteEditorViewModel vm) => vm.hasNote);
    final bool isPinned = context.select<NoteEditorViewModel, bool>((NoteEditorViewModel vm) => vm.note?.isPinned ?? false);
    final bool isSaving = context.select<NoteEditorViewModel, bool>((NoteEditorViewModel vm) => vm.isSaving);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Note Details' : 'New Note'),
        actions: <Widget>[
          IconButton(
            onPressed: isEditing ? _handleExportPressed : null,
            icon: const Icon(Icons.share),
            tooltip: 'Export',
          ),
          IconButton(
            onPressed: () {
              final NoteEditorViewModel vm = context.read<NoteEditorViewModel>();
              final note = vm.note;
              if (note == null) return;
              vm.updateDraft(isPinned: !note.isPinned);
            },
            icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: AppButton(
              label: 'Save',
              isLoading: isSaving,
              onPressed: () async {
                final NoteEditorViewModel vm = context.read<NoteEditorViewModel>();
                vm.updateDraft(title: _titleController.text, content: _contentController.text);
                await vm.saveNow();
                if (!context.mounted) return;
                final notesVm = context.read<NotesViewModel>();
                await notesVm.refreshNotes();
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            AppTextField(
              controller: _titleController,
              hintText: 'Note title',
              onChanged: (String value) => context.read<NoteEditorViewModel>().updateDraft(title: value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AppTextField(
                controller: _contentController,
                hintText: 'Start writing...',
                maxLines: null,
                onChanged: (String value) => context.read<NoteEditorViewModel>().updateDraft(content: value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExportPressed() async {
    final NoteEditorViewModel editorVm = context.read<NoteEditorViewModel>();
    final note = editorVm.note;
    if (note == null) return;

    final exportVm = context.read<ExportViewModel>();

    await ExportOptionsBottomSheet.show(
      context,
      onExportFormatSelected: (ExportFormat format) async {
        final success = await exportVm.exportNote(note.id, format.name);
        if (!context.mounted) return;
        _showExportResultSnackBar(success, format.name);
      },
      onShareSelected: () async {
        final success = await exportVm.getShareableContent(note.id);
        if (!context.mounted) return;
        if (success && exportVm.shareableContent != null) {
          await Share.share(exportVm.shareableContent!);
          exportVm.clearShareableContent();
        } else {
          _showExportResultSnackBar(false, 'share');
        }
      },
    );
  }

  void _showExportResultSnackBar(bool success, String format) {
    final message = success
        ? 'Note exported as $format'
        : 'Failed to export note as $format';
    final snackBar = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
