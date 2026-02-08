import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';
import 'package:noteable_app/domain/usecases/template/apply_template_usecase.dart';

void main() {
  group('ApplyTemplateUseCase', () {
    test('substitutes date variable in title', () {
      final now = DateTime.now();
      final expectedMonth = <String>[
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][now.month - 1];

      final template = TemplateEntity(
        id: '1',
        name: 'Meeting',
        title: 'Meeting: {{date}}',
        content: 'Content',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'date', type: 'date'),
        ],
      );

      final useCase = ApplyTemplateUseCase(template: template);
      final result = useCase();

      expect(result.isSuccess, isTrue);
      expect(result.data!.title, contains('$expectedMonth ${now.day}'));
      expect(result.data!.title, contains('${now.year}'));
    });

    test('substitutes time variable in content', () {
      final template = TemplateEntity(
        id: '1',
        name: 'Meeting',
        title: 'Meeting',
        content: 'Meeting started at {{time}}',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'time', type: 'time'),
        ],
      );

      final useCase = ApplyTemplateUseCase(template: template);
      final result = useCase();

      expect(result.isSuccess, isTrue);
      expect(result.data!.content, contains(RegExp(r'\d{1,2}:\d{2} [AP]M')));
    });

    test('uses defaultValue for text variables', () {
      final template = TemplateEntity(
        id: '1',
        name: 'Bug Report',
        title: 'Bug: {{title}}',
        content: 'Severity: {{severity}}',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'title', type: 'text', defaultValue: 'Crash on startup'),
          TemplateVariable(name: 'severity', type: 'text', defaultValue: 'High'),
        ],
      );

      final useCase = ApplyTemplateUseCase(template: template);
      final result = useCase();

      expect(result.isSuccess, isTrue);
      expect(result.data!.title, 'Bug: Crash on startup');
      expect(result.data!.content, 'Severity: High');
    });

    test('uses empty string when defaultValue is null for text variables', () {
      final template = TemplateEntity(
        id: '1',
        name: 'Simple',
        title: '{{placeholder}}',
        content: 'Content',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'placeholder', type: 'text'),
        ],
      );

      final useCase = ApplyTemplateUseCase(template: template);
      final result = useCase();

      expect(result.isSuccess, isTrue);
      expect(result.data!.title, isEmpty);
    });

    test('substitutes multiple variables throughout content', () {
      final template = TemplateEntity(
        id: '1',
        name: 'Journal',
        title: 'Journal - {{date}}',
        content: '''# Journal Entry

Mood: {{mood}}
Highlights: {{highlight}}

Time: {{time}}''',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'date', type: 'date'),
          TemplateVariable(name: 'mood', type: 'text', defaultValue: 'Happy'),
          TemplateVariable(name: 'highlight', type: 'text', defaultValue: 'Great day'),
          TemplateVariable(name: 'time', type: 'time'),
        ],
      );

      final useCase = ApplyTemplateUseCase(template: template);
      final result = useCase();

      expect(result.isSuccess, isTrue);
      expect(result.data!.content, contains('Mood: Happy'));
      expect(result.data!.content, contains('Highlights: Great day'));
      expect(result.data!.content, contains(RegExp(r'Time: \d{1,2}:\d{2} [AP]M')));
    });

    test('handles variables without placeholders', () {
      final template = TemplateEntity(
        id: '1',
        name: 'Simple',
        title: 'Simple Title',
        content: 'Simple Content',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'unused', type: 'text', defaultValue: 'Value'),
        ],
      );

      final useCase = ApplyTemplateUseCase(template: template);
      final result = useCase();

      expect(result.isSuccess, isTrue);
      expect(result.data!.title, 'Simple Title');
      expect(result.data!.content, 'Simple Content');
    });

    test('handles template with no variables', () {
      final template = TemplateEntity(
        id: '1',
        name: 'Blank',
        title: 'My Title',
        content: 'My Content',
        variables: <TemplateVariable>[],
      );

      final useCase = ApplyTemplateUseCase(template: template);
      final result = useCase();

      expect(result.isSuccess, isTrue);
      expect(result.data!.title, 'My Title');
      expect(result.data!.content, 'My Content');
    });

    test('handles text_multiline type as text variable', () {
      final template = TemplateEntity(
        id: '1',
        name: 'Notes',
        title: 'Notes',
        content: 'My notes: {{notes}}',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'notes', type: 'text_multiline'),
        ],
      );

      final useCase = ApplyTemplateUseCase(template: template);
      final result = useCase();

      expect(result.isSuccess, isTrue);
      expect(result.data!.content, 'My notes: ');
    });

    test('replaces all occurrences of the same variable', () {
      final template = TemplateEntity(
        id: '1',
        name: 'Recurring',
        title: '{{name}} - {{name}}',
        content: 'Hello {{name}}, welcome {{name}}',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'name', type: 'text', defaultValue: 'John'),
        ],
      );

      final useCase = ApplyTemplateUseCase(template: template);
      final result = useCase();

      expect(result.isSuccess, isTrue);
      expect(result.data!.title, 'John - John');
      expect(result.data!.content, 'Hello John, welcome John');
    });
  });
}
