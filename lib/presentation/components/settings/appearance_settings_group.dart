import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/theme_cubit.dart';
import 'settings_widgets.dart';

class AppearanceSettingsGroup extends StatelessWidget {
  const AppearanceSettingsGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Appearance',
      children: [
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final isDark = themeMode == ThemeMode.dark;
            return SettingsTile(
              icon: isDark ? Icons.dark_mode : Icons.light_mode,
              title: 'Dark Mode',
              subtitle: 'Toggle application theme',
              iconColor: Colors.indigoAccent,
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
      ],
    );
  }
}
