import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:noteable_app/data/repositories/template_repository_impl.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';
import 'package:noteable_app/presentation/providers/template_view_model.dart';

@GenerateNiceMocks([MockSpec<TemplateRepository>()])
import 'template_view_model_test.mocks.dart';

void main() {
  late MockTemplateRepository mockRepository;
  late TemplateViewModel viewModel;

  setUp(() {
    mockRepository = MockTemplateRepository();
    viewModel = TemplateViewModel(templateRepository: mockRepository);
  });

  group('load', () {
    test('loads templates and notifies listeners', () async {
      final templates = <TemplateEntity>[
        TemplateEntity(
          id: '1',
          name: 'Template 1',
          title: 'T1',
          content: 'C1',
          variables: <TemplateVariable>[],
        ),
      ];
      when(mockRepository.getTemplates()).thenAnswer((_) async => templates);

      await viewModel.load();

      expect(viewModel.templates, equals(templates));
    });

    test('handles empty template list', () async {
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[]);

      await viewModel.load();

      expect(viewModel.templates, isEmpty);
    });

    test('handles repository error gracefully', () async {
      when(mockRepository.getTemplates()).thenThrow(Exception('Error'));

      await viewModel.load();

      // Should not crash, templates should remain empty
      expect(viewModel.templates, isEmpty);
    });
  });

  group('refresh', () {
    test('reloads templates from repository', () async {
      final templates1 = <TemplateEntity>[
        TemplateEntity(
          id: '1',
          name: 'Template 1',
          title: 'T1',
          content: 'C1',
          variables: <TemplateVariable>[],
        ),
      ];
      final templates2 = <TemplateEntity>[
        TemplateEntity(
          id: '2',
          name: 'Template 2',
          title: 'T2',
          content: 'C2',
          variables: <TemplateVariable>[],
        ),
      ];
      when(mockRepository.getTemplates()).thenAnswer((_) async => templates1);

      await viewModel.load();

      when(mockRepository.getTemplates()).thenAnswer((_) async => templates2);
      await viewModel.refresh();

      expect(viewModel.templates.length, 1);
      expect(viewModel.templates.first.id, '2');
    });
  });

  group('createTemplate', () {
    test('creates template and refreshes list', () async {
      final toCreate = TemplateEntity(
        id: 'ignored',
        name: 'New Template',
        title: 'New',
        content: 'Content',
        variables: <TemplateVariable>[],
      );
      final created = TemplateEntity(
        id: 'custom_123',
        name: 'New Template',
        title: 'New',
        content: 'Content',
        variables: <TemplateVariable>[],
      );
      when(mockRepository.createTemplate(toCreate)).thenAnswer((_) async => created);
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[created]);

      await viewModel.createTemplate(toCreate);

      expect(viewModel.templates.length, 1);
      expect(viewModel.templates.first.id, 'custom_123');
    });

    test('preserves variables when creating template', () async {
      final variables = <TemplateVariable>[
        TemplateVariable(name: 'date', type: 'date'),
      ];
      final toCreate = TemplateEntity(
        id: 'ignored',
        name: 'Template',
        title: 'T',
        content: 'C',
        variables: variables,
      );
      final created = toCreate.copyWith(id: 'custom_123');
      when(mockRepository.createTemplate(toCreate)).thenAnswer((_) async => created);
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[created]);

      await viewModel.createTemplate(toCreate);

      expect(viewModel.templates.first.variables.length, 1);
    });
  });

  group('updateTemplate', () {
    test('updates template and refreshes list', () async {
      final original = TemplateEntity(
        id: 'custom_123',
        name: 'Original',
        title: 'Original',
        content: 'Original',
        variables: <TemplateVariable>[],
      );
      final updated = TemplateEntity(
        id: 'custom_123',
        name: 'Updated',
        title: 'Updated',
        content: 'Updated',
        variables: <TemplateVariable>[],
      );
      when(mockRepository.updateTemplate(updated)).thenAnswer((_) async => updated);
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[updated]);

      await viewModel.updateTemplate(updated);

      expect(viewModel.templates.first.name, 'Updated');
    });
  });

  group('deleteTemplate', () {
    test('deletes template and refreshes list', () async {
      final template = TemplateEntity(
        id: 'custom_123',
        name: 'To Delete',
        title: 'Delete',
        content: 'Content',
        variables: <TemplateVariable>[],
      );
      when(mockRepository.deleteTemplate('custom_123')).thenAnswer((_) async {});
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[]);

      await viewModel.deleteTemplate('custom_123');

      expect(viewModel.templates, isEmpty);
    });
  });

  group('exportTemplates', () {
    test('returns JSON string on successful export', () async {
      final customTemplate = TemplateEntity(
        id: 'custom_1',
        name: 'Custom',
        title: 'Title',
        content: 'Content',
        variables: <TemplateVariable>[],
        isBuiltIn: false,
      );
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[customTemplate]);

      final json = await viewModel.exportTemplates();

      expect(json, contains('"version"'));
      expect(json, contains('"templates"'));
    });

    test('throws exception when no custom templates exist', () async {
      final builtIn = TemplateEntity(
        id: 'builtin_1',
        name: 'Built-in',
        title: 'Title',
        content: 'Content',
        variables: <TemplateVariable>[],
        isBuiltIn: true,
      );
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[builtIn]);

      expect(
        () => viewModel.exportTemplates(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to export templates'),
        )),
      );
    });
  });

  group('importTemplates', () {
    test('imports templates and refreshes list', () async {
      const jsonString = '{"version":"1.0","templates":[{"name":"Imported","title":"Imp","content":"Content","variables":[]}]}';
      final imported = TemplateEntity(
        id: 'custom_123',
        name: 'Imported',
        title: 'Imp',
        content: 'Content',
        variables: <TemplateVariable>[],
      );
      when(mockRepository.createTemplate(any)).thenAnswer((_) async => imported);
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[imported]);

      final result = await viewModel.importTemplates(jsonString);

      expect(result.length, 1);
      expect(result.first.name, 'Imported');
      expect(viewModel.templates.length, 1);
    });

    test('throws exception on invalid JSON', () async {
      expect(
        () => viewModel.importTemplates('invalid json'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getTemplateById', () {
    test('returns template when found', () async {
      final template = TemplateEntity(
        id: 'custom_123',
        name: 'Found',
        title: 'Found',
        content: 'Content',
        variables: <TemplateVariable>[],
      );
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[template]);

      await viewModel.load();

      final found = viewModel.getTemplateById('custom_123');

      expect(found, isNotNull);
      expect(found!.id, 'custom_123');
    });

    test('returns null when not found', () async {
      final template = TemplateEntity(
        id: 'custom_123',
        name: 'Found',
        title: 'Found',
        content: 'Content',
        variables: <TemplateVariable>[],
      );
      when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[template]);

      await viewModel.load();

      final found = viewModel.getTemplateById('non_existent');

      expect(found, isNull);
    });
  });

  group('getBuiltInTemplates', () {
    test('returns only built-in templates', () async {
      final templates = <TemplateEntity>[
        TemplateEntity(
          id: 'builtin_1',
          name: 'Built-in',
          title: 'Built',
          content: 'Content',
          variables: <TemplateVariable>[],
          isBuiltIn: true,
        ),
        TemplateEntity(
          id: 'custom_1',
          name: 'Custom',
          title: 'Custom',
          content: 'Content',
          variables: <TemplateVariable>[],
          isBuiltIn: false,
        ),
      ];
      when(mockRepository.getTemplates()).thenAnswer((_) async => templates);

      await viewModel.load();

      final builtIn = viewModel.getBuiltInTemplates();

      expect(builtIn.length, 1);
      expect(builtIn.first.isBuiltIn, isTrue);
    });
  });

  group('getCustomTemplates', () {
    test('returns only custom templates', () async {
      final templates = <TemplateEntity>[
        TemplateEntity(
          id: 'builtin_1',
          name: 'Built-in',
          title: 'Built',
          content: 'Content',
          variables: <TemplateVariable>[],
          isBuiltIn: true,
        ),
        TemplateEntity(
          id: 'custom_1',
          name: 'Custom',
          title: 'Custom',
          content: 'Content',
          variables: <TemplateVariable>[],
          isBuiltIn: false,
        ),
      ];
      when(mockRepository.getTemplates()).thenAnswer((_) async => templates);

      await viewModel.load();

      final custom = viewModel.getCustomTemplates();

      expect(custom.length, 1);
      expect(custom.first.isBuiltIn, isFalse);
    });
  });
}
