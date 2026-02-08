class TemplateVariable {
  TemplateVariable({
    required this.name,
    required this.type,
    this.defaultValue,
  });

  final String name;
  final String type;
  final String? defaultValue;

  TemplateVariable copyWith({
    String? name,
    String? type,
    String? defaultValue,
    bool clearDefaultValue = false,
  }) {
    return TemplateVariable(
      name: name ?? this.name,
      type: type ?? this.type,
      defaultValue: clearDefaultValue ? null : (defaultValue ?? this.defaultValue),
    );
  }
}
