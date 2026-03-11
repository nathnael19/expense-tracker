import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../data/models/debt_model.dart';
import '../../data/models/person_model.dart';
import '../blocs/debt_cubit.dart';
import 'add_debt_screen.dart';

import 'person_debt_history_screen.dart';

class PersonDetailScreen extends StatelessWidget {
  final PersonModel person;

  const PersonDetailScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(person.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonDebtHistoryScreen(person: person),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeletePersonDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Build summary card only when balance changes
          Builder(builder: (context) {
            final balance = context.select<DebtCubit, double>(
              (cubit) => cubit.state.getPersonBalance(person.id),
            );
            return _buildSummaryCard(context, balance);
          }),
          Expanded(
            child: BlocSelector<DebtCubit, DebtState, List<DebtModel>>(
              selector: (state) => state.debts
                  .where((d) =>
                      (d.personId == person.id ||
                          (d.personId == null && d.personName == person.name)) &&
                      !d.isPaid)
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date)),
              builder: (context, activeDebts) {
                if (activeDebts.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeDebts.length,
                  itemBuilder: (context, index) {
                    return _DebtItemTile(debt: activeDebts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDebtScreen(
                debt: null,
                initialPerson: person,
              ),
            ),
          );
        },
        label: const Text('Add Record'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, double balance) {
    final color = balance >= 0 ? Colors.green : Colors.redAccent;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            balance >= 0 ? 'They owe you' : 'You owe them',
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(8),
          Text(
            'ETB ${balance.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notes, size: 64, color: Colors.grey[300]),
          const Gap(16),
          const Text(
            'No records for this person yet',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showDeletePersonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Person'),
        content: Text('Are you sure you want to delete ${person.name}? This will not delete their records, but they will be unlinked.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DebtCubit>().deletePerson(person.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _DebtItemTile extends StatelessWidget {
  final DebtModel debt;

  const _DebtItemTile({required this.debt});

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
          '${isLent ? 'Lent' : 'Borrowed'} • ${DateFormat.yMMMd().format(debt.date)}',
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
            const Gap(4),
            if (!debt.isPaid)
              InkWell(
                onTap: () {
                  context.read<DebtCubit>().togglePaidStatus(debt);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isLent ? 'Mark Paid' : 'Mark Repaid',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              Text(
                isLent ? 'Paid' : 'Repaid',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        onLongPress: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Record'),
              content: const Text(
                'Are you sure you want to delete this record?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<DebtCubit>().deleteDebt(debt.id);
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
