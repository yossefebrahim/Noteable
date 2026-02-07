import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class CreateNoteUseCase {
  final NoteRepository _noteRepository;
  final Note _note;

  CreateNoteUseCase({required NoteRepository noteRepository, required Note note})
    : _noteRepository = noteRepository,
      _note = note;

  Future<Result<Note>> call() async {
    try {
      final created = await _noteRepository.createNote(_note);
      return Result.success(created);
    } catch (e) {
      return Result.failure('Failed to create note: $e');
    }
  }
}
