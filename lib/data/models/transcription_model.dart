import 'package:isar/isar.dart';

part 'transcription_model.g.dart';

@collection
class TranscriptionModel {
  TranscriptionModel({
    this.id = Isar.autoIncrement,
    required this.text,
    required this.confidence,
    required this.timestamp,
    this.audioAttachmentId,
  });

  Id id;

  late String text;

  @Index()
  late double confidence;

  @Index()
  late DateTime timestamp;

  @Index()
  int? audioAttachmentId;
}
