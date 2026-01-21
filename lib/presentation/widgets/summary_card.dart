// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SummaryCard extends StatelessWidget {
  final double todaysTotal; // This represents total expense
  final double todaysIncome;
  final double todaysNetBalance;
  final double monthlyTotal;
  final double? monthlyBudget;

  const SummaryCard({
    super.key,
    required this.todaysTotal,
    required this.todaysIncome,
    required this.todaysNetBalance,
    required this.monthlyTotal,
    this.monthlyBudget,
  });

  @override
  Widget build(BuildContext context) {
    // Determine gradient based on brightness to ensure it pops but fits
    // For this specific 'surprise' feature, we'll use a vibrant gradient that works well
    // in both modes, or adjusts slightly.

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4e54c8), // Cyber-ish Blue
            Color(0xFF8f94fb), // Softer Purple-Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4e54c8).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Net Balance Today',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(8),
                Text(
                  'ETB ${todaysNetBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.0,
                  ),
                ),
                const Gap(24),
                Row(
                  children: [
                    _MiniStat(
                      label: 'Income',
                      amount: todaysIncome,
                      icon: Icons.arrow_upward,
                      color: Colors.greenAccent,
                    ),
                    const Gap(16),
                    _MiniStat(
                      label: 'Expense',
                      amount: todaysTotal,
                      icon: Icons.arrow_downward,
                      color: Colors.orangeAccent,
                    ),
                  ],
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 14,
                      ),
                      const Gap(6),
                      Text(
                        'Monthly Spent: ETB ${monthlyTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (monthlyBudget != null) ...[
                  const Gap(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monthly Budget',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        'ETB ${monthlyTotal.toStringAsFixed(0)} / ${monthlyBudget!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (monthlyTotal / monthlyBudget!).clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        monthlyTotal > monthlyBudget!
                            ? Colors.redAccent
                            : Colors.greenAccent,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const Gap(4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const Gap(4),
        Text(
          'ETB ${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
