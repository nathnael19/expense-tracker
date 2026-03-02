import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class DateNoteInputs extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onDatePickerTap;
  final TextEditingController noteController;

  const DateNoteInputs({
    super.key,
    required this.selectedDate,
    required this.onDatePickerTap,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InputContainer(
            onTap: onDatePickerTap,
            icon: Icons.calendar_today_rounded,
            label: DateFormat('MMM d, y').format(selectedDate),
          ),
        ),
        const Gap(16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: 'Note...',
                border: InputBorder.none,
                icon: Icon(Icons.edit_note_rounded, size: 20, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InputContainer extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;

  const _InputContainer({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const Gap(12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
