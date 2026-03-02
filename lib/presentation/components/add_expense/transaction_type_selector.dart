import 'package:flutter/material.dart';
import '../../../data/models/expense_model.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType currentType;
  final ValueChanged<TransactionType> onTypeChanged;

  const TransactionTypeSelector({
    super.key,
    required this.currentType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: 'Expense',
              isSelected: currentType == TransactionType.expense,
              color: Colors.redAccent,
              onTap: () => onTypeChanged(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: 'Income',
              isSelected: currentType == TransactionType.income,
              color: Colors.greenAccent[700]!,
              onTap: () => onTypeChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
