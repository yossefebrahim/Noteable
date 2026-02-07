import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class DeleteNoteUseCase {
  final NoteRepository _noteRepository;
  final String _noteId;

  DeleteNoteUseCase({
    required NoteRepository noteRepository,
    required String noteId,
  }) : _noteRepository = noteRepository,
       _noteId = noteId;

  Future<Result<void>> call() async {
    try {
      await _noteRepository.deleteNote(_noteId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete note: $e');
    }
  }
}
