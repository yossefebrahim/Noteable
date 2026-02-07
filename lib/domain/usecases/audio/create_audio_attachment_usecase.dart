import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/audio_attachment.dart';
import 'package:noteable_app/domain/repositories/audio_repository.dart';

class CreateAudioAttachmentUseCase {
  final AudioRepository _audioRepository;
  final AudioAttachment _audioAttachment;

  CreateAudioAttachmentUseCase({
    required AudioRepository audioRepository,
    required AudioAttachment audioAttachment,
  }) : _audioRepository = audioRepository,
       _audioAttachment = audioAttachment;

  Future<Result<AudioAttachment>> call() async {
    try {
      final created = await _audioRepository.createAudioAttachment(_audioAttachment);
      return Result.success(created);
    } catch (e) {
      return Result.failure('Failed to create audio attachment: $e');
    }
  }
}
