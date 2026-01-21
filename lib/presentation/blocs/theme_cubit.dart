import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_loadTheme()) {
    // Initial load is handled in super
  }

  static ThemeMode _loadTheme() {
    final themeStr = StorageService.settingsBox.get(
      'themeMode',
      defaultValue: 'system',
    );
    switch (themeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void toggleTheme(ThemeMode mode) async {
    emit(mode);
    await StorageService.settingsBox.put('themeMode', mode.name);
  }
}
