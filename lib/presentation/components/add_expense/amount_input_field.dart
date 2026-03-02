import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../data/models/expense_model.dart';

class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool autofocus;
  final TransactionType transactionType;

  const AmountInputField({
    super.key,
    required this.controller,
    required this.autofocus,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text(
            'AMOUNT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const Gap(12),
          TextField(
            controller: controller,
            autofocus: autofocus,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: transactionType == TransactionType.income
                  ? Colors.greenAccent[700]
                  : Theme.of(context).colorScheme.onSurface,
              letterSpacing: -1.5,
            ),
            decoration: InputDecoration(
              prefixText: 'ETB ',
              prefixStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
              ),
              border: InputBorder.none,
              hintText: '0.00',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
