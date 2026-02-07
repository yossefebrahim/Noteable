import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final Map<String, TemplateEntity> _templates = <String, TemplateEntity>{};

  TemplateRepositoryImpl() {
    _initializeBuiltInTemplates();
  }

  void _initializeBuiltInTemplates() {
    final List<TemplateEntity> builtInTemplates = <TemplateEntity>[
      TemplateEntity(
        id: 'builtin_blank',
        name: 'Blank Note',
        title: '',
        content: '',
        variables: <TemplateVariable>[],
        isBuiltIn: true,
      ),
      TemplateEntity(
        id: 'builtin_meeting',
        name: 'Meeting Notes',
        title: 'Meeting: {{date}}',
        content: '''# Meeting: {{date}}

**Attendees:** {{attendees}}

## Agenda
{{agenda}}

## Discussion Notes
{{notes}}

## Action Items
- [ ] {{action_items}}

## Next Meeting
**Date:** {{next_meeting_date}}
**Location:** {{location}}''',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'date', type: 'date', defaultValue: 'today'),
          TemplateVariable(name: 'attendees', type: 'text'),
          TemplateVariable(name: 'agenda', type: 'text'),
          TemplateVariable(name: 'notes', type: 'text_multiline'),
          TemplateVariable(name: 'action_items', type: 'text'),
          TemplateVariable(name: 'next_meeting_date', type: 'date'),
          TemplateVariable(name: 'location', type: 'text'),
        ],
        isBuiltIn: true,
      ),
      TemplateEntity(
        id: 'builtin_journal',
        name: 'Daily Journal',
        title: 'Journal Entry - {{date}}',
        content: '''# Journal Entry - {{date}}

## Mood
{{mood}}

## Highlights
- {{highlight1}}
- {{highlight2}}
- {{highlight3}}

## Thoughts & Reflections
{{thoughts}}

## Tomorrow's Goals
{{tomorrow_goals}}

## Gratitude
{{gratitude}}''',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'date', type: 'date', defaultValue: 'today'),
          TemplateVariable(name: 'mood', type: 'text'),
          TemplateVariable(name: 'highlight1', type: 'text'),
          TemplateVariable(name: 'highlight2', type: 'text'),
          TemplateVariable(name: 'highlight3', type: 'text'),
          TemplateVariable(name: 'thoughts', type: 'text_multiline'),
          TemplateVariable(name: 'tomorrow_goals', type: 'text_multiline'),
          TemplateVariable(name: 'gratitude', type: 'text_multiline'),
        ],
        isBuiltIn: true,
      ),
      TemplateEntity(
        id: 'builtin_weekly',
        name: 'Weekly Plan',
        title: 'Weekly Plan - Week of {{date}}',
        content: '''# Weekly Plan - Week of {{date}}

## Goals for This Week
{{goals}}

## Priority Tasks
1. {{task1}}
2. {{task2}}
3. {{task3}}
4. {{task4}}
5. {{task5}}

## Schedule
### Monday
{{monday}}

### Tuesday
{{tuesday}}

### Wednesday
{{wednesday}}

### Thursday
{{thursday}}

### Friday
{{friday}}

## Notes & Reflections
{{notes}}

## Next Week Preview
{{next_week}}''',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'date', type: 'date', defaultValue: 'today'),
          TemplateVariable(name: 'goals', type: 'text_multiline'),
          TemplateVariable(name: 'task1', type: 'text'),
          TemplateVariable(name: 'task2', type: 'text'),
          TemplateVariable(name: 'task3', type: 'text'),
          TemplateVariable(name: 'task4', type: 'text'),
          TemplateVariable(name: 'task5', type: 'text'),
          TemplateVariable(name: 'monday', type: 'text_multiline'),
          TemplateVariable(name: 'tuesday', type: 'text_multiline'),
          TemplateVariable(name: 'wednesday', type: 'text_multiline'),
          TemplateVariable(name: 'thursday', type: 'text_multiline'),
          TemplateVariable(name: 'friday', type: 'text_multiline'),
          TemplateVariable(name: 'notes', type: 'text_multiline'),
          TemplateVariable(name: 'next_week', type: 'text_multiline'),
        ],
        isBuiltIn: true,
      ),
      TemplateEntity(
        id: 'builtin_book',
        name: 'Book Notes',
        title: 'Book Notes: {{title}} by {{author}}',
        content: '''# Book Notes: {{title}} by {{author}}

**Start Date:** {{start_date}}
**Finish Date:** {{finish_date}}
**Rating:** {{rating}}/5

## Book Summary
{{summary}}

## Key Takeaways
1. {{takeaway1}}
2. {{takeaway2}}
3. {{takeaway3}}

## Favorite Quotes
> "{{quote1}}"

> "{{quote2}}"

## Notes by Chapter/Section
{{chapter_notes}}

## Personal Reflections
{{reflections}}

## Recommendations
{{recommendations}}

Would I recommend this book? {{would_recommend}}''',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'title', type: 'text'),
          TemplateVariable(name: 'author', type: 'text'),
          TemplateVariable(name: 'start_date', type: 'date', defaultValue: 'today'),
          TemplateVariable(name: 'finish_date', type: 'date'),
          TemplateVariable(name: 'rating', type: 'text', defaultValue: '5'),
          TemplateVariable(name: 'summary', type: 'text_multiline'),
          TemplateVariable(name: 'takeaway1', type: 'text'),
          TemplateVariable(name: 'takeaway2', type: 'text'),
          TemplateVariable(name: 'takeaway3', type: 'text'),
          TemplateVariable(name: 'quote1', type: 'text_multiline'),
          TemplateVariable(name: 'quote2', type: 'text_multiline'),
          TemplateVariable(name: 'chapter_notes', type: 'text_multiline'),
          TemplateVariable(name: 'reflections', type: 'text_multiline'),
          TemplateVariable(name: 'recommendations', type: 'text_multiline'),
          TemplateVariable(name: 'would_recommend', type: 'text', defaultValue: 'Yes'),
        ],
        isBuiltIn: true,
      ),
    ];

    for (final TemplateEntity template in builtInTemplates) {
      _templates[template.id] = template;
    }
  }

  @override
  Future<List<TemplateEntity>> getTemplates() async {
    final List<TemplateEntity> templates = _templates.values.toList()
      ..sort((TemplateEntity a, TemplateEntity b) {
        if (a.isBuiltIn != b.isBuiltIn) {
          return a.isBuiltIn ? -1 : 1;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return templates;
  }

  @override
  Future<TemplateEntity?> getTemplateById(String id) async => _templates[id];

  @override
  Future<TemplateEntity> createTemplate(TemplateEntity template) async {
    final String id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final TemplateEntity newTemplate = template.copyWith(id: id);
    _templates[id] = newTemplate;
    return newTemplate;
  }

  @override
  Future<TemplateEntity> updateTemplate(TemplateEntity template) async {
    if (template.isBuiltIn) {
      throw ArgumentError('Cannot update built-in templates');
    }
    _templates[template.id] = template;
    return template;
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final TemplateEntity? template = _templates[id];
    if (template != null && template.isBuiltIn) {
      throw ArgumentError('Cannot delete built-in templates');
    }
    _templates.remove(id);
  }
}
