import 'package:flutter/material.dart';

import '../providers/folder_provider.dart';

class FolderCard extends StatelessWidget {
  const FolderCard({super.key, required this.folder, this.onTap});

  final FolderItem folder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(Icons.folder, size: 48, color: _parseColor(folder.colorHex)),
        title: Text(
          folder.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        subtitle: Text('${folder.noteCount} notes', style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  Color _parseColor(String value) {
    final hex = value.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
