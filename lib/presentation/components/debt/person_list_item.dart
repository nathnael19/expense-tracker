import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../data/models/person_model.dart';
import '../../blocs/debt_cubit.dart';
import '../../screens/person_detail_screen.dart';

class PersonListItem extends StatelessWidget {
  final PersonModel person;

  const PersonListItem({super.key, required this.person});

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
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            title: Text(
              person.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              balance == 0
                  ? 'No active debts'
                  : (balance > 0 ? 'Receivable' : 'Payable'),
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
