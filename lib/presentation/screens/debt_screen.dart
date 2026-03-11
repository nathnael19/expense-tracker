import 'package:expense_tracker_offline/data/models/debt_model.dart';
import 'package:expense_tracker_offline/data/models/person_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../blocs/debt_cubit.dart';
import 'add_debt_screen.dart';
import 'person_detail_screen.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'People'),
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _PersonList(),
          const _DebtList(isActive: true),
          const _DebtList(isActive: false),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, child) {
          final isPeopleTab = _tabController.index == 0;
          return FloatingActionButton.extended(
            onPressed: isPeopleTab
                ? _showAddPersonDialog
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddDebtScreen(),
                      ),
                    );
                  },
            label: Text(isPeopleTab ? 'Add Person' : 'Add Record'),
            icon: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

class _PersonList extends StatelessWidget {
  const _PersonList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtCubit, DebtState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final persons = state.persons;

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
                    // This is a bit hacky but it works for now
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
      },
    );
  }
}

class _DebtList extends StatelessWidget {
  final bool isActive;

  const _DebtList({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtCubit, DebtState>(
      builder: (context, state) {
        final list = isActive ? state.activeDebts : state.historyDebts;

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? Icons.money_off : Icons.history,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const Gap(16),
                Text(
                  isActive ? 'No active debts' : 'No history yet',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final debt = list[index];
            final isLent = debt.type == DebtType.lent;
            final color = isLent ? Colors.green : Colors.redAccent;
            final bgColor = color.withOpacity(0.1);

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: bgColor,
                  child: Icon(
                    isLent ? Icons.arrow_upward : Icons.arrow_downward,
                    color: color,
                    size: 20,
                  ),
                ),
                title: Text(
                  debt.personName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isLent ? 'Lent' : 'Borrowed'}: ${DateFormat.yMMMd().format(debt.date)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (debt.dueDate != null && isActive)
                      Text(
                        'Due: ${DateFormat.yMMMd().format(debt.dueDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: debt.dueDate!.isBefore(DateTime.now())
                              ? Colors.red
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
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
                    if (isActive)
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
                  // Show delete dialog
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
          },
        );
      },
    );
  }
}
