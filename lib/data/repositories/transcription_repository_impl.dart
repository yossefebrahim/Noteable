import 'package:noteable_app/domain/entities/transcription.dart';
import 'package:noteable_app/domain/repositories/transcription_repository.dart';

import '../../services/storage/isar_service.dart';
import '../models/transcription_model.dart';

class TranscriptionRepositoryImpl implements TranscriptionRepository {
  TranscriptionRepositoryImpl(this._isarService);

  final IsarService _isarService;

  @override
  Future<void> initialize() => _isarService.init();

  @override
  Future<List<Transcription>> getTranscriptions() async {
    final transcriptions = await _isarService.getTranscriptions();
    return transcriptions.map(_toEntity).toList(growable: false);
  }

  @override
  Future<Transcription?> getTranscriptionById(String id) async {
    final model = await _isarService.getTranscriptionById(int.parse(id));
    if (model == null) return null;
    return _toEntity(model);
  }

  @override
  Future<List<Transcription>> getTranscriptionsByAudioAttachmentId(
    String audioAttachmentId,
  ) async {
    final transcriptions = await _isarService.getTranscriptionsByAudioAttachmentId(
      int.parse(audioAttachmentId),
    );
    return transcriptions.map(_toEntity).toList(growable: false);
  }

  @override
  Future<Transcription> createTranscription(Transcription transcription) async {
    final model = _toModel(transcription);
    final id = await _isarService.putTranscription(model);
    final created = await _isarService.getTranscriptionById(id);
    return _toEntity(created!);
  }

  @override
  Future<Transcription> transcribeAudio(String audioFilePath) async {
    // TODO: Implement actual audio transcription
    // This would use a speech-to-text service/API to transcribe the audio file
    // For now, return a placeholder transcription
    final transcription = Transcription(
      id: '', // Will be set by createTranscription
      text: 'Transcription placeholder for $audioFilePath',
      confidence: 0.0,
      timestamp: DateTime.now(),
      audioAttachmentId: null,
    );
    return createTranscription(transcription);
  }

  @override
  Future<Transcription> updateTranscription(Transcription transcription) async {
    final model = _toModel(transcription);
    await _isarService.putTranscription(model);
    final updated = await _isarService.getTranscriptionById(model.id);
    return _toEntity(updated!);
  }

  @override
  Future<void> deleteTranscription(String id) async {
    await _isarService.deleteTranscription(int.parse(id));
  }

  TranscriptionModel _toModel(Transcription transcription) =>
      TranscriptionModel(
        id: int.tryParse(transcription.id) ?? 0,
        text: transcription.text,
        confidence: transcription.confidence,
        timestamp: transcription.timestamp,
        audioAttachmentId: transcription.audioAttachmentId != null
            ? int.tryParse(transcription.audioAttachmentId!)
            : null,
      );

  Transcription _toEntity(TranscriptionModel model) => Transcription(
        id: model.id.toString(),
        text: model.text,
        confidence: model.confidence,
        timestamp: model.timestamp,
        audioAttachmentId: model.audioAttachmentId?.toString(),
      );
}
