class Note {
  final String id;
  final String title;
  final String content;
  final bool isPinned;
  final String? folderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.isPinned = false,
    this.folderId,
    required this.createdAt,
    required this.updatedAt,
  });
}
