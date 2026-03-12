import 'package:flutter/material.dart';
import '../../../data/models/debt_model.dart';

class DebtTypeToggle extends StatelessWidget {
  final DebtType selectedType;
  final ValueChanged<DebtType> onSelectionChanged;
  final Color primaryColor;

  const DebtTypeToggle({
    super.key,
    required this.selectedType,
    required this.onSelectionChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DebtType>(
      segments: const [
        ButtonSegment(
          value: DebtType.lent,
          label: Text('I Lent'),
          icon: Icon(Icons.arrow_upward),
        ),
        ButtonSegment(
          value: DebtType.borrowed,
          label: Text('I Borrowed'),
          icon: Icon(Icons.arrow_downward),
        ),
      ],
      selected: {selectedType},
      onSelectionChanged: (newSelection) {
        onSelectionChanged(newSelection.first);
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: primaryColor,
        selectedForegroundColor: Colors.white,
      ),
    );
  }
}
