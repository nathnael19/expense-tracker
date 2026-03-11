import 'package:expense_tracker_offline/data/models/person_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import '../blocs/debt_cubit.dart';
import 'person_detail_screen.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  void _showAddPersonDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Person'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter person name',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final newPerson = PersonModel(
                  id: const Uuid().v4(),
                  name: nameController.text.trim(),
                  createdAt: DateTime.now(),
                );
                context.read<DebtCubit>().addPerson(newPerson);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Manager'),
      ),
      body: const _PersonList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPersonDialog,
        label: const Text('Add Person'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _PersonList extends StatelessWidget {
  const _PersonList();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DebtCubit, DebtState, List<PersonModel>>(
      selector: (state) => state.persons,
      builder: (context, persons) {
        if (persons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                const Gap(16),
                const Text(
                  'No people added yet',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const Gap(8),
                TextButton(
                  onPressed: () {
                    (context.findAncestorStateOfType<_DebtScreenState>())?._showAddPersonDialog();
                  },
                  child: const Text('Add your first person'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: persons.length,
          itemBuilder: (context, index) {
            final person = persons[index];
            // We still need the cubit to get the balance, but we use BlocBuilder here
            // because individual item balances might change when debts change.
            return _PersonListItem(person: person);
          },
        );
      },
    );
  }
}

class _PersonListItem extends StatelessWidget {
  final PersonModel person;
  const _PersonListItem({required this.person});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtCubit, DebtState>(
      buildWhen: (previous, current) {
        // Only rebuild if this specific person's balance might have changed
        // This happens if the debts list changes or this specific person is deleted/updated
        return previous.debts != current.debts || previous.persons != current.persons;
      },
      builder: (context, state) {
        final balance = state.getPersonBalance(person.id);
        final color = balance >= 0 ? Colors.green : Colors.redAccent;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonDetailScreen(person: person),
                ),
              );
            },
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Text(
                person.name[0].toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              person.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ETB ${balance.abs().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: balance == 0 ? Colors.grey : color,
                  ),
                ),
                Text(
                  balance >= 0 ? 'Receivable' : 'Payable',
                  style: TextStyle(
                    fontSize: 10,
                    color: balance == 0 ? Colors.grey : color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

