class AudioAttachment {
  final String id;
  final int duration;
  final String path;
  final String format;
  final int size;
  final DateTime createdAt;
  final String? noteId;

  const AudioAttachment({
    required this.id,
    required this.duration,
    required this.path,
    required this.format,
    required this.size,
    required this.createdAt,
    this.noteId,
  });
}
