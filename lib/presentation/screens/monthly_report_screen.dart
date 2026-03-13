// ignore_for_file: deprecated_member_use, no_leading_underscores_for_local_identifiers

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../blocs/stats_cubit.dart';
import '../blocs/category_cubit.dart';
import '../../data/models/category_model.dart';
import '../../data/services/pdf_service.dart';

import '../components/monthly_report/view_mode_selector.dart';
import '../components/monthly_report/comparison_banner.dart';
import '../components/monthly_report/report_pie_chart.dart';
import '../components/monthly_report/categorized_spending_list.dart';
import '../components/monthly_report/report_header.dart';
import '../components/monthly_report/category_detail_sheet.dart';
import '../components/monthly_report/export_popup_menu.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsState = context.watch<StatsCubit>().state;
    final stats = statsState.reportStats;
    final currentDate = statsState.selectedDate;
    final viewMode = statsState.viewMode;
    final categories = context.watch<CategoryCubit>().state;

    final sortedCatKeys = stats.categoryTotals.keys.toList()..sort((a, b) => stats.categoryTotals[b]!.compareTo(stats.categoryTotals[a]!));
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.amber];

    String _getTitle() {
      if (viewMode == ReportViewMode.weekly) {
        final firstDay = currentDate.subtract(Duration(days: currentDate.weekday - 1));
        return '${DateFormat.MMMd().format(firstDay)} - ${DateFormat.yMMMd().format(firstDay.add(const Duration(days: 6)))}';
      }
      return viewMode == ReportViewMode.monthly ? DateFormat.yMMMM().format(currentDate) : DateFormat.y().format(currentDate);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'), elevation: 0,
        actions: [
          ExportPopupMenu(
            onExportCsv: () => _exportCsv(context, stats.expenses, categories, viewMode, currentDate),
            onExportPdf: () => PdfService.generateAndShareReport(title: _getTitle(), expenses: stats.expenses, categories: categories, totalIncome: stats.totalIncome, totalSpent: stats.totalSpent, netBalance: stats.netBalance),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(context: context, initialDate: currentDate, firstDate: DateTime(2000), lastDate: DateTime.now());
              if (picked != null && context.mounted) {
                context.read<StatsCubit>().changeDate(picked);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ViewModeSelector(selectedMode: viewMode, onSelectionChanged: (mode) => context.read<StatsCubit>().changeViewMode(mode)),
            const Gap(24),
            ComparisonBanner(totalSpent: stats.totalSpent, prevPeriodTotal: statsState.previousPeriodTotal, viewMode: viewMode),
            const Gap(24),
            ReportHeader(title: _getTitle(), viewMode: viewMode, average: stats.average),
            const Gap(32),
            ReportPieChart(totalSpent: stats.totalSpent, categoryTotals: stats.categoryTotals, sortedCatKeys: sortedCatKeys, colors: colors),
            const Gap(32),
            const Text('Categorized Spending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Gap(16),
            CategorizedSpendingList(
              sortedCatKeys: sortedCatKeys, categoryTotals: stats.categoryTotals, categories: categories, totalSpent: stats.totalSpent, colors: colors, expenses: stats.expenses,
              onCategoryTap: (cat, exp, col) => showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (context) => CategoryDetailSheet(category: cat, expenses: exp, color: col)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, List<dynamic> expenses, List<CategoryModel> categories, ReportViewMode viewMode, DateTime currentDate) async {
    if (expenses.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No data to export'))); return; }
    final buffer = StringBuffer()..writeln('Date,Category,Note,Amount');
    final sortedExpenses = [...expenses]..sort((a, b) => b.date.compareTo(a.date));
    for (final e in sortedExpenses) {
      final cat = categories.firstWhere((c) => c.id == e.categoryId, orElse: () => CategoryModel(id: 'unknown', name: 'Unknown', iconCode: 0));
      buffer.writeln('${DateFormat('yyyy-MM-dd').format(e.date)},"${cat.name}","${e.note}",${e.amount}');
    }
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/expense_report_${viewMode.name}_${DateFormat('yyyyMMdd').format(currentDate)}.csv';
    await File(path).writeAsString(buffer.toString());
    await Share.shareXFiles([XFile(path)], text: 'Expense Report (${viewMode.name})');
  }
}
