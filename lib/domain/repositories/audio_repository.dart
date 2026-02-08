import 'package:noteable_app/domain/entities/audio_attachment.dart';
import 'package:noteable_app/domain/repositories/base_repository.dart';

abstract interface class AudioRepository implements BaseRepository {
  Future<List<AudioAttachment>> getAudioAttachments();

  Future<AudioAttachment?> getAudioAttachmentById(String id);

  Future<List<AudioAttachment>> getAudioAttachmentsByNoteId(String noteId);

  Future<AudioAttachment> createAudioAttachment(AudioAttachment audioAttachment);

  Future<AudioAttachment> updateAudioAttachment(AudioAttachment audioAttachment);

  Future<void> deleteAudioAttachment(String id);
}
