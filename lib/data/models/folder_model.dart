import 'package:isar/isar.dart';

part 'folder_model.g.dart';

@collection
class FolderModel {
  FolderModel({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.createdAt,
    this.colorHex = '#007AFF',
  });

  Id id;

  @Index(unique: true)
  late String name;

  late DateTime createdAt;

  @Index()
  late String colorHex;
}
