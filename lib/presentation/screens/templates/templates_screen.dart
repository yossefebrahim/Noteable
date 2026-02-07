import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/presentation/providers/template_view_model.dart';
import 'package:provider/provider.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateViewModel>(
      builder: (BuildContext context, TemplateViewModel vm, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Templates')),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToEditor(context),
            child: const Icon(Icons.add_outlined),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.templates.length,
            itemBuilder: (BuildContext context, int index) {
              final TemplateEntity template = vm.templates[index];
              return Card(
                child: ListTile(
                  title: Text(template.name),
                  subtitle: Text(template.title),
                  leading: Icon(
                    template.isBuiltIn ? Icons.lock_outlined : Icons.description_outlined,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (!template.isBuiltIn) ...<Widget>[
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _navigateToEditor(context, template: template),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(context, template, vm),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _navigateToEditor(
    BuildContext context, {
    TemplateEntity? template,
  }) async {
    context.go('/template-editor', extra: template?.id);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TemplateEntity template,
    TemplateViewModel vm,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await vm.deleteTemplate(template.id);
    }
  }
}
