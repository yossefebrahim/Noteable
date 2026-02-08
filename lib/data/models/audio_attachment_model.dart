import 'package:isar/isar.dart';

part 'audio_attachment_model.g.dart';

@collection
class AudioAttachmentModel {
  AudioAttachmentModel({
    this.id = Isar.autoIncrement,
    required this.duration,
    required this.path,
    required this.format,
    required this.size,
    required this.createdAt,
    this.noteId,
  });

  Id id;

  @Index()
  late int duration;

  late String path;

  @Index()
  late String format;

  @Index()
  late int size;

  @Index()
  late DateTime createdAt;

  @Index()
  String? noteId;
}
