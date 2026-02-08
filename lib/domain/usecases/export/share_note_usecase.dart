import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class ShareNoteUseCase {
  final NoteRepository _noteRepository;
  final String _noteId;

  ShareNoteUseCase({
    required NoteRepository noteRepository,
    required String noteId,
  }) : _noteRepository = noteRepository,
       _noteId = noteId;

  Future<Result<String>> call() async {
    try {
      final shareableContent = await _noteRepository.getShareableNoteContent(_noteId);
      return Result.success(shareableContent);
    } catch (e) {
      return Result.failure('Failed to get shareable content: $e');
    }
  }
}
