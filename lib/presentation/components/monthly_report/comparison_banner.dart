import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../blocs/stats_cubit.dart';

class ComparisonBanner extends StatelessWidget {
  final double totalSpent;
  final double prevPeriodTotal;
  final ReportViewMode viewMode;

  const ComparisonBanner({
    super.key,
    required this.totalSpent,
    required this.prevPeriodTotal,
    required this.viewMode,
  });

  @override
  Widget build(BuildContext context) {
    if (prevPeriodTotal <= 0) return const SizedBox.shrink();

    final diff = totalSpent - prevPeriodTotal;
    final pct = (diff.abs() / prevPeriodTotal * 100).toStringAsFixed(0);
    final isLess = diff < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isLess ? Colors.greenAccent.withOpacity(0.05) : Colors.redAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLess
              ? Colors.greenAccent.withOpacity(0.2)
              : Colors.redAccent.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLess
                  ? Colors.greenAccent.withOpacity(0.1)
                  : Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLess ? Icons.trending_down : Icons.trending_up,
              color: isLess ? Colors.greenAccent[700] : Colors.redAccent[700],
              size: 20,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Text(
              isLess
                  ? 'Great! You spent $pct% less than the previous ${viewMode.name}.'
                  : 'Watch out. You spent $pct% more than the previous ${viewMode.name}.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
