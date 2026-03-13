import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/sync_cubit.dart';
import '../../blocs/expense_cubit.dart';
import '../../blocs/category_cubit.dart';
import '../../blocs/budget_cubit.dart';
import '../../blocs/debt_cubit.dart';
import '../../blocs/shopping_cubit.dart';
import '../../blocs/shortcut_cubit.dart';
import 'settings_widgets.dart';

class SyncSettingsGroup extends StatelessWidget {
  const SyncSettingsGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Backup & Sync',
      children: [
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
              return SettingsTile(
                icon: Icons.cloud_outlined,
                title: 'Sign in with Google',
                subtitle: 'Backup and sync your data',
                iconColor: Colors.blue,
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
                        context.read<SyncCubit>().signIn();
                      },
              );
            }

            return Column(
              children: [
                const ListTile(
                   title: Text('Google Drive Sync', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: syncState.user?.photoUrl != null
                        ? NetworkImage(syncState.user!.photoUrl!)
                        : null,
                    child: syncState.user?.photoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(syncState.user?.displayName ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(syncState.user?.email ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.logout, size: 20, color: Colors.redAccent),
                    onPressed: () => _showSignOutDialog(context),
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
                SettingsTile(
                  icon: Icons.sync,
                  title: 'Sync Now',
                  subtitle: 'Upload and sync your data',
                  iconColor: Colors.teal,
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
                const Divider(height: 1, indent: 56),
                SettingsTile(
                  icon: Icons.cloud_download,
                  title: 'Restore (Append)',
                  subtitle: 'Add missing records from cloud',
                  iconColor: Colors.orange,
                  onTap: syncState.status == SyncStatus.syncing
                      ? null
                      : () => _showRestoreDialog(context),
                ),
                const Divider(height: 1),
                const ListTile(
                   title: Text('Local Device Backup', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                ),
                if (syncState.lastLocalBackupTime != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 72, right: 16, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Last local backup: ${DateFormat('MMM d, y h:mm a').format(syncState.lastLocalBackupTime!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                SettingsTile(
                  icon: Icons.save_alt,
                  title: 'Create Local Backup',
                  subtitle: 'Save a backup file to your device',
                  iconColor: Colors.teal,
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
                          context.read<SyncCubit>().createLocalBackup();
                        },
                ),
                const Divider(height: 1, indent: 56),
                SettingsTile(
                  icon: Icons.settings_backup_restore,
                  title: 'Restore Local Backup',
                  subtitle: 'Restore from a local backup file',
                  iconColor: Colors.orange,
                  onTap: syncState.status == SyncStatus.syncing
                      ? null
                      : () => _showRestoreLocalDialog(context),
                ),
                 const Divider(height: 1, indent: 56),
                SettingsTile(
                  icon: Icons.delete_outline,
                  title: 'Delete Local Backup',
                  subtitle: 'Remove the local backup file',
                  iconColor: Colors.red,
                  onTap: syncState.status == SyncStatus.syncing
                      ? null
                      : () => _showDeleteLocalDialog(context),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) async {
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
  }

  void _showRestoreDialog(BuildContext context) async {
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
  }

  void _showRestoreLocalDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Local Backup?'),
        content: const Text(
          'This will add records from your local backup that are missing. Existing data will NOT be deleted.',
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
      context.read<SyncCubit>().restoreLocalBackup();
    }
  }

  void _showDeleteLocalDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Local Backup?'),
        content: const Text(
          'This will permanently delete the local backup file from your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<SyncCubit>().deleteLocalBackup();
    }
  }
}
