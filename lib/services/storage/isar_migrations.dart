import 'package:isar/isar.dart';

/// Place app-specific migration scripts here when bumping schema versions.
///
/// Example:
/// if (from < 2) { ... }
Future<void> runIsarMigrations({
  required Isar isar,
  required int from,
  required int to,
}) async {
  if (from >= to) return;

  // v1 baseline - no-op.

  // v2 - Added AudioAttachmentModel and TranscriptionModel collections
  // This is a non-breaking change (new collections only), no manual migration needed.
  if (from < 2) {
    // Isar automatically handles new collections
  }
}
