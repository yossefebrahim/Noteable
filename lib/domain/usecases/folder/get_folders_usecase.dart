import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/folder.dart';
import 'package:noteable_app/domain/repositories/folder_repository.dart';

class GetFoldersUseCase {
  final FolderRepository _folderRepository;

  GetFoldersUseCase({required FolderRepository folderRepository})
    : _folderRepository = folderRepository;

  Future<Result<List<Folder>>> call() async {
    try {
      final folders = await _folderRepository.getFolders();
      return Result.success(folders);
    } catch (e) {
      return Result.failure('Failed to fetch folders: $e');
    }
  }
}
