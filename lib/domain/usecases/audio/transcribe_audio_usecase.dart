import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/transcription.dart';
import 'package:noteable_app/domain/repositories/transcription_repository.dart';

class TranscribeAudioUseCase {
  final TranscriptionRepository _transcriptionRepository;
  final String _audioFilePath;

  TranscribeAudioUseCase({
    required TranscriptionRepository transcriptionRepository,
    required String audioFilePath,
  }) : _transcriptionRepository = transcriptionRepository,
       _audioFilePath = audioFilePath;

  Future<Result<Transcription>> call() async {
    try {
      final transcription = await _transcriptionRepository.transcribeAudio(_audioFilePath);
      return Result.success(transcription);
    } catch (e) {
      return Result.failure('Failed to transcribe audio: $e');
    }
  }
}
