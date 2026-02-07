import 'dart:async';

import 'package:record/record.dart';

/// Service for recording audio using the 'record' package.
///
/// Provides methods for starting, pausing, resuming, stopping, and canceling
/// audio recordings. Exposes streams for recording state and amplitude changes.
class AudioRecorderService {
  AudioRecorderService();

  final AudioRecorder _recorder = AudioRecorder();
  bool _isInitialized = false;

  // Stream controllers for state and amplitude
  final StreamController<bool> _isRecordingController =
      StreamController<bool>.broadcast();
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();

  // Current recording state
  bool _isRecording = false;
  bool _isPaused = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0; // in milliseconds

  /// Initialize the recorder service
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Listen to recorder state changes
    _recorder.onStateChanged().listen((state) {
      _isRecording = state == RecordState.record;
      _isPaused = state == RecordState.pause;
      _isRecordingController.add(_isRecording);

      // Stop timer when not recording
      if (!_isRecording) {
        _recordingTimer?.cancel();
      }
    });
  }

  /// Stream that emits true when recording, false when not
  Stream<bool> get onRecordingStateChanged => _isRecordingController.stream;

  /// Stream that emits amplitude values for visualization
  /// Values range from 0 to 1 (normalized)
  Stream<double> get onAmplitudeChanged => _amplitudeController.stream;

  /// Whether the recorder is currently recording
  bool get isRecording => _isRecording;

  /// Whether the recorder is currently paused
  bool get isPaused => _isPaused;

  /// Current recording duration in milliseconds
  int get recordingDuration => _recordingDuration;

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    await init();
    return await _recorder.hasPermission();
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    await init();
    return await _recorder.hasPermission();
  }

  /// Start recording audio
  ///
  /// [path] is the output file path. If null, a temporary path is used.
  /// [format] is the audio format (e.g., 'm4a', 'wav', 'mp3'). Defaults to 'm4a'.
  ///
  /// Returns true if recording started successfully, false otherwise.
  Future<bool> startRecording({String? path, String format = 'm4a'}) async {
    await init();

    // Check permission first
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      return false;
    }

    try {
      // Start recording
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacM4a, // Default to M4A format
          bitRate: 128000, // 128 kbps
          sampleRate: 44100, // 44.1 kHz
        ),
        path: path,
      );

      // Start amplitude monitoring
      _startAmplitudeMonitoring();

      // Start duration timer
      _recordingDuration = 0;
      _recordingTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => _recordingDuration += 100,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Pause the current recording
  ///
  /// Returns true if paused successfully, false otherwise.
  Future<bool> pauseRecording() async {
    if (!_isRecording || _isPaused) return false;

    try {
      await _recorder.pause();
      _recordingTimer?.cancel();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Resume a paused recording
  ///
  /// Returns true if resumed successfully, false otherwise.
  Future<bool> resumeRecording() async {
    if (!_isPaused) return false;

    try {
      await _recorder.resume();

      // Restart duration timer
      _recordingTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => _recordingDuration += 100,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Stop the current recording
  ///
  /// Returns a [RecordingInfo] object containing the recording path,
  /// duration, and format, or null if stopping failed.
  Future<RecordingInfo?> stopRecording() async {
    if (!_isRecording && !_isPaused) return null;

    try {
      _recordingTimer?.cancel();

      final recordInfo = await _recorder.stop();

      if (recordInfo != null) {
        return RecordingInfo(
          path: recordInfo.path,
          duration: _recordingDuration,
          format: 'm4a', // Default format
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cancel the current recording without saving
  ///
  /// Returns true if canceled successfully, false otherwise.
  Future<bool> cancelRecording() async {
    if (!_isRecording && !_isPaused) return false;

    try {
      _recordingTimer?.cancel();
      await _recorder.stop();
      _recordingDuration = 0;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Start monitoring amplitude for visualization
  void _startAmplitudeMonitoring() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (!_isRecording) {
        timer.cancel();
        return;
      }

      try {
        final amplitude = await _recorder.getAmplitude();
        // Normalize amplitude to 0-1 range (typical range is -160 to 0 dB)
        final normalized = (amplitude.current + 160) / 160;
        _amplitudeController.add(normalized.clamp(0.0, 1.0));
      } catch (e) {
        // Continue monitoring even if one read fails
      }
    });
  }

  /// Dispose of resources
  Future<void> dispose() async {
    _recordingTimer?.cancel();
    await _recorder.dispose();
    await _isRecordingController.close();
    await _amplitudeController.close();
  }
}

/// Information about a completed recording
class RecordingInfo {
  const RecordingInfo({
    required this.path,
    required this.duration,
    required this.format,
  });

  /// Path to the recorded audio file
  final String path;

  /// Duration in milliseconds
  final int duration;

  /// Audio format (e.g., 'm4a', 'wav', 'mp3')
  final String format;
}
