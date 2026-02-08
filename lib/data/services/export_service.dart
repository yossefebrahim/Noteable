import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/note_model.dart';

/// Enum representing supported export formats
enum ExportFormat {
  markdown,
  txt,
  pdf,
  json,
}

/// Enum representing export types
enum ExportType {
  single,
  folder,
  all,
}

/// Result of an export operation
class ExportResult {
  final String filePath;
  final String format;
  final int itemCount;

  ExportResult({
    required this.filePath,
    required this.format,
    required this.itemCount,
  });
}

/// Internal class to hold export content (text or binary)
class _ExportContent {
  final String? text;
  final Uint8List? bytes;

  _ExportContent.text(this.text) : bytes = null;
  _ExportContent.binary(this.bytes) : text = null;

  bool get isBinary => bytes != null;
  bool get isText => text != null;
}

/// Service for exporting notes to various formats
class ExportService {
  ExportService();

  /// Export a single note to the specified format
  Future<ExportResult> exportSingleNote(
    NoteModel note,
    ExportFormat format,
  ) async {
    final content = _convertNote(note, format);
    final fileName = _generateFileName(note.title, format);
    final filePath = await _saveToFile(fileName, content, format);

    return ExportResult(
      filePath: filePath,
      format: format.name,
      itemCount: 1,
    );
  }

  /// Export multiple notes to a ZIP archive
  ///
  /// Creates a ZIP archive containing all notes in the specified format:
  /// - Each note is saved as an individual file with generated filename
  /// - Filenames are sanitized to be filesystem-safe
  /// - Duplicate filenames are numbered to avoid conflicts
  /// - Archive is named based on the export format and note count
  Future<ExportResult> exportMultipleNotes(
    List<NoteModel> notes,
    ExportFormat format,
  ) async {
    if (notes.isEmpty) {
      throw ArgumentError('Cannot export empty notes list');
    }

    final archive = Archive();
    final usedFileNames = <String>{};

    for (var i = 0; i < notes.length; i++) {
      final note = notes[i];
      final content = _convertNote(note, format);
      final baseFileName = _generateFileName(note.title, format);
      final uniqueFileName = _generateUniqueFileName(
        baseFileName,
        usedFileNames,
      );

      usedFileNames.add(uniqueFileName);

      final bytes = content.isBinary
          ? content.bytes!
          : Uint8List.fromList(content.text!.codeUnits);

      final archiveFile = ArchiveFile(uniqueFileName, bytes.length, bytes);
      archive.addFile(archiveFile);
    }

    final zipBytes = ZipEncoder().encode(archive);
    final zipFileName = _generateZipFileName(notes.length, format);
    final zipFilePath = await _saveZipFile(zipFileName, zipBytes!);

    return ExportResult(
      filePath: zipFilePath,
      format: '${format.name}_zip',
      itemCount: notes.length,
    );
  }

  /// Get note content formatted for sharing
  Future<String> getShareableContent(NoteModel note) async {
    return _convertNoteToShareableText(note);
  }

  /// Convert a note to the specified format
  _ExportContent _convertNote(NoteModel note, ExportFormat format) {
    switch (format) {
      case ExportFormat.markdown:
        return _ExportContent.text(_convertToMarkdown(note));
      case ExportFormat.txt:
        return _ExportContent.text(_convertToTxt(note));
      case ExportFormat.pdf:
        return _ExportContent.binary(_convertToPdf(note));
      case ExportFormat.json:
        return _ExportContent.text(_convertToJson(note));
    }
  }

  /// Convert note to Markdown format
  ///
  /// Creates a properly formatted Markdown document with:
  /// - Title as H1 heading (# Title)
  /// - Blank line after heading for proper spacing
  /// - Content with preserved line breaks
  /// - Handles empty title or content gracefully
  String _convertToMarkdown(NoteModel note) {
    final buffer = StringBuffer();

    if (note.title.isNotEmpty) {
      buffer.writeln('# ${note.title}');
      buffer.writeln();
    }

    if (note.content.isNotEmpty) {
      buffer.writeln(note.content);
    }

    return buffer.toString();
  }

  /// Convert note to plain text format
  ///
  /// Creates a simple plain text document with:
  /// - Title as plain text (no markdown formatting)
  /// - Blank line after title for separation
  /// - Content with preserved line breaks
  /// - Handles empty title or content gracefully
  String _convertToTxt(NoteModel note) {
    final buffer = StringBuffer();

    if (note.title.isNotEmpty) {
      buffer.writeln(note.title);
      buffer.writeln();
    }

    if (note.content.isNotEmpty) {
      buffer.writeln(note.content);
    }

    return buffer.toString();
  }

