import 'dart:convert';

import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';

class ImportExportTemplatesUseCase {
  final TemplateRepository _templateRepository;

  ImportExportTemplatesUseCase({required TemplateRepository templateRepository})
    : _templateRepository = templateRepository;

  /// Exports all custom templates (excluding built-in templates) to JSON format
  Future<Result<String>> exportTemplates() async {
    try {
      final templates = await _templateRepository.getTemplates();

      // Filter out built-in templates, only export custom ones
      final customTemplates = templates.where((t) => !t.isBuiltIn).toList();

      if (customTemplates.isEmpty) {
        return const Result.failure('No custom templates to export');
      }

      final exportData = <String, dynamic>{
        'version': '1.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'templates': customTemplates.map((t) => _templateToJson(t)).toList(),
      };

      final jsonString = jsonEncode(exportData);
      return Result.success(jsonString);
    } catch (e) {
      return Result.failure('Failed to export templates: $e');
    }
  }

  /// Imports templates from JSON format
  /// Returns the list of imported templates
  Future<Result<List<TemplateEntity>>> importTemplates(String jsonString) async {
    try {
      if (jsonString.trim().isEmpty) {
        return const Result.failure('JSON string is empty');
      }

      final dynamic decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return const Result.failure('Invalid JSON format: expected object');
      }

      final data = decoded;

      if (!data.containsKey('templates') || data['templates'] is! List) {
        return const Result.failure('Invalid template format: missing templates list');
      }

      final templatesList = data['templates'] as List<dynamic>;
      final List<TemplateEntity> importedTemplates = [];

      for (final dynamic item in templatesList) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        try {
          final template = _jsonToTemplate(item);
          final created = await _templateRepository.createTemplate(template);
          importedTemplates.add(created);
        } catch (e) {
          // Continue with other templates even if one fails
          continue;
        }
      }

      if (importedTemplates.isEmpty) {
        return const Result.failure('No valid templates found in JSON');
      }

      return Result.success(importedTemplates);
    } catch (e) {
      return Result.failure('Failed to import templates: $e');
    }
  }

  Map<String, dynamic> _templateToJson(TemplateEntity template) {
    return <String, dynamic>{
      'name': template.name,
      'title': template.title,
      'content': template.content,
      'variables': template.variables.map((v) => _variableToJson(v)).toList(),
      'defaultFolderId': template.defaultFolderId,
    };
  }

  Map<String, dynamic> _variableToJson(TemplateVariable variable) {
    return <String, dynamic>{
      'name': variable.name,
      'type': variable.type,
      'defaultValue': variable.defaultValue,
    };
  }

  TemplateEntity _jsonToTemplate(Map<String, dynamic> json) {
    final List<TemplateVariable> variables = <TemplateVariable>[];

    if (json['variables'] is List) {
      final List<dynamic> variablesList = json['variables'] as List<dynamic>;
      for (final dynamic item in variablesList) {
        if (item is Map<String, dynamic>) {
          variables.add(_jsonToVariable(item));
        }
      }
    }

    // Create a temporary ID, it will be replaced on create
    return TemplateEntity(
      id: '', // Temporary empty ID
      name: json['name'] as String? ?? 'Untitled',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      variables: variables,
      defaultFolderId: json['defaultFolderId'] as String?,
    );
  }

  TemplateVariable _jsonToVariable(Map<String, dynamic> json) {
    return TemplateVariable(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      defaultValue: json['defaultValue'] as String?,
    );
  }
}
