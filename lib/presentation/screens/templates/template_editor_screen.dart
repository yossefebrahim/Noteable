import 'package:flutter/material.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';
import 'package:noteable_app/presentation/providers/folder_provider.dart';
import 'package:noteable_app/presentation/providers/template_view_model.dart';
import 'package:noteable_app/presentation/widgets/app_button.dart';
import 'package:noteable_app/presentation/widgets/app_text_field.dart';
import 'package:provider/provider.dart';

class TemplateEditorScreen extends StatefulWidget {
  const TemplateEditorScreen({super.key, this.templateId});

  final String? templateId;

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  final List<_VariableEditorState> _variables = <_VariableEditorState>[];
  String? _selectedFolderId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final TemplateViewModel vm = context.read<TemplateViewModel>();
      if (widget.templateId != null) {
        final template = vm.getTemplateById(widget.templateId!);
        if (!mounted || template == null) return;
        _nameController.text = template.name;
        _titleController.text = template.title;
        _contentController.text = template.content;
        for (final variable in template.variables) {
          _variables.add(_VariableEditorState(
            name: variable.name,
            type: variable.type,
            defaultValue: variable.defaultValue ?? '',
          ));
        }
        _selectedFolderId = template.defaultFolderId;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    for (final variable in _variables) {
      variable.dispose();
    }
    super.dispose();
  }

  void _addVariable() {
    setState(() {
      _variables.add(_VariableEditorState(
        name: '',
        type: 'text',
        defaultValue: '',
      ));
    });
  }

  void _removeVariable(int index) {
    _variables[index].dispose();
    setState(() {
      _variables.removeAt(index);
    });
  }

  Future<void> _saveTemplate() async {
    final TemplateViewModel vm = context.read<TemplateViewModel>();

    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter a template name');
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showError('Please enter a template title');
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showError('Please enter template content');
      return;
    }

    // Convert variable editors to TemplateVariable objects
    final validVariables = <TemplateVariable>[];
    for (final editor in _variables) {
      final name = editor.nameController.text.trim();
      if (name.isNotEmpty) {
        final defaultValue = editor.defaultValueController.text.trim();
        validVariables.add(TemplateVariable(
          name: name,
          type: editor.type,
          defaultValue: defaultValue.isEmpty ? null : defaultValue,
        ));
      }
    }

    final template = TemplateEntity(
      id: widget.templateId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      variables: validVariables,
      defaultFolderId: _selectedFolderId,
      isBuiltIn: false,
    );

    if (widget.templateId != null) {
      await vm.updateTemplate(template);
    } else {
      await vm.createTemplate(template);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.templateId != null;
    final folders = context.watch<FolderViewModel>().folders;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Template' : 'New Template'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: AppButton(
              label: 'Save',
              onPressed: _saveTemplate,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppTextField(
              controller: _nameController,
              hintText: 'Template name (e.g., Meeting Notes)',
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _titleController,
              hintText: 'Note title (e.g., {{date}} Meeting)',
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _contentController,
              hintText: 'Template content... Use {{variable}} for placeholders',
              maxLines: null,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Variables',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _addVariable,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Variable'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_variables.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No variables defined yet.\nTap "Add Variable" to create one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...List<Widget>.generate(_variables.length, (int index) {
                final editor = _variables[index];
                return _VariableCard(
                  key: ValueKey(editor),
                  editor: editor,
                  onRemove: () => _removeVariable(index),
                );
              }),
            const SizedBox(height: 24),
            Text(
              'Default Folder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFolderId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: <DropdownMenuItem<String>>[
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('No default folder'),
                ),
                ...folders.map<DropdownMenuItem<String>>((folder) {
                  return DropdownMenuItem<String>(
                    value: folder.id,
                    child: Text(folder.name),
                  );
                }),
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedFolderId = value;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _VariableEditorState {
  _VariableEditorState({
    required this.name,
    required this.type,
    required this.defaultValue,
  }) {
    nameController = TextEditingController(text: name);
    defaultValueController = TextEditingController(text: defaultValue);
  }

  final String name;
  String type;
  final String defaultValue;
  late final TextEditingController nameController;
  late final TextEditingController defaultValueController;

  void dispose() {
    nameController.dispose();
    defaultValueController.dispose();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _VariableEditorState &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class _VariableCard extends StatefulWidget {
  const _VariableCard({
    super.key,
    required this.editor,
    required this.onRemove,
  });

  final _VariableEditorState editor;
  final VoidCallback onRemove;

  @override
  State<_VariableCard> createState() => _VariableCardState();
}

class _VariableCardState extends State<_VariableCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: widget.editor.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Variable name',
                      hintText: 'e.g., date, time, attendees',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: widget.editor.type,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(12),
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'text',
                  child: Text('Text'),
                ),
                DropdownMenuItem<String>(
                  value: 'date',
                  child: Text('Date'),
                ),
                DropdownMenuItem<String>(
                  value: 'time',
                  child: Text('Time'),
                ),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    widget.editor.type = value;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.editor.defaultValueController,
              decoration: const InputDecoration(
                labelText: 'Default value (optional)',
                hintText: 'e.g., today, now',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
