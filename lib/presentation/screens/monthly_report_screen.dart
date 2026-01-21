// ignore_for_file: deprecated_member_use, no_leading_underscores_for_local_identifiers

import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../blocs/stats_cubit.dart';
import '../blocs/category_cubit.dart';
import '../../data/models/category_model.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsCubit = context.watch<StatsCubit>();
    final statsState = statsCubit.state;
    final stats = statsState.reportStats;
    final currentDate = statsState.selectedDate;
    final viewMode = statsState.viewMode;
    final categories = context.watch<CategoryCubit>().state;
    final prevPeriodTotal = statsState.previousPeriodTotal;

    // Sort categories by spend desc
    final sortedCatKeys = stats.categoryTotals.keys.toList()
      ..sort(
        (a, b) => stats.categoryTotals[b]!.compareTo(stats.categoryTotals[a]!),
      );

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
    ];

    // Export Logic
    Future<void> _exportData() async {
      final buffer = StringBuffer();
      buffer.writeln('Date,Category,Note,Amount');

      final expenses = [...stats.expenses]
        ..sort((a, b) => b.date.compareTo(a.date));

      for (final e in expenses) {
        final cat = categories.firstWhere(
          (c) => c.id == e.categoryId,
          orElse: () =>
              CategoryModel(id: 'unknown', name: 'Unknown', iconCode: 0),
        );
        buffer.writeln(
          '${DateFormat('yyyy-MM-dd').format(e.date)},"${cat.name}","${e.note}",${e.amount}',
        );
      }

      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/expense_report_${viewMode.name}_${DateFormat('yyyyMMdd').format(currentDate)}.csv';
      final file = File(path);
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(path)],
        text:
            'Expense Report (${viewMode.name}) - ${DateFormat.yMMMM().format(currentDate)}',
      );
    }

    String _getTitle() {
      switch (viewMode) {
        case ReportViewMode.weekly:
          final firstDay = currentDate.subtract(
            Duration(days: currentDate.weekday - 1),
          );
          final lastDay = firstDay.add(const Duration(days: 6));
          return '${DateFormat.MMMd().format(firstDay)} - ${DateFormat.yMMMd().format(lastDay)}';
        case ReportViewMode.monthly:
          return DateFormat.yMMMM().format(currentDate);
        case ReportViewMode.yearly:
          return DateFormat.y().format(currentDate);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              if (stats.expenses.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No data to export')),
                );
                return;
              }
              _exportData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) statsCubit.changeDate(picked);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // View Mode Selector
              Center(
                child: SegmentedButton<ReportViewMode>(
                  segments: const [
                    ButtonSegment(
                      value: ReportViewMode.weekly,
                      label: Text('Week'),
                    ),
                    ButtonSegment(
                      value: ReportViewMode.monthly,
                      label: Text('Month'),
                    ),
                    ButtonSegment(
                      value: ReportViewMode.yearly,
                      label: Text('Year'),
                    ),
                  ],
                  selected: {viewMode},
                  onSelectionChanged: (value) {
                    statsCubit.changeViewMode(value.first);
                  },
                ),
              ),
              const Gap(24),

              // Comparison Banner
              if (prevPeriodTotal > 0) ...[
                Builder(
                  builder: (context) {
                    final diff = stats.totalSpent - prevPeriodTotal;
                    final pct = (diff.abs() / prevPeriodTotal * 100)
                        .toStringAsFixed(0);
                    final isLess = diff < 0;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isLess
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isLess
                              ? Colors.green.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        isLess
                            ? '🎉 Spent $pct% less than previous ${viewMode.name}!'
                            : '⚠️ Spent $pct% more than previous ${viewMode.name}.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isLess
                              ? Colors.green[800]
                              : Colors.orange[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                const Gap(24),
              ],

              Center(
                child: Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Gap(8),
              Center(
                child: Column(
                  children: [
                    Text(
                      'ETB ${stats.totalSpent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      viewMode == ReportViewMode.yearly
                          ? 'Monthly Avg: ETB ${stats.average.toStringAsFixed(2)}'
                          : 'Daily Avg: ETB ${stats.average.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(32),

              // Bar Chart
              if (stats.totalSpent > 0)
                AspectRatio(
                  aspectRatio: 1.7,
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => Colors.blueGrey.shade900,
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.toStringAsFixed(0)}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: (viewMode == ReportViewMode.weekly)
                                      ? 'Day'
                                      : (viewMode == ReportViewMode.monthly)
                                      ? 'Week'
                                      : 'Month',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              String text = '';
                              if (viewMode == ReportViewMode.weekly) {
                                const days = [
                                  'M',
                                  'T',
                                  'W',
                                  'T',
                                  'F',
                                  'S',
                                  'S',
                                ];
                                if (value >= 0 && value < 7) {
                                  text = days[value.toInt()];
                                }
                              } else if (viewMode == ReportViewMode.monthly) {
                                text = 'W${value.toInt() + 1}';
                              } else {
                                const months = [
                                  'J',
                                  'F',
                                  'M',
                                  'A',
                                  'M',
                                  'J',
                                  'J',
                                  'A',
                                  'S',
                                  'O',
                                  'N',
                                  'D',
                                ];
                                if (value >= 0 && value < 12) {
                                  text = months[value.toInt()];
                                }
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: stats.periodicTotals.asMap().entries.map((
                        entry,
                      ) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value,
                              color: Theme.of(context).colorScheme.primary,
                              width: 16,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY:
                                    stats.periodicTotals.reduce(
                                      (a, b) => a > b ? a : b,
                                    ) *
                                    1.1,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant.withOpacity(0.3),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                )
              else
                const SizedBox(
                  height: 100,
                  child: Center(child: Text('No data for this period')),
                ),

              const Gap(32),

              // Breakdown List
              const Text(
                'Categorized Spending',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Gap(16),

              if (sortedCatKeys.isEmpty)
                const Center(child: Text('No categories to display'))
              else
                ...sortedCatKeys.map((catId) {
                  final val = stats.categoryTotals[catId]!;
                  final cat =
                      categories.where((c) => c.id == catId).firstOrNull ??
                      CategoryModel(
                        id: 'unknown',
                        name: 'Unknown',
                        iconCode: 0xe88e,
                      );
                  final index = sortedCatKeys.indexOf(catId);
                  final color = colors[index % colors.length];

                  return InkWell(
                    onTap: () {
                      _showCategoryDetails(
                        context,
                        cat,
                        stats.expenses
                            .where((e) => e.categoryId == catId)
                            .toList(),
                        color,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              IconData(
                                cat.iconCode,
                                fontFamily: 'MaterialIcons',
                              ),
                              color: color,
                              size: 20,
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: stats.totalSpent > 0
                                        ? val / stats.totalSpent
                                        : 0,
                                    backgroundColor: Colors.grey[100],
                                    color: color,
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(16),
                          Text(
                            'ETB ${val.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Gap(4),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDetails(
    BuildContext context,
    CategoryModel category,
    List<dynamic> expenses,
    Color color,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                      color: color,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${expenses.length} items',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const Gap(20),
              Flexible(
                child: expenses.isEmpty
                    ? const Center(child: Text('No transactions found'))
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: expenses.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (context, index) {
                          final e = expenses[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              e.note.isEmpty ? 'No description' : e.note,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat.yMMMd().format(e.date),
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              'ETB ${e.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
