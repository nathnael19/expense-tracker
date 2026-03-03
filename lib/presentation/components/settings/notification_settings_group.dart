import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/settings_cubit.dart';
import 'settings_widgets.dart';

class NotificationSettingsGroup extends StatelessWidget {
  const NotificationSettingsGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;

    return SettingsSection(
      title: 'Notifications',
      children: [
        SettingsTile(
          icon: Icons.notifications_active_outlined,
          title: 'Daily Reminders',
          subtitle: 'Get reminded to log your expenses',
          iconColor: Colors.amber,
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
          SettingsTile(
            icon: Icons.access_time,
            title: 'Reminder Time',
            subtitle: settingsState.reminderTime.format(context),
            iconColor: Colors.grey,
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
      ],
    );
  }
}
