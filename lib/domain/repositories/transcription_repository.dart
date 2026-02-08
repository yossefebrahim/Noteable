import 'package:noteable_app/domain/entities/transcription.dart';
import 'package:noteable_app/domain/repositories/base_repository.dart';

abstract interface class TranscriptionRepository implements BaseRepository {
  Future<List<Transcription>> getTranscriptions();

  Future<Transcription?> getTranscriptionById(String id);

  Future<List<Transcription>> getTranscriptionsByAudioAttachmentId(String audioAttachmentId);

  Future<Transcription> createTranscription(Transcription transcription);

  Future<Transcription> transcribeAudio(String audioFilePath);

  Future<Transcription> updateTranscription(Transcription transcription);

  Future<void> deleteTranscription(String id);
}
