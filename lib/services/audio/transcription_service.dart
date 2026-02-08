import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

/// Service for transcribing audio to text using the 'speech_to_text' package.
///
/// Provides methods for initializing the speech recognizer, checking availability,
/// starting/stopping transcription, and listening for transcription results.
class TranscriptionService {
  TranscriptionService();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  // Stream controllers for state and results
  final StreamController<bool> _isListeningController = StreamController<bool>.broadcast();
  final StreamController<String> _transcriptionController = StreamController<String>.broadcast();
  final StreamController<double> _confidenceController = StreamController<double>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();

  // Current transcription state
  bool _isListening = false;
  String _currentTranscription = '';
  double _lastConfidence = 0.0;
  String _status = 'idle';

  /// Initialize the transcription service
  Future<bool> init() async {
    if (_isInitialized) return true;

    final hasPermission = await _speechToText.initialize();
    _isInitialized = hasPermission;
    return hasPermission;
  }

  /// Check if speech recognition is available on the device
  Future<bool> isAvailable() async {
    await init();
    return _speechToText.isAvailable;
  }

  /// Stream that emits true when listening, false when not
  Stream<bool> get onListeningStateChanged => _isListeningController.stream;

  /// Stream that emits transcription text as it's recognized
  Stream<String> get onTranscriptionChanged => _transcriptionController.stream;

  /// Stream that emits confidence scores (0.0 to 1.0)
  Stream<double> get onConfidenceChanged => _confidenceController.stream;

  /// Stream that emits status updates (idle, listening, stopped, etc.)
  Stream<String> get onStatusChanged => _statusController.stream;

  /// Whether the service is currently listening for speech
  bool get isListening => _isListening;

  /// Current transcription text
  String get currentTranscription => _currentTranscription;

  /// Last confidence score received
  double get lastConfidence => _lastConfidence;

  /// Current status of the service
  String get status => _status;

  /// Start listening for speech and transcribing
  ///
  /// [localeId] is the locale for speech recognition (e.g., 'en_US').
  /// If null, the device's default locale is used.
  ///
  /// [partialResults] determines whether to emit partial results during speech.
  ///
  /// Returns true if listening started successfully, false otherwise.
  Future<bool> startListening({String? localeId, bool partialResults = true}) async {
    await init();

    // Check if speech recognition is available
    if (!_speechToText.isAvailable) {
      return false;
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          // Update transcription and confidence
          if (result.recognizedWords.isNotEmpty) {
            _currentTranscription = result.recognizedWords;
            _transcriptionController.add(_currentTranscription);
          }

          // Update confidence if available
          if (result.finalResult) {
            final confidence = result.confidence;
            if (confidence != null) {
              _lastConfidence = confidence;
              _confidenceController.add(_lastConfidence);
            }
          }
        },
        listenFor: const Duration(minutes: 30), // Max listen duration
        pauseFor: const Duration(seconds: 10), // Pause duration
        localeId: localeId,
        partialResults: partialResults,
        onSoundLevelChange: (level) {
          // Sound level change (could be used for visualization)
        },
        cancelOnError: false,
        listenMode: ListenMode.confirmation,
      );

      _isListening = true;
      _status = 'listening';
      _isListeningController.add(_isListening);
      _statusController.add(_status);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Stop listening for speech
  ///
  /// Returns the final transcription text, or null if stopping failed.
  Future<String?> stopListening() async {
    if (!_isListening) return null;

    try {
      await _speechToText.stop();

      final finalTranscription = _currentTranscription;

      _isListening = false;
      _status = 'stopped';
      _isListeningController.add(_isListening);
      _statusController.add(_status);

      return finalTranscription;
    } catch (e) {
      return null;
    }
  }

  /// Cancel listening without returning results
  ///
  /// Returns true if canceled successfully, false otherwise.
  Future<bool> cancelListening() async {
    if (!_isListening) return false;

    try {
      await _speechToText.cancel();

      _isListening = false;
      _status = 'idle';
      _currentTranscription = '';
      _lastConfidence = 0.0;
      _isListeningController.add(_isListening);
      _statusController.add(_status);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get available locales for speech recognition
  ///
  /// Returns a list of locale names (e.g., 'en_US', 'es_ES').
  Future<List<dynamic>> getAvailableLocales() async {
    await init();
    return await _speechToText.locales();
  }

  /// Clear current transcription state
  void clearTranscription() {
    _currentTranscription = '';
    _lastConfidence = 0.0;
    _transcriptionController.add(_currentTranscription);
    _confidenceController.add(_lastConfidence);
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await _speechToText.cancel();
    await _isListeningController.close();
    await _transcriptionController.close();
    await _confidenceController.close();
    await _statusController.close();
  }
}
