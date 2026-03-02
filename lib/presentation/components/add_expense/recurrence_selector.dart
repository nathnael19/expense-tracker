import 'package:flutter/material.dart';
import '../../../data/models/expense_model.dart';
import 'package:gap/gap.dart';

class RecurrenceSelector extends StatelessWidget {
  final RecurrenceType currentRecurrence;
  final ValueChanged<RecurrenceType> onRecurrenceChanged;

  const RecurrenceSelector({
    super.key,
    required this.currentRecurrence,
    required this.onRecurrenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECURRENCE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const Gap(12),
        Row(
          children: [
            _RecurrenceChip(
              label: 'Weekly',
              isSelected: currentRecurrence == RecurrenceType.weekly,
              onTap: () => onRecurrenceChanged(RecurrenceType.weekly),
            ),
            const Gap(12),
            _RecurrenceChip(
              label: 'Monthly',
              isSelected: currentRecurrence == RecurrenceType.monthly,
              onTap: () => onRecurrenceChanged(RecurrenceType.monthly),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecurrenceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecurrenceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
