import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../data/models/debt_model.dart';
import '../../data/models/person_model.dart';
import '../blocs/debt_cubit.dart';
import '../screens/add_debt_screen.dart';
import '../screens/person_debt_history_screen.dart';
import '../components/debt/person_summary_card.dart';
import '../components/debt/debt_item_tile.dart';

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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PersonDebtHistoryScreen(person: person))),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeletePersonDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Builder(builder: (context) {
            final balance = context.select<DebtCubit, double>((cubit) => cubit.state.getPersonBalance(person.id));
            return PersonSummaryCard(balance: balance);
          }),
          Expanded(
            child: BlocSelector<DebtCubit, DebtState, List<DebtModel>>(
              selector: (state) => state.debts
                  .where((d) => (d.personId == person.id || (d.personId == null && d.personName == person.name)) && !d.isPaid)
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date)),
              builder: (context, activeDebts) {
                if (activeDebts.isEmpty) return _buildEmptyState();
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeDebts.length,
                  itemBuilder: (context, index) => DebtItemTile(debt: activeDebts[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddDebtScreen(debt: null, initialPerson: person))),
        label: const Text('Add Record'),
        icon: const Icon(Icons.add),
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
          const Text('No records for this person yet', style: TextStyle(color: Colors.grey)),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<DebtCubit>().deletePerson(person.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
