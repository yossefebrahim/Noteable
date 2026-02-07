import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/folder.dart';
import 'package:noteable_app/domain/repositories/folder_repository.dart';

class CreateFolderUseCase {
  final FolderRepository _folderRepository;
  final Folder _folder;

  CreateFolderUseCase({
    required FolderRepository folderRepository,
    required Folder folder,
  }) : _folderRepository = folderRepository,
       _folder = folder;

  Future<Result<Folder>> call() async {
    try {
      final created = await _folderRepository.createFolder(_folder);
      return Result.success(created);
    } catch (e) {
      return Result.failure('Failed to create folder: $e');
    }
  }
}
