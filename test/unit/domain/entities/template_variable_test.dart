import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';

void main() {
  group('TemplateVariable', () {
    test('creates with required fields', () {
      final variable = TemplateVariable(
        name: 'date',
        type: 'date',
      );

      expect(variable.name, 'date');
      expect(variable.type, 'date');
      expect(variable.defaultValue, isNull);
    });

    test('creates with optional defaultValue', () {
      final variable = TemplateVariable(
        name: 'priority',
        type: 'text',
        defaultValue: 'Medium',
      );

      expect(variable.name, 'priority');
      expect(variable.type, 'text');
      expect(variable.defaultValue, 'Medium');
    });

    test('copyWith creates new instance with updated fields', () {
      final original = TemplateVariable(
        name: 'date',
        type: 'date',
        defaultValue: 'today',
      );

      final updated = original.copyWith(
        name: 'time',
        defaultValue: 'now',
      );

      expect(updated.name, 'time');
      expect(updated.type, 'date'); // unchanged
      expect(updated.defaultValue, 'now');
    });

    test('copyWith can clear defaultValue', () {
      final original = TemplateVariable(
        name: 'priority',
        type: 'text',
        defaultValue: 'High',
      );

      final updated = original.copyWith(clearDefaultValue: true);

      expect(updated.defaultValue, isNull);
    });

    test('copyWith prioritizes clearDefaultValue over defaultValue', () {
      final original = TemplateVariable(
        name: 'priority',
        type: 'text',
        defaultValue: 'High',
      );

      final updated = original.copyWith(
        defaultValue: 'Low',
        clearDefaultValue: true,
      );

      expect(updated.defaultValue, isNull);
    });

    test('copyWith preserves original when no params provided', () {
      final original = TemplateVariable(
        name: 'title',
        type: 'text',
        defaultValue: 'Untitled',
      );

      final copied = original.copyWith();

      expect(copied.name, original.name);
      expect(copied.type, original.type);
      expect(copied.defaultValue, original.defaultValue);
    });

    test('supports different variable types', () {
      final textVar = TemplateVariable(name: 'title', type: 'text');
      final dateVar = TemplateVariable(name: 'date', type: 'date');
      final timeVar = TemplateVariable(name: 'time', type: 'time');
      final multilineVar = TemplateVariable(name: 'notes', type: 'text_multiline');

      expect(textVar.type, 'text');
      expect(dateVar.type, 'date');
      expect(timeVar.type, 'time');
      expect(multilineVar.type, 'text_multiline');
    });
  });
}
