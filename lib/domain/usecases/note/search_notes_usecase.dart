import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class SearchNotesUseCase {
  final NoteRepository _noteRepository;
  final String _query;

  SearchNotesUseCase({
    required NoteRepository noteRepository,
    required String query,
  }) : _noteRepository = noteRepository,
       _query = query;

  Future<Result<List<Note>>> call() async {
    try {
      final notes = await _noteRepository.searchNotes(_query);
      return Result.success(notes);
    } catch (e) {
      return Result.failure('Failed to search notes: $e');
    }
  }
}
