// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

enum EmptyStateType { home, chart, generic }

class SmartEmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? message;

  const SmartEmptyState({
    super.key,
    this.type = EmptyStateType.generic,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String text;

    switch (type) {
      case EmptyStateType.home:
        icon = Icons.receipt_long;
        text = "No expenses yet. Either a great day… or you forgot.";
        break;
      case EmptyStateType.chart:
        icon = Icons.pie_chart_outline;
        text = "Not enough data to graph!";
        break;
      case EmptyStateType.generic:
        icon = Icons.info_outline;
        text = "Nothing to see here.";
        break;
    }

    if (message != null) text = message!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ),
          ),
          const Gap(24),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
