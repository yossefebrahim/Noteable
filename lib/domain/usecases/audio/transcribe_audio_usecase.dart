import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/transcription.dart';
import 'package:noteable_app/domain/repositories/transcription_repository.dart';

class TranscribeAudioUseCase {
  final TranscriptionRepository _transcriptionRepository;

  TranscribeAudioUseCase(this._transcriptionRepository);

  Future<Result<Transcription>> call(String audioFilePath) async {
    try {
      final transcription = await _transcriptionRepository.transcribeAudio(audioFilePath);
      return Result.success(transcription);
    } catch (e) {
      return Result.failure('Failed to transcribe audio: $e');
    }
  }
}
