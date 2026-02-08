import 'dart:io';

import 'package:permission_handler/permission_handler.dart' as ph;

/// Service for handling runtime permissions using permission_handler.
///
/// Provides methods for checking and requesting permissions required
/// for audio recording and storage features.
class PermissionService {
  PermissionService();

  bool _isInitialized = false;

  /// Initialize the permission service
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  /// Check if microphone permission is granted
  ///
  /// Returns true if permission is granted, false otherwise.
  Future<bool> hasMicrophonePermission() async {
    await init();
    return await ph.Permission.microphone.status.isGranted;
  }

  /// Request microphone permission
  ///
  /// Returns true if permission is granted, false otherwise.
  /// If permission is permanently denied, returns false and user
  /// should be directed to app settings.
  Future<bool> requestMicrophonePermission() async {
    await init();

    final status = await ph.Permission.microphone.request();
    return status.isGranted;
  }

  /// Check if storage permission is granted (Android only)
  ///
  /// Returns true if permission is granted, false otherwise.
  /// On iOS, this always returns true as storage permission is not required.
  Future<bool> hasStoragePermission() async {
    await init();

    // On Android, check for storage permission
    if (_isAndroid()) {
      return await ph.Permission.storage.status.isGranted;
    }

    // Storage permission not required on iOS
    return true;
  }

  /// Request storage permission (Android only)
  ///
  /// Returns true if permission is granted, false otherwise.
  /// On iOS, this returns true immediately as storage permission is not required.
  Future<bool> requestStoragePermission() async {
    await init();

    // On Android, request storage permission
    if (_isAndroid()) {
      final status = await ph.Permission.storage.request();
      return status.isGranted;
    }

    // Storage permission not required on iOS
    return true;
  }

  /// Check if microphone permission is permanently denied
  ///
  /// Returns true if permission was permanently denied by the user,
  /// meaning the user should be directed to app settings to enable it.
  Future<bool> isMicrophonePermissionPermanentlyDenied() async {
    await init();
    return await ph.Permission.microphone.isPermanentlyDenied;
  }

  /// Check if storage permission is permanently denied (Android only)
  ///
  /// Returns true if permission was permanently denied by the user,
  /// meaning the user should be directed to app settings to enable it.
  /// On iOS, this returns false.
  Future<bool> isStoragePermissionPermanentlyDenied() async {
    await init();

    if (_isAndroid()) {
      return await ph.Permission.storage.isPermanentlyDenied;
    }

    return false;
  }

  /// Open app settings so user can grant permissions manually
  ///
  /// Returns true if settings were opened successfully, false otherwise.
  Future<bool> openSettings() async {
    await init();
    return await ph.openAppSettings();
  }

  /// Request all permissions required for audio recording
  ///
  /// Returns a map of permission names to their granted status.
  /// All permissions must be granted for successful audio recording.
  Future<Map<String, bool>> requestAudioPermissions() async {
    await init();

    final results = <String, bool>{};

    // Request microphone permission
    final micStatus = await ph.Permission.microphone.request();
    results['microphone'] = micStatus.isGranted;

    // Request storage permission on Android
    if (_isAndroid()) {
      final storageStatus = await ph.Permission.storage.request();
      results['storage'] = storageStatus.isGranted;
    } else {
      results['storage'] = true;
    }

    return results;
  }

  /// Check all permissions required for audio recording
  ///
  /// Returns a map of permission names to their granted status.
  Future<Map<String, bool>> checkAudioPermissions() async {
    await init();

    final results = <String, bool>{};

    // Check microphone permission
    results['microphone'] = await ph.Permission.microphone.status.isGranted;

    // Check storage permission on Android
    if (_isAndroid()) {
      results['storage'] = await ph.Permission.storage.status.isGranted;
    } else {
      results['storage'] = true;
    }

    return results;
  }

  /// Check if the app is running on Android
  bool _isAndroid() {
    return Platform.isAndroid;
  }

  /// Dispose of resources
  Future<void> dispose() async {
    // No resources to clean up for permission service
    _isInitialized = false;
  }
}
