import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class RestoreNoteUseCase {
  final NoteRepository _noteRepository;
  final String _noteId;

  RestoreNoteUseCase({
    required NoteRepository noteRepository,
    required String noteId,
  }) : _noteRepository = noteRepository,
       _noteId = noteId;

  Future<Result<void>> call() async {
    try {
      await _noteRepository.restoreNote(_noteId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to restore note: $e');
    }
  }
}
