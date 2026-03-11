// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'category_management_screen.dart';
import '../blocs/settings_cubit.dart';
import '../blocs/theme_cubit.dart';
import '../blocs/sync_cubit.dart';
import '../blocs/expense_cubit.dart';
import '../blocs/category_cubit.dart';
import '../blocs/budget_cubit.dart';
import '../blocs/debt_cubit.dart';
import '../blocs/shopping_cubit.dart';
import '../blocs/shortcut_cubit.dart';

import '../../data/services/security_service.dart';
import 'budget_screen.dart';
import 'recurring_transactions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await SecurityService.isBiometricAvailable();
    setState(() {
      _biometricsAvailable = available;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          // General Section
          _buildSectionHeader('General'),
          _buildSettingsGroup([
            _buildListTile(
              icon: Icons.category_outlined,
              title: 'Manage Categories',
              subtitle: 'Add, edit, or remove categories',
              iconColor: Colors.orangeAccent,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const CategoryManagementScreen()),
              ),
            ),
            const Divider(height: 1, indent: 56),
            _buildListTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Set Monthly Budget',
              subtitle: 'Define your monthly spending limit',
              iconColor: Colors.blueAccent,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const BudgetScreen()),
              ),
            ),
            const Divider(height: 1, indent: 56),
            _buildListTile(
              icon: Icons.repeat_rounded,
              title: 'Recurring Transactions',
              subtitle: 'Manage repeat expenses',
              iconColor: Colors.greenAccent[700]!,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const RecurringTransactionsScreen()),
              ),
            ),
          ]),

          const Gap(24),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildSettingsGroup([
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDark = themeMode == ThemeMode.dark;
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigoAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.indigoAccent),
                  ),
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Toggle application theme'),
                  trailing: CupertinoSwitch(
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: isDark,
                    onChanged: (val) {
                      context.read<ThemeCubit>().toggleTheme(
                        val ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                );
              },
            ),
          ]),

          const Gap(24),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSettingsGroup([
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_outlined, color: Colors.amber),
              ),
              title: const Text('Daily Reminders', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Get reminded to log your expenses'),
              trailing: CupertinoSwitch(
                activeColor: Theme.of(context).colorScheme.primary,
                value: settingsState.reminderEnabled,
                onChanged: (val) {
                  context.read<SettingsCubit>().toggleReminder(val);
                },
              ),
            ),
            if (settingsState.reminderEnabled) ...[
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.access_time, color: Colors.grey),
                ),
                title: const Text('Reminder Time', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(settingsState.reminderTime.format(context)),
                trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: settingsState.reminderTime,
                  );
                  if (picked != null) {
                    context.read<SettingsCubit>().updateReminderTime(picked);
                  }
                },
              ),
            ],
          ]),

          const Gap(24),

          // Security Section
          _buildSectionHeader('Security'),
          _buildSettingsGroup([
            if (_biometricsAvailable)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fingerprint, color: Colors.redAccent),
                ),
                title: const Text('App Lock', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Require authentication on launch'),
                trailing: CupertinoSwitch(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: settingsState.isAppLockEnabled,
                  onChanged: (val) {
                    context.read<SettingsCubit>().toggleAppLock(val);
                  },
                ),
              )
            else
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: Colors.grey),
                ),
                title: const Text('App Lock Unavailable', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Biometrics not supported on this device'),
              ),
          ]),

          const Gap(24),

          // Cloud Sync Section
          _buildSectionHeader('Cloud Sync'),
          _buildSettingsGroup([
            BlocConsumer<SyncCubit, SyncState>(
              listener: (context, syncState) {
                if (syncState.status == SyncStatus.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sync successful!')),
                  );

                  // Reload data in all cubits to reflect restored data
                  context.read<ExpenseCubit>().loadExpenses();
                  context.read<CategoryCubit>().loadCategories();
                  context.read<BudgetCubit>().loadBudgets();
                  context.read<DebtCubit>().loadDebts();
                  context.read<ShoppingCubit>().loadShoppingLists();
                  context.read<ShortcutCubit>().loadShortcuts();

                  context.read<SyncCubit>().resetStatus();
                } else if (syncState.status == SyncStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(syncState.errorMessage ?? 'Sync failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  context.read<SyncCubit>().resetStatus();
                }
              },
              builder: (context, syncState) {
                if (!syncState.isSignedIn) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_outlined, color: Colors.blue),
                    ),
                    title: const Text('Sign in with Google', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Backup and sync your data'),
                    trailing: syncState.status == SyncStatus.syncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: syncState.status == SyncStatus.syncing
                        ? null
                        : () {
                            context.read<SyncCubit>().signIn();
                          },
                  );
                }

                // User is signed in
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: syncState.user?.photoUrl != null
                            ? NetworkImage(syncState.user!.photoUrl!)
                            : null,
                        child: syncState.user?.photoUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(syncState.user?.displayName ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(syncState.user?.email ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.logout, size: 20, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Sign Out?'),
                              content: const Text(
                                'You will no longer sync data to Google Drive.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            context.read<SyncCubit>().signOut();
                          }
                        },
                      ),
                    ),
                    if (syncState.lastSyncTime != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 72, right: 16, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Last synced: ${DateFormat('MMM d, y h:mm a').format(syncState.lastSyncTime!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sync, color: Colors.teal),
                      ),
                      title: const Text('Sync Now', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Upload and sync your data'),
                      trailing: syncState.status == SyncStatus.syncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: syncState.status == SyncStatus.syncing
                          ? null
                          : () {
                              context.read<SyncCubit>().syncNow();
                            },
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_download, color: Colors.orange),
                      ),
                      title: const Text('Restore (Append)', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Add missing records from cloud'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: syncState.status == SyncStatus.syncing
                          ? null
                          : () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Restore & Append?'),
                                  content: const Text(
                                    'This will add records from your cloud backup that are missing locally. Existing local data will NOT be deleted.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Restore',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && context.mounted) {
                                context.read<SyncCubit>().restoreBackup();
                              }
                            },
                    ),
                  ],
                );
              },
            ),
          ]),

          const Gap(40),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
