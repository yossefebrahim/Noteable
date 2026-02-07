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
        id: 'builtin_project',
        name: 'Project Plan',
        title: 'Project: {{project_name}}',
        content: '''# Project: {{project_name}}

**Start Date:** {{start_date}}
**Target Date:** {{target_date}}
**Status:** {{status}}

## Overview
{{overview}}

## Objectives
{{objectives}}

## Milestones
1. {{milestone1}} - {{milestone1_date}}
2. {{milestone2}} - {{milestone2_date}}
3. {{milestone3}} - {{milestone3_date}}

## Resources
{{resources}}

## Risks & Mitigation
{{risks}}''',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'project_name', type: 'text'),
          TemplateVariable(name: 'start_date', type: 'date', defaultValue: 'today'),
          TemplateVariable(name: 'target_date', type: 'date'),
          TemplateVariable(name: 'status', type: 'text', defaultValue: 'Planning'),
          TemplateVariable(name: 'overview', type: 'text_multiline'),
          TemplateVariable(name: 'objectives', type: 'text_multiline'),
          TemplateVariable(name: 'milestone1', type: 'text'),
          TemplateVariable(name: 'milestone1_date', type: 'date'),
          TemplateVariable(name: 'milestone2', type: 'text'),
          TemplateVariable(name: 'milestone2_date', type: 'date'),
          TemplateVariable(name: 'milestone3', type: 'text'),
          TemplateVariable(name: 'milestone3_date', type: 'date'),
          TemplateVariable(name: 'resources', type: 'text_multiline'),
          TemplateVariable(name: 'risks', type: 'text_multiline'),
        ],
        isBuiltIn: true,
      ),
      TemplateEntity(
        id: 'builtin_bug_report',
        name: 'Bug Report',
        title: 'Bug: {{title}}',
        content: '''# Bug Report: {{title}}

**Severity:** {{severity}}
**Priority:** {{priority}}
**Status:** {{status}}

## Description
{{description}}

## Steps to Reproduce
1. {{step1}}
2. {{step2}}
3. {{step3}}

## Expected Behavior
{{expected_behavior}}

## Actual Behavior
{{actual_behavior}}

## Environment
- **OS:** {{os}}
- **Version:** {{version}}

## Screenshots
{{screenshots}}

## Additional Notes
{{notes}}''',
        variables: <TemplateVariable>[
          TemplateVariable(name: 'title', type: 'text'),
          TemplateVariable(name: 'severity', type: 'text', defaultValue: 'Medium'),
          TemplateVariable(name: 'priority', type: 'text', defaultValue: 'Normal'),
          TemplateVariable(name: 'status', type: 'text', defaultValue: 'Open'),
          TemplateVariable(name: 'description', type: 'text_multiline'),
          TemplateVariable(name: 'step1', type: 'text'),
          TemplateVariable(name: 'step2', type: 'text'),
          TemplateVariable(name: 'step3', type: 'text'),
          TemplateVariable(name: 'expected_behavior', type: 'text_multiline'),
          TemplateVariable(name: 'actual_behavior', type: 'text_multiline'),
          TemplateVariable(name: 'os', type: 'text'),
          TemplateVariable(name: 'version', type: 'text'),
          TemplateVariable(name: 'screenshots', type: 'text_multiline'),
          TemplateVariable(name: 'notes', type: 'text_multiline'),
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
