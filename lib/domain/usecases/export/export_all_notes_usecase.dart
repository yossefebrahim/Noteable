import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class ExportAllNotesUseCase {
  final NoteRepository _noteRepository;

  ExportAllNotesUseCase({required NoteRepository noteRepository})
    : _noteRepository = noteRepository;

  Future<Result<String>> call() async {
    try {
      final exportedContent = await _noteRepository.exportAllNotes();
      return Result.success(exportedContent);
    } catch (e) {
      return Result.failure('Failed to export all notes: $e');
    }
  }
}
