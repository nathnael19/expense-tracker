import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/settings_cubit.dart';
import 'settings_widgets.dart';

class SecuritySettingsGroup extends StatelessWidget {
  final bool biometricsAvailable;

  const SecuritySettingsGroup({
    super.key,
    required this.biometricsAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;

    return SettingsSection(
      title: 'Security',
      children: [
        if (biometricsAvailable)
          SettingsTile(
            icon: Icons.fingerprint,
            title: 'App Lock',
            subtitle: 'Require authentication on launch',
            iconColor: Colors.redAccent,
            trailing: CupertinoSwitch(
              activeColor: Theme.of(context).colorScheme.primary,
              value: settingsState.isAppLockEnabled,
              onChanged: (val) {
                context.read<SettingsCubit>().toggleAppLock(val);
              },
            ),
          )
        else
          const SettingsTile(
            icon: Icons.lock_outline,
            title: 'App Lock Unavailable',
            subtitle: 'Biometrics not supported on this device',
            iconColor: Colors.grey,
            trailing: SizedBox.shrink(),
          ),
      ],
    );
  }
}
