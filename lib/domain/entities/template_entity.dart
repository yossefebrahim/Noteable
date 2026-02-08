import 'template_variable.dart';

class TemplateEntity {
  TemplateEntity({
    required this.id,
    required this.name,
    required this.title,
    required this.content,
    required this.variables,
    this.defaultFolderId,
    this.isBuiltIn = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String title;
  final String content;
  final List<TemplateVariable> variables;
  final String? defaultFolderId;
  final bool isBuiltIn;
  final DateTime createdAt;

  TemplateEntity copyWith({
    String? id,
    String? name,
    String? title,
    String? content,
    List<TemplateVariable>? variables,
    String? defaultFolderId,
    bool clearDefaultFolderId = false,
    bool? isBuiltIn,
    DateTime? createdAt,
  }) {
    return TemplateEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      content: content ?? this.content,
      variables: variables ?? this.variables,
      defaultFolderId:
          clearDefaultFolderId ? null : (defaultFolderId ?? this.defaultFolderId),
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
