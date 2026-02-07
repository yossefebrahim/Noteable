import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class UpdateNoteUseCase {
  final NoteRepository _noteRepository;
  final Note _note;

  UpdateNoteUseCase({required NoteRepository noteRepository, required Note note})
    : _noteRepository = noteRepository,
      _note = note;

  Future<Result<Note>> call() async {
    try {
      final updated = await _noteRepository.updateNote(_note);
      return Result.success(updated);
    } catch (e) {
      return Result.failure('Failed to update note: $e');
    }
  }
}
