import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';

void main() {
  group('TemplateEntity', () {
    test('creates with all required fields', () {
      final template = TemplateEntity(
        id: 'test_id',
        name: 'Test Template',
        title: 'Test Title',
        content: 'Test Content',
        variables: <TemplateVariable>[],
      );

      expect(template.id, 'test_id');
      expect(template.name, 'Test Template');
      expect(template.title, 'Test Title');
      expect(template.content, 'Test Content');
      expect(template.variables, isEmpty);
      expect(template.isBuiltIn, isFalse);
      expect(template.defaultFolderId, isNull);
    });

    test('creates with optional fields', () {
      final date = DateTime(2026, 2, 8);
      final variable = TemplateVariable(name: 'date', type: 'date');
      final template = TemplateEntity(
        id: 'test_id',
        name: 'Test Template',
        title: 'Test Title',
        content: 'Test Content',
        variables: <TemplateVariable>[variable],
        defaultFolderId: 'folder123',
        isBuiltIn: true,
        createdAt: date,
      );

      expect(template.defaultFolderId, 'folder123');
      expect(template.isBuiltIn, isTrue);
      expect(template.createdAt, date);
      expect(template.variables.length, 1);
      expect(template.variables.first.name, 'date');
    });

    test('createdAt defaults to now when not provided', () {
      final before = DateTime.now();
      final template = TemplateEntity(
        id: 'test_id',
        name: 'Test Template',
        title: 'Test Title',
        content: 'Test Content',
        variables: <TemplateVariable>[],
      );
      final after = DateTime.now();

      expect(template.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(template.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = TemplateEntity(
        id: 'test_id',
        name: 'Original Name',
        title: 'Original Title',
        content: 'Original Content',
        variables: <TemplateVariable>[],
        defaultFolderId: 'folder123',
        isBuiltIn: false,
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        title: 'Updated Title',
      );

      expect(updated.id, 'test_id'); // unchanged
      expect(updated.name, 'Updated Name');
      expect(updated.title, 'Updated Title');
      expect(updated.content, 'Original Content'); // unchanged
      expect(updated.defaultFolderId, 'folder123'); // unchanged
      expect(updated.isBuiltIn, isFalse); // unchanged
    });

    test('copyWith can update variables', () {
      final original = TemplateEntity(
        id: 'test_id',
        name: 'Test Template',
        title: 'Test Title',
        content: 'Test Content',
        variables: <TemplateVariable>[],
      );

      final newVariable = TemplateVariable(name: 'date', type: 'date');
      final updated = original.copyWith(
        variables: <TemplateVariable>[newVariable],
      );

      expect(updated.variables.length, 1);
      expect(updated.variables.first.name, 'date');
    });

    test('copyWith can clear defaultFolderId', () {
      final original = TemplateEntity(
        id: 'test_id',
        name: 'Test Template',
        title: 'Test Title',
        content: 'Test Content',
        variables: <TemplateVariable>[],
        defaultFolderId: 'folder123',
      );

      final updated = original.copyWith(clearDefaultFolderId: true);

      expect(updated.defaultFolderId, isNull);
    });

    test('copyWith prioritizes clearDefaultFolderId over defaultFolderId', () {
      final original = TemplateEntity(
        id: 'test_id',
        name: 'Test Template',
        title: 'Test Title',
        content: 'Test Content',
        variables: <TemplateVariable>[],
        defaultFolderId: 'folder123',
      );

      final updated = original.copyWith(
        defaultFolderId: 'new_folder',
        clearDefaultFolderId: true,
      );

      expect(updated.defaultFolderId, isNull);
    });

    test('copyWith preserves original when no params provided', () {
      final original = TemplateEntity(
        id: 'test_id',
        name: 'Test Template',
        title: 'Test Title',
        content: 'Test Content',
        variables: <TemplateVariable>[],
      );

      final copied = original.copyWith();

      expect(copied.id, original.id);
      expect(copied.name, original.name);
      expect(copied.title, original.title);
      expect(copied.content, original.content);
      expect(copied.variables, original.variables);
    });
  });
}
