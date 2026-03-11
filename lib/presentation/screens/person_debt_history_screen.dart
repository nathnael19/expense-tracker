import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../data/models/debt_model.dart';
import '../../data/models/person_model.dart';
import '../blocs/debt_cubit.dart';
import 'add_debt_screen.dart';

class PersonDebtHistoryScreen extends StatelessWidget {
  final PersonModel person;

  const PersonDebtHistoryScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtCubit, DebtState>(
      builder: (context, state) {
        final personHistory = state.debts
            .where((d) =>
                (d.personId == person.id || (d.personId == null && d.personName == person.name)) &&
                d.isPaid)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return Scaffold(
          appBar: AppBar(
            title: Text('${person.name}\'s History'),
          ),
          body: personHistory.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: personHistory.length,
                  itemBuilder: (context, index) {
                    final debt = personHistory[index];
                    return _HistoryItemTile(debt: debt);
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[300]),
          const Gap(16),
          const Text(
            'No settled records found',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _HistoryItemTile extends StatelessWidget {
  final DebtModel debt;

  const _HistoryItemTile({required this.debt});

  @override
  Widget build(BuildContext context) {
    final isLent = debt.type == DebtType.lent;
    final color = isLent ? Colors.green : Colors.redAccent;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDebtScreen(debt: debt),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            isLent ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          (debt.reason ?? '').isNotEmpty ? debt.reason! : (isLent ? 'Lent' : 'Borrowed'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${isLent ? 'Paid' : 'Repaid'} • ${DateFormat.yMMMd().format(debt.date)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'ETB ${debt.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            const Text(
              'Settled',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
