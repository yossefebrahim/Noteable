import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';
import 'package:noteable_app/domain/usecases/template/import_export_templates_usecase.dart';

@GenerateNiceMocks([MockSpec<TemplateRepository>()])
import 'import_export_templates_usecase_test.mocks.dart';

void main() {
  late MockTemplateRepository mockRepository;
  late ImportExportTemplatesUseCase useCase;

  setUp(() {
    mockRepository = MockTemplateRepository();
    useCase = ImportExportTemplatesUseCase(templateRepository: mockRepository);
  });

  group('exportTemplates', () {
    test('exports custom templates to JSON', () async {
      final customTemplate = TemplateEntity(
        id: 'custom_1',
        name: 'My Template',
        title: 'My Title',
        content: 'My Content',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'date', type: 'date'),
        ],
        isBuiltIn: false,
      );
      final builtInTemplate = TemplateEntity(
        id: 'builtin_1',
        name: 'Built-in',
        title: 'Built-in Title',
        content: 'Built-in Content',
        variables: <TemplateVariable>[],
        isBuiltIn: true,
      );
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[
        customTemplate,
        builtInTemplate,
      ]);

      final result = await useCase.exportTemplates();

      expect(result.isSuccess, isTrue);
      final json = jsonDecode(result.data!);
      expect(json['version'], '1.0');
      expect(json['templates'], isList);
      expect((json['templates'] as List).length, 1);
      expect(json['templates'][0]['name'], 'My Template');
    });

    test('returns failure when no custom templates exist', () async {
      final builtIn = TemplateEntity(
        id: 'builtin_1',
        name: 'Built-in',
        title: 'Title',
        content: 'Content',
        variables: <TemplateVariable>[],
        isBuiltIn: true,
      );
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[builtIn]);

      final result = await useCase.exportTemplates();

      expect(result.isSuccess, isFalse);
      expect(result.error, 'No custom templates to export');
    });

    test('includes template variables in export', () async {
      final template = TemplateEntity(
        id: 'custom_1',
        name: 'Template',
        title: 'Title',
        content: 'Content',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'date', type: 'date', defaultValue: 'today'),
          TemplateVariable(name: 'title', type: 'text'),
        ],
        isBuiltIn: false,
      );
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[template]);

      final result = await useCase.exportTemplates();

      expect(result.isSuccess, isTrue);
      final json = jsonDecode(result.data!);
      final variables = json['templates'][0]['variables'] as List;
      expect(variables.length, 2);
      expect(variables[0]['name'], 'date');
      expect(variables[0]['defaultValue'], 'today');
      expect(variables[1]['name'], 'title');
    });

    test('handles export error gracefully', () async {
      when(mockRepository.getTemplates()).thenThrow(Exception('Database error'));

      final result = await useCase.exportTemplates();

      expect(result.isSuccess, isFalse);
      expect(result.error, contains('Failed to export templates'));
    });
  });

  group('importTemplates', () {
    test('imports templates from valid JSON', () async {
      final jsonString = jsonEncode(<String, dynamic>{
        'version': '1.0',
        'templates': <dynamic>[
          <String, dynamic>{
            'name': 'Imported Template',
            'title': 'Imported',
            'content': 'Imported Content',
            'variables': <dynamic>[
              <String, dynamic>{'name': 'date', 'type': 'date'},
            ],
          },
        ],
      });
      final created = TemplateEntity(
        id: 'custom_123',
        name: 'Imported Template',
        title: 'Imported',
        content: 'Imported Content',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'date', type: 'date'),
        ],
      );
      when(mockRepository.createTemplate(any)).thenAnswer((_) async => created);

      final result = await useCase.importTemplates(jsonString);

      expect(result.isSuccess, isTrue);
      expect(result.data!.length, 1);
      expect(result.data![0].name, 'Imported Template');
    });

    test('returns failure for empty JSON string', () async {
      final result = await useCase.importTemplates('   ');

      expect(result.isSuccess, isFalse);
      expect(result.error, 'JSON string is empty');
    });

    test('returns failure for invalid JSON format', () async {
      final result = await useCase.importTemplates('not valid json');

      expect(result.isSuccess, isFalse);
    });

    test('returns failure when templates list is missing', () async {
      final jsonString = jsonEncode(<String, dynamic>{
        'version': '1.0',
      });

      final result = await useCase.importTemplates(jsonString);

      expect(result.isSuccess, isFalse);
      expect(result.error, contains('missing templates list'));
    });

    test('skips invalid template entries but continues with valid ones', () async {
      final jsonString = jsonEncode(<String, dynamic>{
        'version': '1.0',
        'templates': <dynamic>[
          null, // Invalid entry
          <String, dynamic>{ // Valid entry
            'name': 'Valid Template',
            'title': 'Valid',
            'content': 'Valid Content',
            'variables': <dynamic>[],
          },
        ],
      });
      final created = TemplateEntity(
        id: 'custom_123',
        name: 'Valid Template',
        title: 'Valid',
        content: 'Valid Content',
        variables: <TemplateVariable>[],
      );
      when(mockRepository.createTemplate(any)).thenAnswer((_) async => created);

      final result = await useCase.importTemplates(jsonString);

      expect(result.isSuccess, isTrue);
      expect(result.data!.length, 1);
    });

    test('returns failure when no valid templates found', () async {
      final jsonString = jsonEncode(<String, dynamic>{
        'version': '1.0',
        'templates': <dynamic>[null, 'invalid', 123],
      });

      final result = await useCase.importTemplates(jsonString);

      expect(result.isSuccess, isFalse);
      expect(result.error, 'No valid templates found in JSON');
    });

    test('imports template variables correctly', () async {
      final jsonString = jsonEncode(<String, dynamic>{
        'version': '1.0',
        'templates': <dynamic>[
          <String, dynamic>{
            'name': 'Template',
            'title': 'Title',
            'content': 'Content',
            'variables': <dynamic>[
              <String, dynamic>{'name': 'date', 'type': 'date', 'defaultValue': 'today'},
              <String, dynamic>{'name': 'title', 'type': 'text'},
            ],
          },
        ],
      });
      final created = TemplateEntity(
        id: 'custom_123',
        name: 'Template',
        title: 'Title',
        content: 'Content',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'date', type: 'date', defaultValue: 'today'),
          TemplateVariable(name: 'title', type: 'text'),
        ],
      );
      when(mockRepository.createTemplate(any)).thenAnswer((_) async => created);

      final result = await useCase.importTemplates(jsonString);

      expect(result.isSuccess, isTrue);
      expect(result.data![0].variables.length, 2);
      expect(result.data![0].variables[0].name, 'date');
      expect(result.data![0].variables[0].defaultValue, 'today');
    });

    test('uses default values for missing template fields', () async {
      final jsonString = jsonEncode(<String, dynamic>{
        'version': '1.0',
        'templates': <dynamic>[
          <String, dynamic>{
            // name, title, content missing - should use defaults
            'variables': <dynamic>[],
          },
        ],
      });
      final created = TemplateEntity(
        id: 'custom_123',
        name: 'Untitled',
        title: '',
        content: '',
        variables: <TemplateVariable>[],
      );
      when(mockRepository.createTemplate(any)).thenAnswer((_) async => created);

      final result = await useCase.importTemplates(jsonString);

      expect(result.isSuccess, isTrue);
      expect(result.data![0].name, 'Untitled');
    });
  });
}
