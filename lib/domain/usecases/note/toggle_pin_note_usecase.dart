import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class TogglePinNoteUseCase {
  final NoteRepository _noteRepository;
  final String _noteId;

  TogglePinNoteUseCase({
    required NoteRepository noteRepository,
    required String noteId,
  }) : _noteRepository = noteRepository,
       _noteId = noteId;

  Future<Result<Note>> call() async {
    try {
      final toggled = await _noteRepository.togglePinNote(_noteId);
      return Result.success(toggled);
    } catch (e) {
      return Result.failure('Failed to toggle pin state: $e');
    }
  }
}
