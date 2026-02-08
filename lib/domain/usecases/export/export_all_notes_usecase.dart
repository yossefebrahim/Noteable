import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class ExportAllNotesUseCase {
  final NoteRepository _noteRepository;
  final String format;

  ExportAllNotesUseCase({
    required NoteRepository noteRepository,
    required this.format,
  }) : _noteRepository = noteRepository;

  Future<Result<String>> call() async {
    try {
      final exportedContent = await _noteRepository.exportAllNotes(format);
      return Result.success(exportedContent);
    } catch (e) {
      return Result.failure('Failed to export all notes: $e');
    }
  }
}
