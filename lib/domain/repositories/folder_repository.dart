import 'package:noteable_app/domain/entities/folder.dart';
import 'package:noteable_app/domain/repositories/base_repository.dart';

abstract interface class FolderRepository implements BaseRepository {
  Future<List<Folder>> getFolders();

  Future<Folder> createFolder(Folder folder);
}
