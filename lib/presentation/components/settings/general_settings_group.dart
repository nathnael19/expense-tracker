import 'package:flutter/material.dart';
import 'settings_widgets.dart';
import '../../screens/category_management_screen.dart';
import '../../screens/budget_screen.dart';
import '../../screens/recurring_transactions_screen.dart';

class GeneralSettingsGroup extends StatelessWidget {
  const GeneralSettingsGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'General',
      children: [
        SettingsTile(
          icon: Icons.category_outlined,
          title: 'Manage Categories',
          subtitle: 'Add, edit, or remove categories',
          iconColor: Colors.orangeAccent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const CategoryManagementScreen()),
          ),
        ),
        const Divider(height: 1, indent: 56),
        SettingsTile(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Set Monthly Budget',
          subtitle: 'Define your monthly spending limit',
          iconColor: Colors.blueAccent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const BudgetScreen()),
          ),
        ),
        const Divider(height: 1, indent: 56),
        SettingsTile(
          icon: Icons.repeat_rounded,
          title: 'Recurring Transactions',
          subtitle: 'Manage repeat expenses',
          iconColor: Colors.greenAccent[700]!,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const RecurringTransactionsScreen()),
          ),
        ),
      ],
    );
  }
}
