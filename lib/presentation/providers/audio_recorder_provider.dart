import 'dart:async';

import 'package:flutter/foundation.dart';

class AudioRecorderProvider extends ChangeNotifier {
  AudioRecorderProvider();

  bool _isRecording = false;
  Duration _duration = Duration.zero;
  double _amplitude = 0.0;
  Timer? _recordingTimer;
  Timer? _amplitudeTimer;

  bool get isRecording => _isRecording;
  Duration get duration => _duration;
  double get amplitude => _amplitude;

  void startRecording() {
    if (_isRecording) return;
    _isRecording = true;
    _duration = Duration.zero;
    _amplitude = 0.0;
    notifyListeners();

    _startRecordingTimer();
    _startAmplitudeTimer();
  }

  void stopRecording() {
    if (!_isRecording) return;
    _isRecording = false;
    notifyListeners();

    _recordingTimer?.cancel();
    _amplitudeTimer?.cancel();
    _recordingTimer = null;
    _amplitudeTimer = null;
  }

  void reset() {
    _isRecording = false;
    _duration = Duration.zero;
    _amplitude = 0.0;
    _recordingTimer?.cancel();
    _amplitudeTimer?.cancel();
    _recordingTimer = null;
    _amplitudeTimer = null;
    notifyListeners();
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _duration = _duration + const Duration(seconds: 1);
        notifyListeners();
      },
    );
  }

  void _startAmplitudeTimer() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        // Amplitude will be updated by the actual recorder implementation
        // This is a placeholder that simulates amplitude changes
        _amplitude = _generateSimulatedAmplitude();
        notifyListeners();
      },
    );
  }

  double _generateSimulatedAmplitude() {
    // TODO: Replace with actual amplitude from audio recorder
    // This is a placeholder for demonstration
    return 0.3 + (_duration.inSeconds % 10) / 10.0;
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _amplitudeTimer?.cancel();
    super.dispose();
  }
}
