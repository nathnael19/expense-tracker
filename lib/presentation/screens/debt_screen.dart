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
      builder: (ctx) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Person',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Gap(24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter person name',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const Gap(32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  const Gap(12),
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 0,
                    ),
                    child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Manager', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
      ),
      body: const _PersonList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPersonDialog,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: const Text('Add Person', style: TextStyle(fontWeight: FontWeight.bold)),
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
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.outline),
                ),
                const Gap(24),
                const Text(
                  'No people added yet',
                  style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Gap(12),
                TextButton.icon(
                  onPressed: () {
                    (context.findAncestorStateOfType<_DebtScreenState>())?._showAddPersonDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add your first person'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          itemCount: persons.length,
          itemBuilder: (context, index) {
            final person = persons[index];
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
        return previous.debts != current.debts || previous.persons != current.persons;
      },
      builder: (context, state) {
        final balance = state.getPersonBalance(person.id);
        final color = balance > 0
            ? Colors.greenAccent[700]!
            : balance < 0
                ? Colors.redAccent
                : Colors.grey;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
            ),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Hero(
              tag: 'avatar_${person.id}',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  person.name[0].toUpperCase(),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            title: Text(
              person.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              balance == 0 ? 'No active debts' : (balance > 0 ? 'Receivable' : 'Payable'),
              style: TextStyle(
                fontSize: 12,
                color: balance == 0 ? Colors.grey : color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ETB ${balance.abs().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: balance == 0 ? Colors.grey : color,
                    letterSpacing: -0.5,
                  ),
                ),
                const Gap(2),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}

