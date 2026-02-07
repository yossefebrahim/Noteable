class FolderEntity {
  FolderEntity({
    required this.id,
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final DateTime createdAt;

  FolderEntity copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return FolderEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
