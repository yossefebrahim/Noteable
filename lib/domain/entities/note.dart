import 'audio_attachment.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final bool isPinned;
  final String? folderId;
  final List<AudioAttachment> audioAttachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.isPinned = false,
    this.folderId,
    this.audioAttachments = const [],
    required this.createdAt,
    required this.updatedAt,
  });
}
