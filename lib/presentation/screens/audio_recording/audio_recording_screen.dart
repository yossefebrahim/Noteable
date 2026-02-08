import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/audio_player_provider.dart';
import '../../providers/audio_recorder_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/audio_player_widget.dart';
import '../../widgets/audio_recorder_widget.dart';

class AudioRecordingScreen extends StatefulWidget {
  const AudioRecordingScreen({super.key, this.noteId});

  final String? noteId;

  @override
  State<AudioRecordingScreen> createState() => _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  String? _recordedAudioPath;

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRecording = context.select<AudioRecorderProvider, bool>(
      (AudioRecorderProvider vm) => vm.isRecording,
    );
    final bool hasRecordedAudio = _recordedAudioPath != null;
    final bool canSave = hasRecordedAudio && !isRecording;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recording'),
        actions: <Widget>[
          if (canSave)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: AppButton(
                label: 'Save',
                isLoading: false,
                onPressed: () async {
                  // TODO: Implement saving audio to note
                  // This will be completed in a future subtask
                  // when we wire up the actual audio recording service
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Audio saved to note'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Navigate back after saving
                  Navigator.pop(context);
                },
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Instructions
            if (!hasRecordedAudio && !isRecording) ...[
              _buildInstructions(context),
              const SizedBox(height: 24),
            ],
            // Audio recorder widget
            if (!hasRecordedAudio)
              AudioRecorderWidget(
                provider: context.read<AudioRecorderProvider>(),
              )
            else
              AudioPlayerWidget(
                provider: context.read<AudioPlayerProvider>(),
              ),
            const SizedBox(height: 24),
            // Status message
            if (isRecording)
              Center(
                child: Text(
                  'Recording in progress...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              )
            else if (hasRecordedAudio)
              Center(
                child: Text(
                  'Recording complete! Review your audio above.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'How to record',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '1. Tap the microphone button to start recording\n'
            '2. Speak clearly into your device\n'
            '3. Tap the stop button when finished\n'
            '4. Review your recording using the player\n'
            '5. Tap "Save" to attach to your note',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
