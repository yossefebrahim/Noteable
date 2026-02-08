import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';

/// A simple data class to hold the result of applying a template
class AppliedTemplate {
  final String title;
  final String content;

  const AppliedTemplate({required this.title, required this.content});
}

class ApplyTemplateUseCase {
  final TemplateEntity _template;

  ApplyTemplateUseCase({required TemplateEntity template}) : _template = template;

  /// Applies variable substitution to the template and returns the result
  Result<AppliedTemplate> call() {
    try {
      final substitutedTitle = _substituteVariables(_template.title);
      final substitutedContent = _substituteVariables(_template.content);

      final result = AppliedTemplate(
        title: substitutedTitle,
        content: substitutedContent,
      );

      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to apply template: $e');
    }
  }

  /// Substitutes variables in the given text
  String _substituteVariables(String text) {
    String result = text;

    // Get variable substitutions map
    final substitutions = _getVariableSubstitutions();

    // Replace each variable placeholder with its value
    for (final entry in substitutions.entries) {
      final placeholder = '{{${entry.key}}}';
      result = result.replaceAll(placeholder, entry.value);
    }

    return result;
  }

  /// Builds a map of variable names to their substituted values
  Map<String, String> _getVariableSubstitutions() {
    final Map<String, String> substitutions = {};

    for (final variable in _template.variables) {
      final value = _getVariableValue(variable);
      substitutions[variable.name] = value;
    }

    return substitutions;
  }

  /// Gets the value for a single variable based on its type
  String _getVariableValue(TemplateVariable variable) {
    switch (variable.type) {
      case 'date':
        // Use current date in a readable format
        final now = DateTime.now();
        return '${_monthName(now.month)} ${now.day}, ${now.year}';

      case 'time':
        // Use current time in 12-hour format
        final now = DateTime.now();
        final hour = now.hour;
        final minute = now.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:$minute $period';

      default:
        // For text and other types, use default value if available, otherwise empty string
        return variable.defaultValue ?? '';
    }
  }

  /// Returns the month name for a given month number (1-12)
  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
