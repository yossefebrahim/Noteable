import 'package:isar/isar.dart';

part 'note_model.g.dart';

@collection
class NoteModel {
  NoteModel({
    this.id = Isar.autoIncrement,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.folderId,
  });

  Id id;

  late String title;
  late String content;

  @Index()
  late DateTime createdAt;

  DateTime? updatedAt;

  @Index()
  bool isPinned;

  @Index()
  String? folderId;
}
