import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PersonSummaryCard extends StatelessWidget {
  final double balance;

  const PersonSummaryCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final color = balance >= 0 ? Colors.green : Colors.redAccent;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            balance >= 0 ? 'They owe you' : 'You owe them',
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(8),
          Text(
            'ETB ${balance.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
