import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';

class ExportNoteUseCase {
  final NoteRepository _noteRepository;
  final String _noteId;
  final String _format;

  ExportNoteUseCase({
    required NoteRepository noteRepository,
    required String noteId,
    required String format,
  }) : _noteRepository = noteRepository,
       _noteId = noteId,
       _format = format;

  Future<Result<String>> call() async {
    try {
      final exportedContent = await _noteRepository.exportNote(_noteId, _format);
      return Result.success(exportedContent);
    } catch (e) {
      return Result.failure('Failed to export note: $e');
    }
  }
}
