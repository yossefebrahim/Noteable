import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

/// Use case for searching notes by query string.
///
/// The search includes:
/// - Note titles
/// - Note content
/// - Transcription text from audio attachments
///
/// This allows users to find notes by searching for words
/// they spoke in voice recordings.
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
