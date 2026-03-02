import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../blocs/stats_cubit.dart';

class ReportHeader extends StatelessWidget {
  final String title;
  final ReportViewMode viewMode;
  final double average;

  const ReportHeader({
    super.key,
    required this.title,
    required this.viewMode,
    required this.average,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        const Gap(24),
        Center(
          child: Text(
            viewMode == ReportViewMode.yearly
                ? 'Monthly Avg Spent: ETB ${average.toStringAsFixed(2)}'
                : 'Daily Avg Spent: ETB ${average.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
