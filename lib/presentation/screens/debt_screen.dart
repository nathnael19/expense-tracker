import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../data/models/person_model.dart';
import '../blocs/debt_cubit.dart';
import '../components/debt/add_person_dialog.dart';
import '../components/debt/person_list_item.dart';

class DebtScreen extends StatelessWidget {
  const DebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Manager', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          const _DebtSummary(),
          const Expanded(child: _PersonList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (ctx) => const AddPersonDialog(),
        ),
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
                  onPressed: () => showDialog(
                    context: context,
                    builder: (ctx) => const AddPersonDialog(),
                  ),
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
            return PersonListItem(person: persons[index]);
          },
        );
      },
    );
  }
}

class _DebtSummary extends StatelessWidget {
  const _DebtSummary();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtCubit, DebtState>(
      builder: (context, state) {
        final totalLent = state.totalLent;
        final totalBorrowed = state.totalBorrowed;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    title: 'THEY OWE',
                    amount: totalLent,
                    color: Colors.green,
                    isPositive: true,
                  ),
                ),
                VerticalDivider(
                  color: Colors.grey.withOpacity(0.1),
                  thickness: 1,
                  indent: 4,
                  endIndent: 4,
                ),
                Expanded(
                  child: _SummaryItem(
                    title: 'I OWE',
                    amount: totalBorrowed,
                    color: Colors.red,
                    isPositive: false,
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

class _SummaryItem extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final bool isPositive;

  const _SummaryItem({
    required this.title,
    required this.amount,
    required this.color,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const Gap(4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
              size: 14,
              color: color,
            ),
            const Gap(6),
            Text(
              '${amount.toStringAsFixed(0)} ETB',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
