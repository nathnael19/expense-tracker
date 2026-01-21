import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../blocs/budget_cubit.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentBudget = context.read<BudgetCubit>().state.monthlyBudget;
    if (currentBudget != null) {
      _amountController.text = currentBudget.amount.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    context.read<BudgetCubit>().setMonthlyBudget(amount);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Monthly Budget')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'How much do you want to spend this month?',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Gap(24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: 'ETB ',
                border: InputBorder.none,
                hintText: '0',
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveBudget,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Budget',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
