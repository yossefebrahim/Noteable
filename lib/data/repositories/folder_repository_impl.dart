import 'package:noteable_app/domain/entities/folder.dart';
import 'package:noteable_app/domain/repositories/folder_repository.dart';

import '../../services/storage/isar_service.dart';
import '../models/folder_model.dart';

class FolderRepositoryImpl implements FolderRepository {
  FolderRepositoryImpl(this._isarService);

  final IsarService _isarService;

  @override
  Future<void> initialize() => _isarService.init();

  @override
  Future<Folder> createFolder(Folder folder) async {
    final id = await _isarService.putFolder(_toModel(folder));
    final created = await _isarService.getFolderById(id);
    return _toEntity(created!);
  }

  @override
  Future<List<Folder>> getFolders() async {
    final folders = await _isarService.getFolders();
    return folders.map(_toEntity).toList(growable: false);
  }

  FolderModel _toModel(Folder folder) => FolderModel(
        id: int.tryParse(folder.id) ?? 0,
        name: folder.name,
        createdAt: folder.createdAt,
      );

  Folder _toEntity(FolderModel model) => Folder(
        id: model.id.toString(),
        name: model.name,
        createdAt: model.createdAt,
      );
}
