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
      body: const _PersonList(),
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
