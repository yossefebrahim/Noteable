import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/audio_attachment.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/audio_recorder_provider.dart';
import '../../providers/note_detail_view_model.dart';
import '../../providers/notes_view_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/audio_player_widget.dart';
import '../../widgets/audio_recorder_widget.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key, this.noteId});

  final String? noteId;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final NoteEditorViewModel vm = context.read<NoteEditorViewModel>();
      await vm.init(noteId: widget.noteId);
      final note = vm.note;
      if (!mounted || note == null) return;
      _titleController.text = note.title;
      _contentController.text = note.content;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = context.select<NoteEditorViewModel, bool>((NoteEditorViewModel vm) => vm.hasNote);
    final bool isPinned = context.select<NoteEditorViewModel, bool>((NoteEditorViewModel vm) => vm.note?.isPinned ?? false);
    final bool isSaving = context.select<NoteEditorViewModel, bool>((NoteEditorViewModel vm) => vm.isSaving);
    final audioAttachments = context.select<NoteEditorViewModel, List>((NoteEditorViewModel vm) => vm.audioAttachments);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Note Details' : 'New Note'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              final NoteEditorViewModel vm = context.read<NoteEditorViewModel>();
              final note = vm.note;
              if (note == null) return;
              vm.updateDraft(isPinned: !note.isPinned);
            },
            icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: AppButton(
              label: 'Save',
              isLoading: isSaving,
              onPressed: () async {
                final NoteEditorViewModel vm = context.read<NoteEditorViewModel>();
                vm.updateDraft(title: _titleController.text, content: _contentController.text);
                await vm.saveNow();
                if (!context.mounted) return;
                final notesVm = context.read<NotesViewModel>();
                await notesVm.refreshNotes();
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            AppTextField(
              controller: _titleController,
              hintText: 'Note title',
              onChanged: (String value) => context.read<NoteEditorViewModel>().updateDraft(title: value),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _contentController,
              hintText: 'Start writing...',
              maxLines: null,
              minLines: 10,
              onChanged: (String value) => context.read<NoteEditorViewModel>().updateDraft(content: value),
            ),
            const SizedBox(height: 16),
            // Audio section
            _buildAudioSection(context, audioAttachments),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSection(BuildContext context, List<AudioAttachment> audioAttachments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing audio attachments
        if (audioAttachments.isNotEmpty) ...[
          Text(
            'Audio Attachments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...List<Widget>.generate(
            audioAttachments.length,
            (int index) {
              final attachment = audioAttachments[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AudioPlayerTile(
                  attachment: attachment,
                  onDelete: () => _deleteAudioAttachment(attachment.id),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
        // Audio recorder widget
        Text(
          'Record Audio',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<AudioRecorderProvider>(
          builder: (BuildContext context, AudioRecorderProvider recorder, Widget? child) {
            return AudioRecorderWidget(provider: recorder);
          },
        ),
      ],
    );
  }

  void _deleteAudioAttachment(String attachmentId) {
    context.read<NoteEditorViewModel>().removeAudioAttachment(attachmentId);
  }
}

class _AudioPlayerTile extends StatefulWidget {
  const _AudioPlayerTile({
    required this.attachment,
    this.onDelete,
  });

  final AudioAttachment attachment;
  final VoidCallback? onDelete;

  @override
  State<_AudioPlayerTile> createState() => _AudioPlayerTileState();
}

class _AudioPlayerTileState extends State<_AudioPlayerTile> {
  late final AudioPlayerProvider _playerProvider;

  @override
  void initState() {
    super.initState();
    _playerProvider = context.read<AudioPlayerProvider>();
    // Load audio when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playerProvider.loadAudio(widget.attachment.path);
    });
  }

  @override
  void didUpdateWidget(_AudioPlayerTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attachment.path != widget.attachment.path) {
      _playerProvider.loadAudio(widget.attachment.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AudioPlayerProvider>.value(
      value: _playerProvider,
      child: AudioPlayerWidget(
        provider: _playerProvider,
        waveformAmplitudes: null, // TODO: Add waveform data when available
        onDelete: widget.onDelete,
      ),
    );
  }
}
