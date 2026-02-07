import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class GetNoteListUseCase {
  final NoteRepository _noteRepository;

  GetNoteListUseCase({required NoteRepository noteRepository})
    : _noteRepository = noteRepository;

  Future<Result<List<Note>>> call() async {
    try {
      final notes = await _noteRepository.getNoteList();
      return Result.success(notes);
    } catch (e) {
      return Result.failure('Failed to fetch notes: $e');
    }
  }
}
