import 'package:isar/isar.dart';

part 'template_model.g.dart';

@collection
class TemplateModel {
  TemplateModel({
    this.id = Isar.autoIncrement,
    required this.uuid,
    required this.name,
    required this.title,
    required this.content,
    required this.createdAt,
    this.defaultFolderId,
    this.isBuiltIn = false,
  });

  Id id;

  @Index(unique: true)
  late String uuid;

  late String name;
  late String title;
  late String content;

  final variables = <TemplateVariableModel>[];

  @Index()
  String? defaultFolderId;

  @Index()
  late bool isBuiltIn;

  @Index()
  late DateTime createdAt;

  /// Converts the template to JSON for export/import
  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'name': name,
      'title': title,
      'content': content,
      'variables': variables.map((v) => v.toJson()).toList(),
      'defaultFolderId': defaultFolderId,
      'isBuiltIn': isBuiltIn,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a TemplateModel from JSON for import/export
  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    final model = TemplateModel(
      uuid: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      defaultFolderId: json['defaultFolderId'] as String?,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

    // Load variables from JSON
    final variablesJson = json['variables'] as List<dynamic>?;
    if (variablesJson != null) {
      model.variables.addAll(
        variablesJson
            .map((v) =>
                TemplateVariableModel.fromJson(v as Map<String, dynamic>))
            .toList(),
      );
    }

    return model;
  }
}

@embedded
class TemplateVariableModel {
  TemplateVariableModel();

  late String name;
  late String type;
  String? defaultValue;

  /// Converts the variable to JSON for export/import
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      if (defaultValue != null) 'defaultValue': defaultValue,
    };
  }

  /// Creates a TemplateVariableModel from JSON for import/export
  factory TemplateVariableModel.fromJson(Map<String, dynamic> json) {
    final model = TemplateVariableModel()
      ..name = json['name'] as String
      ..type = json['type'] as String
      ..defaultValue = json['defaultValue'] as String?;
    return model;
  }
}
