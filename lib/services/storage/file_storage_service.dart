import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  FileStorageService();

  static const String _audioDirectoryName = 'audio';
  Directory? _audioDirectory;

  /// Initialize the audio storage directory
  Future<void> init() async {
    if (_audioDirectory != null) return;

    final appDir = await getApplicationDocumentsDirectory();
    _audioDirectory = Directory(p.join(appDir.path, _audioDirectoryName));

    // Create directory if it doesn't exist
    if (!await _audioDirectory!.exists()) {
      await _audioDirectory!.create(recursive: true);
    }
  }

  /// Get the audio storage directory
  Future<Directory> get audioDirectory async {
    await init();
    return _audioDirectory!;
  }

  /// Save audio file data to storage and return the file path
  Future<String> saveAudioFile(List<int> bytes, String format) async {
    final dir = await audioDirectory;

    // Generate unique filename with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'audio_$timestamp.$format';
    final filePath = p.join(dir.path, filename);

    // Write bytes to file
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  /// Save audio file from a source path to storage
  /// Returns the new path in the audio storage directory
  Future<String> saveAudioFileFromPath(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('Source file does not exist', sourcePath);
    }

    // Get file extension from source
    final format = p.extension(sourcePath).replaceFirst('.', '');
    final bytes = await sourceFile.readAsBytes();

    return saveAudioFile(bytes, format);
  }

  /// Delete audio file at the given path
  Future<bool> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      // Return false if deletion fails
      return false;
    }
  }

  /// Check if an audio file exists at the given path
  Future<bool> audioFileExists(String filePath) async {
    final file = File(filePath);
    return file.exists();
  }

  /// Get the size of an audio file in bytes
  Future<int> getAudioFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return file.lengthSync();
    }
    return 0;
  }

  /// Generate a unique file path for a new audio recording
  /// (does not create the file, just returns the path)
  Future<String> generateUniqueAudioPath(String format) async {
    final dir = await audioDirectory;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'audio_$timestamp.$format';
    return p.join(dir.path, filename);
  }

  /// Get all audio files in the audio directory
  Future<List<File>> getAllAudioFiles() async {
    final dir = await audioDirectory;
    return dir.list().where((entity) => entity is File).cast<File>().toList();
  }

  /// Clear all audio files from the audio directory
  Future<void> clearAllAudioFiles() async {
    final files = await getAllAudioFiles();
    for (final file in files) {
      try {
        await file.delete();
      } catch (e) {
        // Continue deleting other files if one fails
        continue;
      }
    }
  }
}
