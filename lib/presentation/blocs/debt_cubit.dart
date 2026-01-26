import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../data/models/debt_model.dart';

class DebtState {
  final List<DebtModel> debts;
  final bool isLoading;
  final String? error;

  DebtState({this.debts = const [], this.isLoading = false, this.error});

  List<DebtModel> get activeDebts =>
      debts.where((d) => !d.isPaid).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<DebtModel> get historyDebts =>
      debts.where((d) => d.isPaid).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  double get totalLent => activeDebts
      .where((d) => d.type == DebtType.lent)
      .fold(0.0, (sum, d) => sum + d.amount);

  DebtState copyWith({List<DebtModel>? debts, bool? isLoading, String? error}) {
    return DebtState(
      debts: debts ?? this.debts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DebtCubit extends Cubit<DebtState> {
  static const String boxName = 'debts';
  late Box<DebtModel> _box;

  DebtCubit() : super(DebtState(isLoading: true)) {
    Future.microtask(() => _init());
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<DebtModel>(boxName);
      emit(state.copyWith(debts: _box.values.toList(), isLoading: false));
    } catch (e) {
      debugPrint('Error initializing DebtCubit: $e');
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> addDebt(DebtModel debt) async {
    try {
      await _box.put(debt.id, debt);
      emit(state.copyWith(debts: _box.values.toList()));
    } catch (e) {
      debugPrint('Error adding debt: $e');
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateDebt(DebtModel debt) async {
    try {
      await debt.save();
      emit(state.copyWith(debts: _box.values.toList()));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteDebt(String id) async {
    try {
      await _box.delete(id);
      emit(state.copyWith(debts: _box.values.toList()));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> togglePaidStatus(DebtModel debt) async {
    final updatedDebt = debt.copyWith(isPaid: !debt.isPaid);
    // Be careful with direct ID put if the original object instance is reused from Hive
    // Using HiveObject save/delete is safer when we have the object reference from the box
    // But since we created copyWith we need to put it back using the key
    await _box.put(debt.id, updatedDebt);
    emit(state.copyWith(debts: _box.values.toList()));
  }
}
