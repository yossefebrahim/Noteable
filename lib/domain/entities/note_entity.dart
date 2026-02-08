import 'audio_attachment.dart';

class NoteEntity {
  NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    this.isPinned = false,
    this.folderId,
    this.audioAttachments = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String title;
  final String content;
  final bool isPinned;
  final String? folderId;
  final List<AudioAttachment> audioAttachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    bool? isPinned,
    String? folderId,
    bool clearFolderId = false,
    List<AudioAttachment>? audioAttachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      folderId: clearFolderId ? null : (folderId ?? this.folderId),
      audioAttachments: audioAttachments ?? this.audioAttachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
