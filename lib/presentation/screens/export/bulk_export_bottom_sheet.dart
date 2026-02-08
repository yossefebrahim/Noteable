import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/export_view_model.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/export_service.dart';

/// Callback type for bulk export format selection
typedef BulkExportCallback = void Function(ExportFormat format);

/// Bottom sheet for bulk export options (export all notes as ZIP in selected format)
class BulkExportBottomSheet extends StatelessWidget {
  const BulkExportBottomSheet({
    super.key,
    this.onExportFormatSelected,
  });

  final BulkExportCallback? onExportFormatSelected;

  /// Show the bulk export bottom sheet
  static Future<void> show(
    BuildContext context, {
    BulkExportCallback? onExportFormatSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return BulkExportBottomSheet(
          onExportFormatSelected: onExportFormatSelected,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isExporting = context.select<ExportViewModel, bool>(
      (ExportViewModel vm) => vm.isExporting,
    );

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
                'Export All Notes',
                style: AppTextStyles.h3,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'All notes will be exported as a ZIP archive',
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Export format options
            _BulkExportOptionTile(
              icon: Icons.description,
              title: 'Markdown',
              description: 'Export all notes as Markdown (.md) in a ZIP',
              format: ExportFormat.markdown,
              onTap: onExportFormatSelected,
              isEnabled: !isExporting,
            ),
            _BulkExportOptionTile(
              icon: Icons.text_snippet,
              title: 'Plain Text',
              description: 'Export all notes as Plain Text (.txt) in a ZIP',
              format: ExportFormat.txt,
              onTap: onExportFormatSelected,
              isEnabled: !isExporting,
            ),
            _BulkExportOptionTile(
              icon: Icons.code,
              title: 'JSON',
              description: 'Export all notes as JSON (.json) in a ZIP',
              format: ExportFormat.json,
              onTap: onExportFormatSelected,
              isEnabled: !isExporting,
            ),

            if (isExporting) ...<Widget>[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Exporting notes...',
                  style: AppTextStyles.caption,
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Individual bulk export format option tile
class _BulkExportOptionTile extends StatelessWidget {
  const _BulkExportOptionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.format,
    this.onTap,
    required this.isEnabled,
  });

  final IconData icon;
  final String title;
  final String description;
  final ExportFormat format;
  final BulkExportCallback? onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled
          ? () {
              onTap?.call(format);
              Navigator.pop(context);
            }
          : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
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
      ),
    );
  }
}
