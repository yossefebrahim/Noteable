import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:noteable_app/services/audio/audio_player_service.dart';

class AudioPlayerProvider extends ChangeNotifier {
  AudioPlayerProvider({
    required AudioPlayerService audioPlayerService,
  }) : _audioPlayerService = audioPlayerService {
    _init();
  }

  final AudioPlayerService _audioPlayerService;

  // Subscription references
  StreamSubscription<bool>? _isPlayingSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<String>? _playerStateSubscription;

  // Playback state
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration? _duration;
  String _playerState = 'idle';
  String? _currentAudioPath;

  // Getters
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration? get duration => _duration;
  String get playerState => _playerState;
  String? get currentAudioPath => _currentAudioPath;
  bool get hasAudio => _currentAudioPath != null;

  void _init() {
    // Subscribe to isPlaying changes
    _isPlayingSubscription =
        _audioPlayerService.onPlayingStateChanged.listen((isPlaying) {
      _isPlaying = isPlaying;
      notifyListeners();
    });

    // Subscribe to position changes
    _positionSubscription =
        _audioPlayerService.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Subscribe to duration changes
    _durationSubscription =
        _audioPlayerService.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    // Subscribe to player state changes
    _playerStateSubscription =
        _audioPlayerService.onPlayerStateChanged.listen((state) {
      _playerState = state;
      notifyListeners();
    });
  }

  /// Load an audio file for playback
  Future<bool> loadAudio(String path) async {
    final success = await _audioPlayerService.loadAudio(path);
    if (success) {
      _currentAudioPath = path;
      notifyListeners();
    }
    return success;
  }

  /// Start or resume playback
  Future<bool> play() async {
    return await _audioPlayerService.play();
  }

  /// Pause playback
  Future<bool> pause() async {
    return await _audioPlayerService.pause();
  }

  /// Stop playback and reset position to beginning
  Future<bool> stop() async {
    final success = await _audioPlayerService.stop();
    if (success) {
      _position = Duration.zero;
      notifyListeners();
    }
    return success;
  }

  /// Seek to a specific position in the audio
  Future<bool> seek(Duration position) async {
    return await _audioPlayerService.seek(position);
  }

  /// Seek to a specific position in the audio by percentage
  Future<bool> seekByPercent(double percent) async {
    return await _audioPlayerService.seekByPercent(percent);
  }

  /// Set the playback volume
  ///
  /// [volume] is the volume level from 0.0 (silent) to 1.0 (full volume).
  Future<bool> setVolume(double volume) async {
    return await _audioPlayerService.setVolume(volume);
  }

  /// Set the playback speed
  ///
  /// [rate] is the playback rate (e.g., 1.0 is normal, 0.5 is half speed, 2.0 is double speed).
  Future<bool> setPlaybackRate(double rate) async {
    return await _audioPlayerService.setPlaybackRate(rate);
  }

  /// Toggle play/pause state
  Future<bool> togglePlayPause() async {
    if (_isPlaying) {
      return await pause();
    } else {
      return await play();
    }
  }

  /// Reset the player state
  void reset() {
    _currentAudioPath = null;
    _position = Duration.zero;
    _duration = null;
    _isPlaying = false;
    _playerState = 'idle';
    notifyListeners();
  }

  @override
  void dispose() {
    _isPlayingSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }
}