  /// Convert note to PDF format
  ///
  /// Creates a properly formatted PDF document with:
  /// - Title as large bold heading with bottom margin
  /// - Content with preserved line breaks
  /// - Proper page size and margins
  /// - Readable font (built-in Helvetica)
  /// - Handles empty title or content gracefully
  Uint8List _convertToPdf(NoteModel note) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title section
              if (note.title.isNotEmpty) ...[
                pw.Text(
                  note.title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    font: pw.Font.helvetica(),
                  ),
                ),
                pw.SizedBox(height: 24),
              ],
              // Content section
              if (note.content.isNotEmpty)
                pw.Text(
                  note.content,
                  style: pw.TextStyle(
                    fontSize: 12,
                    font: pw.Font.helvetica(),
                    lineHeight: 1.5,
                  ),
                ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Convert note to JSON format
  ///
  /// Creates a JSON document suitable for backup/migration with:
  /// - All note fields including optional ones
  /// - Proper JSON encoding using dart:convert
  /// - ISO 8601 formatted dates
  /// - Handles null values for optional fields (folderId, updatedAt)
  String _convertToJson(NoteModel note) {
    final jsonData = {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'isPinned': note.isPinned,
      'folderId': note.folderId,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt?.toIso8601String(),
    };

    return jsonEncode(jsonData);
  }

  /// Convert note to shareable text format
  String _convertNoteToShareableText(NoteModel note) {
    final buffer = StringBuffer();

    if (note.title.isNotEmpty) {
      buffer.write(note.title);
      if (note.content.isNotEmpty) {
        buffer.write('\n\n');
      }
    }

    if (note.content.isNotEmpty) {
      buffer.write(note.content);
    }

    return buffer.toString();
  }

  /// Generate a safe filename from note title
  String _generateFileName(String title, ExportFormat format) {
    final sanitizedTitle = title
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();

    final prefix = sanitizedTitle.isEmpty ? 'untitled' : sanitizedTitle;
    final extension = _getFileExtension(format);

    return '$prefix.$extension';
  }

  /// Get file extension for export format
  String _getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.markdown:
        return 'md';
      case ExportFormat.txt:
        return 'txt';
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.json:
        return 'json';
    }
  }

  /// Save content to file
  Future<String> _saveToFile(
    String fileName,
    _ExportContent content,
    ExportFormat format,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      if (content.isBinary) {
        await file.writeAsBytes(content.bytes!);
      } else {
        await file.writeAsString(content.text!);
      }

      return file.path;
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  /// Generate a unique filename to avoid conflicts in ZIP archive
  ///
  /// If the base filename already exists, appends a number suffix:
  /// - "note.md" -> "note_2.md", "note_3.md", etc.
  /// - Preserves the original file extension
  /// - Tracks used filenames in the provided set
  String _generateUniqueFileName(
    String baseFileName,
    Set<String> usedFileNames,
  ) {
    if (!usedFileNames.contains(baseFileName)) {
      return baseFileName;
    }

    // Extract name and extension
    final lastDotIndex = baseFileName.lastIndexOf('.');
    if (lastDotIndex == -1) {
      // No extension, just append number
      var counter = 2;
      while (usedFileNames.contains('${baseFileName}_$counter')) {
        counter++;
      }
      return '${baseFileName}_$counter';
    }

    final name = baseFileName.substring(0, lastDotIndex);
    final extension = baseFileName.substring(lastDotIndex);

    var counter = 2;
    while (usedFileNames.contains('${name}_$counter$extension')) {
      counter++;
    }

    return '${name}_$counter$extension';
  }

  /// Generate filename for ZIP archive
  ///
  /// Creates a descriptive filename for the ZIP archive:
  /// - Uses format name (markdown, txt, pdf, json)
  /// - Includes note count
  /// - Appends timestamp for uniqueness
  String _generateZipFileName(int noteCount, ExportFormat format) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'notes_${format.name}_${noteCount}_$timestamp.zip';
  }

  /// Save ZIP archive bytes to file
  ///
  /// Saves the ZIP archive to disk:
  /// - Uses path_provider for app directory
  /// - Writes binary ZIP data
  /// - Returns the full file path
  Future<String> _saveZipFile(String fileName, Uint8List zipBytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(zipBytes);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save ZIP file: $e');
    }
  }
}
