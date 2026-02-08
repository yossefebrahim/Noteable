import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/export_view_model.dart';
import '../../../data/services/export_service.dart';
import '../../../core/theme/app_text_styles.dart';

/// Callback type for export option selection
typedef ExportOptionCallback = void Function(ExportFormat format);

/// Callback type for share option selection
typedef ShareOptionCallback = void Function();

/// Bottom sheet for selecting export format or sharing options
class ExportOptionsBottomSheet extends StatelessWidget {
  const ExportOptionsBottomSheet({
    super.key,
    this.onExportFormatSelected,
    this.onShareSelected,
  });

  final ExportOptionCallback? onExportFormatSelected;
  final ShareOptionCallback? onShareSelected;

  /// Show the export options bottom sheet
  static Future<void> show(
    BuildContext context, {
    ExportOptionCallback? onExportFormatSelected,
    ShareOptionCallback? onShareSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return ExportOptionsBottomSheet(
          onExportFormatSelected: onExportFormatSelected,
          onShareSelected: onShareSelected,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Title
            Center(
              child: Text(
                'Export Note',
                style: AppTextStyles.h3,
              ),
            ),
            const SizedBox(height: 24),

            // Export format options
            _ExportOptionTile(
              icon: Icons.description,
              title: 'Markdown',
              description: 'Export as .md file',
              format: ExportFormat.markdown,
              onTap: onExportFormatSelected,
            ),
            _ExportOptionTile(
              icon: Icons.text_snippet,
              title: 'Plain Text',
              description: 'Export as .txt file',
              format: ExportFormat.txt,
              onTap: onExportFormatSelected,
            ),
            _ExportOptionTile(
              icon: Icons.picture_as_pdf,
              title: 'PDF',
              description: 'Export as .pdf file',
              format: ExportFormat.pdf,
              onTap: onExportFormatSelected,
            ),
            _ExportOptionTile(
              icon: Icons.code,
              title: 'JSON',
              description: 'Export as .json file',
              format: ExportFormat.json,
              onTap: onExportFormatSelected,
            ),

            const SizedBox(height: 8),

            // Divider
            const Divider(height: 32),

            // Share option
            _ShareOptionTile(
              icon: Icons.share,
              title: 'Share',
              description: 'Share note with other apps',
              onTap: onShareSelected,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Individual export format option tile
class _ExportOptionTile extends StatelessWidget {
  const _ExportOptionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.format,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final ExportFormat format;
  final ExportOptionCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap?.call(format);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Share option tile
class _ShareOptionTile extends StatelessWidget {
  const _ShareOptionTile({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final ShareOptionCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap?.call();
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
