import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../data/models/debt_model.dart';
import '../../data/models/person_model.dart';

class DebtState {
  final List<DebtModel> debts;
  final List<PersonModel> persons;
  final bool isLoading;
  final String? error;

  // Memoized lists to avoid recalculating every time a getter is accessed
  final List<DebtModel> activeDebts;
  final List<DebtModel> historyDebts;

  DebtState({
    this.debts = const [],
    this.persons = const [],
    this.isLoading = false,
    this.error,
  })  : activeDebts = List.unmodifiable(
          debts.where((d) => !(d.isPaid)).toList()
            ..sort((a, b) => b.date.compareTo(a.date)),
        ),
        historyDebts = List.unmodifiable(
          debts.where((d) => d.isPaid).toList()
            ..sort((a, b) => b.date.compareTo(a.date)),
        );

  double get totalLent => activeDebts
      .where((d) => d.type == DebtType.lent)
      .fold(0.0, (sum, d) => sum + d.amount);

  double get totalBorrowed => activeDebts
      .where((d) => d.type == DebtType.borrowed)
      .fold(0.0, (sum, d) => sum + d.amount);

  double get totalNetBalance => totalLent - totalBorrowed;

  double getPersonBalance(String personId) {
    final person = persons.where((p) => p.id == personId).firstOrNull;
    if (person == null) return 0.0;

    final personDebts = debts.where((d) =>
        d.personId == personId || (d.personId == null && d.personName == person.name));
    double balance = 0;
    for (var d in personDebts) {
      if (d.isPaid) continue;
      if (d.type == DebtType.lent) {
        balance += d.amount;
      } else {
        balance -= d.amount;
      }
    }
    return balance;
  }

  DebtState copyWith({
    List<DebtModel>? debts,
    List<PersonModel>? persons,
    bool? isLoading,
    String? error,
  }) {
    return DebtState(
      debts: debts ?? this.debts,
      persons: persons ?? this.persons,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DebtCubit extends Cubit<DebtState> {
  static const String boxName = 'debts';
  static const String personBoxName = 'persons';
  late Box<DebtModel> _box;
  late Box<PersonModel> _personBox;

  DebtCubit() : super(DebtState(isLoading: true)) {
    Future.microtask(() => _init());
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<DebtModel>(boxName);
      _personBox = await Hive.openBox<PersonModel>(personBoxName);
      loadDebts();
    } catch (e) {
      debugPrint('Error initializing DebtCubit: $e');
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void loadDebts() {
    emit(state.copyWith(
      debts: _box.values.toList(),
      persons: _personBox.values.toList(),
      isLoading: false,
    ));
  }

  // Person Methods
  Future<void> addPerson(PersonModel person) async {
    try {
      await _personBox.put(person.id, person);
      emit(state.copyWith(persons: _personBox.values.toList()));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deletePerson(String id) async {
    try {
      final person = _personBox.get(id);
      if (person == null) return;

      // 1. Delete all debts for this person to keep totals accurate
      final debtIdsToDelete = _box.values
          .where((d) =>
              d.personId == id ||
              (d.personId == null && d.personName == person.name))
          .map((d) => d.id)
          .toList();

      for (var debtId in debtIdsToDelete) {
        await _box.delete(debtId);
      }

      // 2. Delete the person
      await _personBox.delete(id);

      emit(state.copyWith(
        debts: _box.values.toList(),
        persons: _personBox.values.toList(),
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Debt Methods
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
      await _box.put(debt.id, debt);
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
    await _box.put(debt.id, updatedDebt);
    emit(state.copyWith(debts: _box.values.toList()));
  }
}
