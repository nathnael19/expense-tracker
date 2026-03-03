import 'package:flutter/material.dart';
import '../../blocs/stats_cubit.dart';

class ViewModeSelector extends StatelessWidget {
  final ReportViewMode selectedMode;
  final ValueChanged<ReportViewMode> onSelectionChanged;

  const ViewModeSelector({
    super.key,
    required this.selectedMode,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton<ReportViewMode>(
        segments: const [
          ButtonSegment(
            value: ReportViewMode.weekly,
            label: Text('Week'),
          ),
          ButtonSegment(
            value: ReportViewMode.monthly,
            label: Text('Month'),
          ),
          ButtonSegment(
            value: ReportViewMode.yearly,
            label: Text('Year'),
          ),
        ],
        selected: {selectedMode},
        onSelectionChanged: (value) {
          onSelectionChanged(value.first);
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedBackgroundColor:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          selectedForegroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
