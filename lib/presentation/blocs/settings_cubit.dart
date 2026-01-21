import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/storage_service.dart';

class SettingsState {
  final bool isAppLockEnabled;

  SettingsState({this.isAppLockEnabled = false});

  SettingsState copyWith({bool? isAppLockEnabled}) {
    return SettingsState(
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final isLocked = StorageService.settingsBox.get(
      'isAppLockEnabled',
      defaultValue: false,
    );
    emit(state.copyWith(isAppLockEnabled: isLocked));
  }

  Future<void> toggleAppLock(bool value) async {
    await StorageService.settingsBox.put('isAppLockEnabled', value);
    emit(state.copyWith(isAppLockEnabled: value));
  }
}
