class Transcription {
  final String id;
  final String text;
  final double confidence;
  final DateTime timestamp;
  final String? audioAttachmentId;

  const Transcription({
    required this.id,
    required this.text,
    required this.confidence,
    required this.timestamp,
    this.audioAttachmentId,
  });
}
