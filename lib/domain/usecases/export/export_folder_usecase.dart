import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class ExportFolderUseCase {
  final NoteRepository _noteRepository;
  final String? _folderId;

  ExportFolderUseCase({
    required NoteRepository noteRepository,
    required String? folderId,
  }) : _noteRepository = noteRepository,
       _folderId = folderId;

  Future<Result<String>> call() async {
    try {
      final exportedContent = await _noteRepository.exportFolder(_folderId);
      return Result.success(exportedContent);
    } catch (e) {
      return Result.failure('Failed to export folder: $e');
    }
  }
}
