import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/storage_service.dart';
import '../../data/services/notification_service.dart';

class SettingsState {
  final bool isAppLockEnabled;
  final bool reminderEnabled;
  final TimeOfDay reminderTime;

  SettingsState({
    this.isAppLockEnabled = false,
    this.reminderEnabled = false,
    this.reminderTime = const TimeOfDay(hour: 20, minute: 0),
  });

  SettingsState copyWith({
    bool? isAppLockEnabled,
    bool? reminderEnabled,
    TimeOfDay? reminderTime,
  }) {
    return SettingsState(
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState()) {
    Future.microtask(() => _loadSettings());
  }

  void _loadSettings() {
    final isLocked = StorageService.settingsBox.get(
      'isAppLockEnabled',
      defaultValue: false,
    );
    final reminderEnabled = StorageService.settingsBox.get(
      'reminderEnabled',
      defaultValue: false,
    );
    final reminderHour = StorageService.settingsBox.get(
      'reminderHour',
      defaultValue: 20,
    );
    final reminderMinute = StorageService.settingsBox.get(
      'reminderMinute',
      defaultValue: 0,
    );

    emit(
      state.copyWith(
        isAppLockEnabled: isLocked,
        reminderEnabled: reminderEnabled,
        reminderTime: TimeOfDay(hour: reminderHour, minute: reminderMinute),
      ),
    );
  }

  Future<void> toggleAppLock(bool value) async {
    await StorageService.settingsBox.put('isAppLockEnabled', value);
    emit(state.copyWith(isAppLockEnabled: value));
  }

  Future<void> toggleReminder(bool value) async {
    if (value) {
      await NotificationService.requestPermissions();
    }
    await StorageService.settingsBox.put('reminderEnabled', value);
    emit(state.copyWith(reminderEnabled: value));
    _updateNotification();
  }

  Future<void> updateReminderTime(TimeOfDay time) async {
    await StorageService.settingsBox.put('reminderHour', time.hour);
    await StorageService.settingsBox.put('reminderMinute', time.minute);
    emit(state.copyWith(reminderTime: time));
    _updateNotification();
  }

  void _updateNotification() {
    if (state.reminderEnabled) {
      NotificationService.scheduleDailyReminder(
        id: 1,
        title: 'Expense Tracker',
        body: 'Did you forget to log any expenses today?',
        time: state.reminderTime,
      );
    } else {
      NotificationService.cancelAll();
    }
  }
}
