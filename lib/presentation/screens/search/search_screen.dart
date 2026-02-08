import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noteable_app/domain/entities/note_entity.dart';
import 'package:noteable_app/domain/entities/transcription.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/domain/repositories/transcription_repository.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<NoteEntity> _results = <NoteEntity>[];
  bool _isSearching = false;
  final Map<String, List<Transcription>> _transcriptionsCache = <String, List<Transcription>>{};

  @override
  void initState() {
    super.initState();
    final NotesViewModel vm = context.read<NotesViewModel>();
    _results = vm.notes;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      final NotesViewModel vm = context.read<NotesViewModel>();
      setState(() {
        _results = vm.notes;
        _isSearching = false;
        _transcriptionsCache.clear();
      });
      return;
    }

    setState(() => _isSearching = true);
    final NotesViewModel vm = context.read<NotesViewModel>();
    _results = await vm.search(query);

    // Load transcriptions for notes with audio attachments
    await _loadTranscriptionsForResults(query);

    if (mounted) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _loadTranscriptionsForResults(String query) async {
    final transcriptionRepo = context.read<TranscriptionRepository>();
    final transcriptionsMap = <String, List<Transcription>>{};

    for (final note in _results) {
      if (note.audioAttachments.isEmpty) continue;

      final transcriptions = <Transcription>[];
      for (final attachment in note.audioAttachments) {
        final attachmentTranscriptions = await transcriptionRepo
            .getTranscriptionsByAudioAttachmentId(attachment.id);

        // Filter to only include transcriptions that match the query
        final matchingTranscriptions = attachmentTranscriptions
            .where((t) => t.text.toLowerCase().contains(query.toLowerCase()))
            .toList();

        transcriptions.addAll(matchingTranscriptions);
      }

      if (transcriptions.isNotEmpty) {
        transcriptionsMap[note.id] = transcriptions;
      }
    }

    if (mounted) {
      setState(() {
        _transcriptionsCache.clear();
        _transcriptionsCache.addAll(transcriptionsMap);
      });
    }
  }

  String _highlightMatch(String text, String query) {
    if (query.isEmpty) return text;

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) return text;

    // Extract context around the match (up to 50 chars before and after)
    final start = index > 50 ? index - 50 : 0;
    final end = index + query.length + 50 < text.length
        ? index + query.length + 50
        : text.length;

    String snippet = text.substring(start, end);
    if (start > 0) snippet = '...$snippet';
    if (end < text.length) snippet = '$snippet...';

    return snippet;
  }

  @override
  Widget build(BuildContext context) {
    final NotesViewModel vm = context.read<NotesViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Notes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by title, content, or transcription',
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              onChanged: _performSearch,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.trim().isEmpty
                                ? 'Start typing to search notes'
                                : 'No notes found',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (_, int index) {
                            final NoteEntity note = _results[index];
                            final hasAudio = note.audioAttachments.isNotEmpty;
                            final transcriptions = _transcriptionsCache[note.id] ?? <Transcription>[];
                            final hasMatchingTranscriptions = transcriptions.isNotEmpty;
                            final query = _searchController.text.trim();

                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                title: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        note.title.isEmpty ? 'Untitled' : note.title,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ),
                                    if (hasAudio) ...<Widget>[
                                      Icon(
                                        Icons.mic,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SizedBox(height: 4),
                                    Text(
                                      note.content.isEmpty ? 'No content' : note.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    if (hasMatchingTranscriptions && query.isNotEmpty) ...<Widget>[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.transcribe,
                                                  size: 12,
                                                  color: theme.colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Matching transcription',
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            ...transcriptions.take(2).map(
                                              (transcription) => Padding(
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: Text(
                                                  _highlightMatch(transcription.text, query),
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (transcriptions.length > 2)
                                              Text(
                                                '+${transcriptions.length - 2} more match${transcriptions.length - 2 == 1 ? '' : 'es'}',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ] else if (hasAudio) ...<Widget>[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Contains audio/transcription',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                onTap: () => context.push('/note-detail', extra: note.id),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
