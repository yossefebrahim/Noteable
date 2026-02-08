import 'package:isar/isar.dart';

part 'deleted_note_model.g.dart';

@collection
class DeletedNoteModel {
  DeletedNoteModel({
    this.id = Isar.autoIncrement,
    required this.noteId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.folderId,
    required this.deletedAt,
  });

  Id id;

  @Index()
  late Id noteId;

  late String title;

  late String content;

  late DateTime createdAt;

  DateTime? updatedAt;

  bool isPinned;

  String? folderId;

  @Index()
  late DateTime deletedAt;
}
