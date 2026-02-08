import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noteable_app/domain/entities/note_entity.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
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
      });
      return;
    }

    setState(() => _isSearching = true);
    final NotesViewModel vm = context.read<NotesViewModel>();
    _results = await vm.search(query);
    if (mounted) {
      setState(() => _isSearching = false);
    }
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
                                    if (hasAudio) ...<Widget>[
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
