import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class GetNoteByIdUseCase {
  final NoteRepository _noteRepository;
  final String _noteId;

  GetNoteByIdUseCase({
    required NoteRepository noteRepository,
    required String noteId,
  }) : _noteRepository = noteRepository,
       _noteId = noteId;

  Future<Result<Note?>> call() async {
    try {
      final note = await _noteRepository.getNoteById(_noteId);
      return Result.success(note);
    } catch (e) {
      return Result.failure('Failed to fetch note by id: $e');
    }
  }
}
