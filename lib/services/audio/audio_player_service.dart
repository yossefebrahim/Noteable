import 'dart:async';

import 'package:just_audio/just_audio.dart';

/// Service for playing audio using the 'just_audio' package.
///
/// Provides methods for loading, playing, pausing, stopping, and seeking
/// audio files. Exposes streams for playback state and position changes.
class AudioPlayerService {
  AudioPlayerService();

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  // Stream controllers for state and position
  final StreamController<bool> _isPlayingController =
      StreamController<bool>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration?> _durationController =
      StreamController<Duration?>.broadcast();
  final StreamController<String> _playerStateController =
      StreamController<String>.broadcast();

  // Current playback state
  bool _isPlaying = false;
  String _playerState = 'idle';

  /// Initialize the player service
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Listen to player state changes
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _playerState = state.processingState.name;

      _isPlayingController.add(_isPlaying);
      _playerStateController.add(_playerState);

      // Reset state when playback completes
      if (state.processingState == ProcessingState.completed) {
        _player.stop();
      }
    });

    // Listen to position changes
    _player.positionStream.listen((position) {
      _positionController.add(position);
    });

    // Listen to duration changes
    _player.durationStream.listen((duration) {
      _durationController.add(duration);
    });
  }

  /// Stream that emits true when playing, false when not
  Stream<bool> get onPlayingStateChanged => _isPlayingController.stream;

  /// Stream that emits position updates during playback
  Stream<Duration> get onPositionChanged => _positionController.stream;

  /// Stream that emits duration when audio is loaded
  Stream<Duration?> get onDurationChanged => _durationController.stream;

  /// Stream that emits player state changes (idle, loading, buffered, etc.)
  Stream<String> get onPlayerStateChanged => _playerStateController.stream;

  /// Whether the player is currently playing
  bool get isPlaying => _isPlaying;

  /// Current player state (idle, loading, buffering, playing, paused, completed)
  String get playerState => _playerState;

  /// Current playback position
  Duration get position => _player.position;

  /// Total duration of the loaded audio (null if not loaded)
  Duration? get duration => _player.duration;

  /// Load an audio file for playback
  ///
  /// [path] is the file path or URL to the audio file.
  ///
  /// Returns true if loaded successfully, false otherwise.
  Future<bool> loadAudio(String path) async {
    await init();

    try {
      // Stop any current playback
      await _player.stop();

      // Load the audio file
      if (path.startsWith('http://') || path.startsWith('https://')) {
        await _player.setUrl(path);
      } else {
        await _player.setFilePath(path);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Start or resume playback
  ///
  /// Returns true if playback started successfully, false otherwise.
  Future<bool> play() async {
    await init();

    try {
      await _player.play();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Pause playback
  ///
  /// Returns true if paused successfully, false otherwise.
  Future<bool> pause() async {
    if (!_isPlaying) return false;

    try {
      await _player.pause();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Stop playback and reset position to beginning
  ///
  /// Returns true if stopped successfully, false otherwise.
  Future<bool> stop() async {
    try {
      await _player.stop();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Seek to a specific position in the audio
  ///
  /// [position] is the position to seek to.
  ///
  /// Returns true if seeked successfully, false otherwise.
  Future<bool> seek(Duration position) async {
    try {
      await _player.seek(position);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Set the playback volume
  ///
  /// [volume] is the volume level from 0.0 (silent) to 1.0 (full volume).
  ///
  /// Returns true if volume set successfully, false otherwise.
  Future<bool> setVolume(double volume) async {
    if (volume < 0.0 || volume > 1.0) return false;

    try {
      await _player.setVolume(volume);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Set the playback speed
  ///
  /// [rate] is the playback rate (e.g., 1.0 is normal, 0.5 is half speed, 2.0 is double speed).
  ///
  /// Returns true if rate set successfully, false otherwise.
  Future<bool> setPlaybackRate(double rate) async {
    if (rate <= 0.0) return false;

    try {
      await _player.setSpeed(rate);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Seek to a specific position in the audio by percentage
  ///
  /// [percent] is the position as a percentage (0.0 to 1.0).
  ///
  /// Returns true if seeked successfully, false otherwise.
  Future<bool> seekByPercent(double percent) async {
    if (percent < 0.0 || percent > 1.0) return false;
    if (_player.duration == null) return false;

    final position = Duration(
      milliseconds:
          (_player.duration!.inMilliseconds * percent).floor(),
    );

    return seek(position);
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await _player.dispose();
    await _isPlayingController.close();
    await _positionController.close();
    await _durationController.close();
    await _playerStateController.close();
  }
}
