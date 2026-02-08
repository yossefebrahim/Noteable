import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/data/repositories/template_repository_impl.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';

void main() {
  group('TemplateRepositoryImpl', () {
    late TemplateRepositoryImpl repository;

    setUp(() {
      repository = TemplateRepositoryImpl();
    });

    test('getTemplates returns all built-in templates', () async {
      final templates = await repository.getTemplates();

      expect(templates.length, greaterThanOrEqualTo(5));
      expect(templates.any((t) => t.isBuiltIn), isTrue);
    });

    test('getTemplates returns blank note built-in template', () async {
      final templates = await repository.getTemplates();

      final blankNote = templates.where((t) => t.id == 'builtin_blank');
      expect(blankNote.isNotEmpty, isTrue);
      expect(blankNote.first.name, 'Blank Note');
    });

    test('getTemplates returns meeting notes built-in template', () async {
      final templates = await repository.getTemplates();

      final meeting = templates.where((t) => t.id == 'builtin_meeting');
      expect(meeting.isNotEmpty, isTrue);
      expect(meeting.first.name, 'Meeting Notes');
      expect(meeting.first.variables.any((v) => v.name == 'date'), isTrue);
    });

    test('getTemplates returns daily journal built-in template', () async {
      final templates = await repository.getTemplates();

      final journal = templates.where((t) => t.id == 'builtin_journal');
      expect(journal.isNotEmpty, isTrue);
      expect(journal.first.name, 'Daily Journal');
    });

    test('getTemplates returns weekly plan built-in template', () async {
      final templates = await repository.getTemplates();

      final weekly = templates.where((t) => t.id == 'builtin_weekly');
      expect(weekly.isNotEmpty, isTrue);
      expect(weekly.first.name, 'Weekly Plan');
    });

    test('getTemplates returns book notes built-in template', () async {
      final templates = await repository.getTemplates();

      final book = templates.where((t) => t.id == 'builtin_book');
      expect(book.isNotEmpty, isTrue);
      expect(book.first.name, 'Book Notes');
    });

    test('getTemplates sorts built-in before custom', () async {
      final custom = TemplateEntity(
        id: 'custom_1',
        name: 'Custom Template',
        title: 'Custom',
        content: 'Content',
        variables: <TemplateVariable>[],
      );
      await repository.createTemplate(custom);

      final templates = await repository.getTemplates();

      final firstBuiltInIndex = templates.indexWhere((t) => t.isBuiltIn);
      final firstCustomIndex = templates.indexWhere((t) => !t.isBuiltIn);

      expect(firstBuiltInIndex, lessThan(firstCustomIndex));
    });

    test('getTemplates sorts alphabetically within built-in and custom', () async {
      final custom1 = TemplateEntity(
        id: 'custom_1',
        name: 'Zebra Template',
        title: 'Zebra',
        content: 'Content',
        variables: <TemplateVariable>[],
      );
      final custom2 = TemplateEntity(
        id: 'custom_2',
        name: 'Apple Template',
        title: 'Apple',
        content: 'Content',
        variables: <TemplateVariable>[],
      );
      await repository.createTemplate(custom1);
      await repository.createTemplate(custom2);

      final templates = await repository.getTemplates();
      final customTemplates = templates.where((t) => !t.isBuiltIn).toList();

      expect(customTemplates.first.name, 'Apple Template');
      expect(customTemplates.last.name, 'Zebra Template');
    });

    test('getTemplateById returns correct template', () async {
      final template = await repository.getTemplateById('builtin_blank');

      expect(template, isNotNull);
      expect(template!.id, 'builtin_blank');
      expect(template.name, 'Blank Note');
    });

    test('getTemplateById returns null for non-existent id', () async {
      final template = await repository.getTemplateById('non_existent');

      expect(template, isNull);
    });

    test('createTemplate adds custom template', () async {
      final custom = TemplateEntity(
        id: 'ignored', // should be replaced
        name: 'Custom Template',
        title: 'Custom',
        content: 'Content',
        variables: <TemplateVariable>[],
      );

      final created = await repository.createTemplate(custom);

      expect(created.id, startsWith('custom_'));
      expect(created.name, 'Custom Template');
      expect(created.isBuiltIn, isFalse);

      final retrieved = await repository.getTemplateById(created.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Custom Template');
    });

    test('createTemplate generates unique ids', () async {
      final template1 = TemplateEntity(
        id: 'ignored',
        name: 'Template 1',
        title: 'T1',
        content: 'C1',
        variables: <TemplateVariable>[],
      );
      final template2 = TemplateEntity(
        id: 'ignored',
        name: 'Template 2',
        title: 'T2',
        content: 'C2',
        variables: <TemplateVariable>[],
      );

      final created1 = await repository.createTemplate(template1);
      final created2 = await repository.createTemplate(template2);

      expect(created1.id, isNot(equals(created2.id)));
    });

    test('updateTemplate modifies existing custom template', () async {
      final created = await repository.createTemplate(
        TemplateEntity(
          id: 'ignored',
          name: 'Original Name',
          title: 'Original',
          content: 'Original Content',
          variables: <TemplateVariable>[],
        ),
      );

      final updated = created.copyWith(name: 'Updated Name');
      final result = await repository.updateTemplate(updated);

      expect(result.name, 'Updated Name');

      final retrieved = await repository.getTemplateById(created.id);
      expect(retrieved!.name, 'Updated Name');
    });

    test('updateTemplate throws when updating built-in template', () async {
      final blankNote = await repository.getTemplateById('builtin_blank')!;
      final modified = blankNote.copyWith(name: 'Modified');

      expect(
        () => repository.updateTemplate(modified),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Cannot update built-in templates',
        )),
      );
    });

    test('deleteTemplate removes custom template', () async {
      final created = await repository.createTemplate(
        TemplateEntity(
          id: 'ignored',
          name: 'To Delete',
          title: 'Delete',
          content: 'Content',
          variables: <TemplateVariable>[],
        ),
      );

      await repository.deleteTemplate(created.id);

      final retrieved = await repository.getTemplateById(created.id);
      expect(retrieved, isNull);
    });

    test('deleteTemplate throws when deleting built-in template', () async {
      expect(
        () => repository.deleteTemplate('builtin_blank'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Cannot delete built-in templates',
        )),
      );
    });

    test('deleteTemplate is idempotent for non-existent templates', () async {
      await expectLater(
        repository.deleteTemplate('non_existent'),
        returnsNormally,
      );
    });

    test('createTemplate stores variables', () async {
      final variables = <TemplateVariable>[
        TemplateVariable(name: 'date', type: 'date', defaultValue: 'today'),
        TemplateVariable(name: 'title', type: 'text'),
      ];
      final custom = TemplateEntity(
        id: 'ignored',
        name: 'Custom With Variables',
        title: 'Custom',
        content: 'Content',
        variables: variables,
      );

      final created = await repository.createTemplate(custom);

      expect(created.variables.length, 2);
      expect(created.variables[0].name, 'date');
      expect(created.variables[1].name, 'title');
    });

    test('createTemplate stores defaultFolderId', () async {
      final custom = TemplateEntity(
        id: 'ignored',
        name: 'Custom',
        title: 'Custom',
        content: 'Content',
        variables: <TemplateVariable>[],
        defaultFolderId: 'folder123',
      );

      final created = await repository.createTemplate(custom);

      expect(created.defaultFolderId, 'folder123');
    });
  });
}
