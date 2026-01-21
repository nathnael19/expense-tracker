import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/expense_model.dart';
import 'expense_cubit.dart';

enum ReportViewMode { weekly, monthly, yearly }

class ReportStats {
  final double totalSpent;
  final double average;
  final Map<String, double> categoryTotals;
  final List<ExpenseModel> expenses;
  final List<double>
  periodicTotals; // e.g. 7 days for week, ~4 weeks for month, 12 months for year

  ReportStats({
    required this.totalSpent,
    required this.average,
    required this.categoryTotals,
    required this.expenses,
    required this.periodicTotals,
  });

  factory ReportStats.empty() => ReportStats(
    totalSpent: 0,
    average: 0,
    categoryTotals: {},
    expenses: [],
    periodicTotals: [],
  );
}

class StatsState {
  final DateTime selectedDate;
  final ReportViewMode viewMode;
  final ReportStats reportStats;
  final double previousPeriodTotal;
  final int streak;

  StatsState({
    required this.selectedDate,
    required this.viewMode,
    required this.reportStats,
    required this.previousPeriodTotal,
    required this.streak,
  });

  factory StatsState.initial() => StatsState(
    selectedDate: DateTime.now(),
    viewMode: ReportViewMode.monthly,
    reportStats: ReportStats.empty(),
    previousPeriodTotal: 0,
    streak: 0,
  );

  StatsState copyWith({
    DateTime? selectedDate,
    ReportViewMode? viewMode,
    ReportStats? reportStats,
    double? previousPeriodTotal,
    int? streak,
  }) {
    return StatsState(
      selectedDate: selectedDate ?? this.selectedDate,
      viewMode: viewMode ?? this.viewMode,
      reportStats: reportStats ?? this.reportStats,
      previousPeriodTotal: previousPeriodTotal ?? this.previousPeriodTotal,
      streak: streak ?? this.streak,
    );
  }
}

class StatsCubit extends Cubit<StatsState> {
  final ExpenseCubit expenseCubit;
  late StreamSubscription _expenseSubscription;

  StatsCubit({required this.expenseCubit}) : super(StatsState.initial()) {
    _expenseSubscription = expenseCubit.stream.listen((_) {
      _calculateStats();
    });
    _calculateStats();
  }

