import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ExportPopupMenu extends StatelessWidget {
  final VoidCallback onExportCsv;
  final VoidCallback onExportPdf;

  const ExportPopupMenu({
    super.key,
    required this.onExportCsv,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.share),
      onSelected: (value) {
        if (value == 'csv') {
          onExportCsv();
        } else if (value == 'pdf') onExportPdf();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.table_chart, size: 20),
              Gap(12),
              Text('Export as CSV'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 20),
              Gap(12),
              Text('Export as PDF'),
            ],
          ),
        ),
      ],
    );
  }
}
