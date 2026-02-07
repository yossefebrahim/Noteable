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

  @override
  void initState() {
    super.initState();
    final NotesViewModel vm = context.read<NotesViewModel>();
    _results = vm.notes;
  }

  @override
  Widget build(BuildContext context) {
    final NotesViewModel vm = context.read<NotesViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Search Notes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by title or content'),
              onChanged: (String value) async {
                _results = await vm.search(value);
                if (mounted) setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (_, int index) {
                  final NoteEntity note = _results[index];
                  return Card(
                    child: ListTile(
                      title: Text(note.title.isEmpty ? 'Untitled' : note.title),
                      subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
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
