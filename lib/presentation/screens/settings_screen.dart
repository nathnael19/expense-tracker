// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'category_management_screen.dart';
import '../blocs/settings_cubit.dart';
import '../blocs/theme_cubit.dart';
import '../blocs/sync_cubit.dart';
import '../../data/services/backup_service.dart';
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
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        children: [
          const Gap(16),
          // General Section
          _buildSectionHeader('General'),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Manage Categories'),
            subtitle: const Text('Add, edit, or remove categories'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const CategoryManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Set Monthly Budget'),
            subtitle: const Text('Define your monthly spending limit'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => const BudgetScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Recurring Transactions'),
            subtitle: const Text('Manage repeat expenses'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const RecurringTransactionsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark;
              return SwitchListTile(
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle application theme'),
                value: isDark,
                onChanged: (val) {
                  context.read<ThemeCubit>().toggleTheme(
                    val ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              );
            },
          ),
          const Divider(),

          const Divider(),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Daily Reminders'),
            subtitle: const Text('Get reminded to log your expenses'),
            value: settingsState.reminderEnabled,
            onChanged: (val) {
              context.read<SettingsCubit>().toggleReminder(val);
            },
          ),
          if (settingsState.reminderEnabled)
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Reminder Time'),
              subtitle: Text(settingsState.reminderTime.format(context)),
              trailing: const Icon(Icons.edit, size: 16),
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

          const Divider(),

          // Security Section
          _buildSectionHeader('Security'),
          if (_biometricsAvailable)
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('App Lock'),
              subtitle: const Text('Require authentication on launch'),
              value: settingsState.isAppLockEnabled,
              onChanged: (val) {
                context.read<SettingsCubit>().toggleAppLock(val);
              },
            )
          else
            const ListTile(
              leading: Icon(Icons.lock_outline, color: Colors.grey),
              title: Text('App Lock Unavailable'),
              subtitle: Text('Biometrics not supported on this device'),
            ),

          const Divider(),

          // Cloud Sync Section
          _buildSectionHeader('Cloud Sync'),
          BlocConsumer<SyncCubit, SyncState>(
            listener: (context, syncState) {
              if (syncState.status == SyncStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync successful!')),
                );
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
                  leading: const Icon(Icons.cloud_outlined),
                  title: const Text('Sign in with Google'),
                  subtitle: const Text('Backup and sync your data'),
                  trailing: syncState.status == SyncStatus.syncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
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
                    title: Text(syncState.user?.displayName ?? 'User'),
                    subtitle: Text(syncState.user?.email ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.logout, size: 20),
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
                                child: const Text('Sign Out'),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Last synced: ${DateFormat('MMM d, y h:mm a').format(syncState.lastSyncTime!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  const Gap(8),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('Sync Now'),
                    subtitle: const Text('Upload and sync your data'),
                    trailing: syncState.status == SyncStatus.syncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    onTap: syncState.status == SyncStatus.syncing
                        ? null
                        : () {
                            context.read<SyncCubit>().syncNow();
                          },
                  ),
                  ListTile(
                    leading: const Icon(Icons.cloud_download),
                    title: const Text('Restore from Cloud'),
                    subtitle: const Text('Download and restore backup'),
                    onTap: syncState.status == SyncStatus.syncing
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Restore from Cloud?'),
                                content: const Text(
                                  'This will OVERWRITE all current data with your cloud backup. Are you sure?',
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

          const Divider(),

          // Data Section
          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Backup Data'),
            subtitle: const Text('Export your data to a file'),
            onTap: () async {
              await BackupService.exportData();
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Restore Data'),
            subtitle: const Text('Import data from a backup file'),
            onTap: () async {
              // Confirm Dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Restore Backup?'),
                  content: const Text(
                    'This will OVERWRITE all current data. Are you sure?',
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
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final success = await BackupService.restoreData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Data restored successfully'
                            : 'Restore failed or cancelled',
                      ),
                    ),
                  );
                  // Force refresh of stats/home might be needed if providers don't auto-watch hive box perfectly or if references are stale.
                  // Providers watching `expenseListProvider` which re-reads box values on change usually work if we notify them.
                  // But straightforward approach is restart or just hope Riverpod auto-disposal works.
                  // For now, let's assume Riverpod + Hive box listenable works or we trigger a refresh.
                }
              }
            },
          ),

          const Gap(40),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
