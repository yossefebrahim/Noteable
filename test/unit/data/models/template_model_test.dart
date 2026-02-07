import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/data/models/template_model.dart';

void main() {
  group('TemplateModel', () {
    test('creates with required fields', () {
      final model = TemplateModel(
        uuid: 'test-uuid',
        name: 'Test Template',
        title: 'Test Title',
        content: 'Test Content',
        createdAt: DateTime(2026, 2, 8),
      );

      expect(model.uuid, 'test-uuid');
      expect(model.name, 'Test Name');
      expect(model.title, 'Test Title');
      expect(model.content, 'Test Content');
      expect(model.createdAt, DateTime(2026, 2, 8));
      expect(model.defaultFolderId, isNull);
      expect(model.isBuiltIn, isFalse);
    });

    test('creates with optional fields', () {
      final model = TemplateModel(
        uuid: 'test-uuid',
        name: 'Test Template',
        title: 'Test Title',
        content: 'Test Content',
        createdAt: DateTime(2026, 2, 8),
        defaultFolderId: 'folder123',
        isBuiltIn: true,
      );

      expect(model.defaultFolderId, 'folder123');
      expect(model.isBuiltIn, isTrue);
    });

    test('toJson serializes correctly', () {
      final variable = TemplateVariableModel()
        ..name = 'date'
        ..type = 'date'
        ..defaultValue = 'today';
      final model = TemplateModel(
        uuid: 'test-uuid',
        name: 'Test Template',
        title: 'Test Title',
        content: 'Test Content',
        createdAt: DateTime(2026, 2, 8, 12, 30),
        defaultFolderId: 'folder123',
        isBuiltIn: true,
      );
      model.variables.add(variable);

      final json = model.toJson();

      expect(json['id'], 'test-uuid');
      expect(json['name'], 'Test Template');
      expect(json['title'], 'Test Title');
      expect(json['content'], 'Test Content');
      expect(json['createdAt'], '2026-02-08T12:30:00.000');
      expect(json['defaultFolderId'], 'folder123');
      expect(json['isBuiltIn'], isTrue);
      expect(json['variables'], isList);
      expect((json['variables'] as List).length, 1);
      expect((json['variables'] as List).first['name'], 'date');
    });

    test('fromJson deserializes correctly', () {
      final json = <String, dynamic>{
        'id': 'test-uuid',
        'name': 'Test Template',
        'title': 'Test Title',
        'content': 'Test Content',
        'createdAt': '2026-02-08T12:30:00.000',
        'defaultFolderId': 'folder123',
        'isBuiltIn': true,
        'variables': <dynamic>[
          <String, dynamic>{
            'name': 'date',
            'type': 'date',
            'defaultValue': 'today',
          },
        ],
      };

      final model = TemplateModel.fromJson(json);

      expect(model.uuid, 'test-uuid');
      expect(model.name, 'Test Template');
      expect(model.title, 'Test Title');
      expect(model.content, 'Test Content');
      expect(model.createdAt, DateTime(2026, 2, 8, 12, 30));
      expect(model.defaultFolderId, 'folder123');
      expect(model.isBuiltIn, isTrue);
      expect(model.variables.length, 1);
      expect(model.variables.first.name, 'date');
      expect(model.variables.first.type, 'date');
      expect(model.variables.first.defaultValue, 'today');
    });

    test('fromJson handles null isBuiltIn', () {
      final json = <String, dynamic>{
        'id': 'test-uuid',
        'name': 'Test Template',
        'title': 'Test Title',
        'content': 'Test Content',
        'createdAt': '2026-02-08T12:30:00.000',
        'variables': <dynamic>[],
      };

      final model = TemplateModel.fromJson(json);

      expect(model.isBuiltIn, isFalse);
    });

    test('fromJson handles null variables', () {
      final json = <String, dynamic>{
        'id': 'test-uuid',
        'name': 'Test Template',
        'title': 'Test Title',
        'content': 'Test Content',
        'createdAt': '2026-02-08T12:30:00.000',
        'variables': null,
      };

      final model = TemplateModel.fromJson(json);

      expect(model.variables, isEmpty);
    });
  });

  group('TemplateVariableModel', () {
    test('creates with default values', () {
      final model = TemplateVariableModel()
        ..name = 'test'
        ..type = 'text';

      expect(model.name, 'test');
      expect(model.type, 'text');
      expect(model.defaultValue, isNull);
    });

    test('toJson serializes correctly', () {
      final model = TemplateVariableModel()
        ..name = 'priority'
        ..type = 'text'
        ..defaultValue = 'High';

      final json = model.toJson();

      expect(json['name'], 'priority');
      expect(json['type'], 'text');
      expect(json['defaultValue'], 'High');
    });

    test('toJson omits null defaultValue', () {
      final model = TemplateVariableModel()
        ..name = 'title'
        ..type = 'text';

      final json = model.toJson();

      expect(json.containsKey('defaultValue'), isFalse);
    });

    test('fromJson deserializes correctly', () {
      final json = <String, dynamic>{
        'name': 'date',
        'type': 'date',
        'defaultValue': 'today',
      };

      final model = TemplateVariableModel.fromJson(json);

      expect(model.name, 'date');
      expect(model.type, 'date');
      expect(model.defaultValue, 'today');
    });

    test('fromJson handles null defaultValue', () {
      final json = <String, dynamic>{
        'name': 'title',
        'type': 'text',
      };

      final model = TemplateVariableModel.fromJson(json);

      expect(model.defaultValue, isNull);
    });
  });
}
