import 'package:flutter/material.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:provider/provider.dart';

import '../../providers/note_detail_view_model.dart';
import '../../providers/notes_view_model.dart';
import '../../providers/template_view_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/debounced_text_field.dart';

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
            DebouncedTextField(
              controller: _titleController,
              hintText: 'Note title',
              onChanged: (String value) => context.read<NoteEditorViewModel>().updateDraft(title: value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: DebouncedTextField(
                controller: _contentController,
                hintText: 'Start writing...',
                maxLines: null,
                onChanged: (String value) => context.read<NoteEditorViewModel>().updateDraft(content: value),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTemplateDialog(context),
        child: const Icon(Icons.description_outlined),
      ),
    );
  }

  Future<void> _showTemplateDialog(BuildContext context) async {
    final TemplateEntity? selected = await showDialog<TemplateEntity>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<TemplateViewModel>(
          builder: (BuildContext context, TemplateViewModel vm, _) {
            final List<TemplateEntity> templates = vm.templates;
            if (templates.isEmpty) {
              return AlertDialog(
                title: const Text('Use Template'),
                content: const Text('No templates available. Create templates first.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            }
            return AlertDialog(
              title: const Text('Use Template'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: templates.length,
                  itemBuilder: (BuildContext context, int index) {
                    final TemplateEntity template = templates[index];
                    return ListTile(
                      title: Text(template.name),
                      subtitle: Text(template.title),
                      leading: Icon(
                        template.isBuiltIn ? Icons.lock_outlined : Icons.description_outlined,
                      ),
                      onTap: () => Navigator.pop(context, template),
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
    if (selected != null) {
      await _applyTemplate(selected);
    }
  }

  Future<void> _applyTemplate(TemplateEntity template) async {
    final NoteEditorViewModel vm = context.read<NoteEditorViewModel>();
    await vm.applyTemplate(template);
    final note = vm.note;
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
    }
  }
}
