import 'package:noteable_app/domain/entities/audio_attachment.dart';
import 'package:noteable_app/domain/repositories/audio_repository.dart';

import '../../services/storage/isar_service.dart';
import '../models/audio_attachment_model.dart';

class AudioRepositoryImpl implements AudioRepository {
  AudioRepositoryImpl(this._isarService);

  final IsarService _isarService;

  @override
  Future<void> initialize() => _isarService.init();

  @override
  Future<List<AudioAttachment>> getAudioAttachments() async {
    final attachments = await _isarService.getAudioAttachments();
    return attachments.map(_toEntity).toList(growable: false);
  }

  @override
  Future<AudioAttachment?> getAudioAttachmentById(String id) async {
    final model = await _isarService.getAudioAttachmentById(int.parse(id));
    if (model == null) return null;
    return _toEntity(model);
  }

  @override
  Future<List<AudioAttachment>> getAudioAttachmentsByNoteId(
    String noteId,
  ) async {
    final attachments = await _isarService.getAudioAttachmentsByNoteId(noteId);
    return attachments.map(_toEntity).toList(growable: false);
  }

  @override
  Future<AudioAttachment> createAudioAttachment(
    AudioAttachment audioAttachment,
  ) async {
    final model = _toModel(audioAttachment);
    final id = await _isarService.putAudioAttachment(model);
    final created = await _isarService.getAudioAttachmentById(id);
    return _toEntity(created!);
  }

  @override
  Future<AudioAttachment> updateAudioAttachment(
    AudioAttachment audioAttachment,
  ) async {
    final model = _toModel(audioAttachment);
    await _isarService.putAudioAttachment(model);
    final updated = await _isarService.getAudioAttachmentById(model.id);
    return _toEntity(updated!);
  }

  @override
  Future<void> deleteAudioAttachment(String id) async {
    await _isarService.deleteAudioAttachment(int.parse(id));
  }

  AudioAttachmentModel _toModel(AudioAttachment attachment) =>
      AudioAttachmentModel(
        id: int.tryParse(attachment.id) ?? 0,
        duration: attachment.duration,
        path: attachment.path,
        format: attachment.format,
        size: attachment.size,
        createdAt: attachment.createdAt,
        noteId: attachment.noteId,
      );

  AudioAttachment _toEntity(AudioAttachmentModel model) => AudioAttachment(
        id: model.id.toString(),
        duration: model.duration,
        path: model.path,
        format: model.format,
        size: model.size,
        createdAt: model.createdAt,
        noteId: model.noteId,
      );
}