  void changeDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
    _calculateStats();
  }

  void changeViewMode(ReportViewMode mode) {
    emit(state.copyWith(viewMode: mode));
    _calculateStats();
  }

  void _calculateStats() {
    final allExpenses = expenseCubit.state.allExpenses;
    final selectedDate = state.selectedDate;
    final viewMode = state.viewMode;

    List<ExpenseModel> filteredExpenses = [];
    DateTime prevPeriodDate;

    switch (viewMode) {
      case ReportViewMode.weekly:
        // Week starts from Monday
        final firstDayOfWeek = selectedDate.subtract(
          Duration(days: selectedDate.weekday - 1),
        );
        final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
        filteredExpenses = allExpenses.where((e) {
          final date = DateTime(e.date.year, e.date.month, e.date.day);
          return (date.isAtSameMomentAs(
                    DateTime(
                      firstDayOfWeek.year,
                      firstDayOfWeek.month,
                      firstDayOfWeek.day,
                    ),
                  ) ||
                  date.isAfter(firstDayOfWeek)) &&
              (date.isAtSameMomentAs(
                    DateTime(
                      lastDayOfWeek.year,
                      lastDayOfWeek.month,
                      lastDayOfWeek.day,
                    ),
                  ) ||
                  date.isBefore(lastDayOfWeek));
        }).toList();
        prevPeriodDate = selectedDate.subtract(const Duration(days: 7));
        break;
      case ReportViewMode.monthly:
        filteredExpenses = allExpenses.where((e) {
          return e.date.year == selectedDate.year &&
              e.date.month == selectedDate.month;
        }).toList();
        prevPeriodDate = DateTime(selectedDate.year, selectedDate.month - 1);
        break;
      case ReportViewMode.yearly:
        filteredExpenses = allExpenses.where((e) {
          return e.date.year == selectedDate.year;
        }).toList();
        prevPeriodDate = DateTime(selectedDate.year - 1);
        break;
    }

    // Previous period total
    double prevTotal = 0;
    switch (viewMode) {
      case ReportViewMode.weekly:
        final firstDayPrev = prevPeriodDate.subtract(
          Duration(days: prevPeriodDate.weekday - 1),
        );
        final lastDayPrev = firstDayPrev.add(const Duration(days: 6));
        prevTotal = allExpenses
            .where((e) {
              final date = DateTime(e.date.year, e.date.month, e.date.day);
              return (date.isAtSameMomentAs(
                        DateTime(
                          firstDayPrev.year,
                          firstDayPrev.month,
                          firstDayPrev.day,
                        ),
                      ) ||
                      date.isAfter(firstDayPrev)) &&
                  (date.isAtSameMomentAs(
                        DateTime(
                          lastDayPrev.year,
                          lastDayPrev.month,
                          lastDayPrev.day,
                        ),
                      ) ||
                      date.isBefore(lastDayPrev));
            })
            .fold(0.0, (sum, e) => sum + e.amount);
        break;
      case ReportViewMode.monthly:
        prevTotal = allExpenses
            .where(
              (e) =>
                  e.date.year == prevPeriodDate.year &&
                  e.date.month == prevPeriodDate.month,
            )
            .fold(0.0, (sum, e) => sum + e.amount);
        break;
      case ReportViewMode.yearly:
        prevTotal = allExpenses
            .where((e) => e.date.year == prevPeriodDate.year)
            .fold(0.0, (sum, e) => sum + e.amount);
        break;
    }

    // Periodic Totals for Chart
    List<double> periodicTotals = [];
    double totalSpent = 0;
    Map<String, double> catTotals = {};
    for (var e in filteredExpenses) {
      totalSpent += e.amount;
      catTotals[e.categoryId] = (catTotals[e.categoryId] ?? 0) + e.amount;
    }

    if (viewMode == ReportViewMode.weekly) {
      periodicTotals = List.generate(7, (index) => 0.0);
      final firstDayOfWeek = selectedDate.subtract(
        Duration(days: selectedDate.weekday - 1),
      );
      for (var e in filteredExpenses) {
        final diff = e.date
            .difference(
              DateTime(
                firstDayOfWeek.year,
                firstDayOfWeek.month,
                firstDayOfWeek.day,
              ),
            )
            .inDays;
        if (diff >= 0 && diff < 7) {
          periodicTotals[diff] += e.amount;
        }
      }
    } else if (viewMode == ReportViewMode.monthly) {
      // Divide by weeks
      periodicTotals = List.generate(5, (index) => 0.0);
      for (var e in filteredExpenses) {
        int week = (e.date.day - 1) ~/ 7;
        if (week >= 5) week = 4;
        periodicTotals[week] += e.amount;
      }
    } else {
      periodicTotals = List.generate(12, (index) => 0.0);
      for (var e in filteredExpenses) {
        periodicTotals[e.date.month - 1] += e.amount;
      }
    }

    double average = 0;
    if (viewMode == ReportViewMode.weekly) {
      average = totalSpent / 7;
    } else if (viewMode == ReportViewMode.monthly) {
      final now = DateTime.now();
      int daysCount;
      if (selectedDate.year == now.year && selectedDate.month == now.month) {
        daysCount = now.day;
      } else {
        daysCount = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
      }
      average = daysCount > 0 ? totalSpent / daysCount : 0;
    } else {
      average = totalSpent / 12;
    }

    final reportStats = ReportStats(
      totalSpent: totalSpent,
      average: average,
      categoryTotals: catTotals,
      expenses: filteredExpenses,
      periodicTotals: periodicTotals,
    );

    // Streak logic
    int streak = 0;
    if (allExpenses.isNotEmpty) {
      final sortedDates =
          allExpenses
              .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      if (sortedDates.contains(todayDate) ||
          sortedDates.contains(todayDate.subtract(const Duration(days: 1)))) {
        DateTime checkDate = sortedDates.contains(todayDate)
            ? todayDate
            : todayDate.subtract(const Duration(days: 1));
        while (sortedDates.contains(checkDate)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        }
      }
    }

    emit(
      state.copyWith(
        reportStats: reportStats,
        previousPeriodTotal: prevTotal,
        streak: streak,
      ),
    );
  }

  @override
  Future<void> close() {
    _expenseSubscription.cancel();
    return super.close();
  }
}
