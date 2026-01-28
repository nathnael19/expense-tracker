import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/services/firestore_backup_service.dart';
import '../../data/local/storage_service.dart';

enum BackupStatus { idle, backing_up, success, error }

class BackupState {
  final BackupStatus status;
  final DateTime? lastBackupTime;
  final String? errorMessage;
  final String userId;

  const BackupState({
    this.status = BackupStatus.idle,
    this.lastBackupTime,
    this.errorMessage,
    required this.userId,
  });

  BackupState copyWith({
    BackupStatus? status,
    DateTime? lastBackupTime,
    String? errorMessage,
    String? userId,
    bool clearError = false,
  }) {
    return BackupState(
      status: status ?? this.status,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      userId: userId ?? this.userId,
    );
  }
}

class BackupCubit extends Cubit<BackupState> {
  final FirestoreBackupService _backupService = FirestoreBackupService();

  BackupCubit() : super(BackupState(userId: _getOrCreateUserId())) {
    _init();
  }

  Future<void> _init() async {
    final lastBackup = await _backupService.getLastBackupTime();
    emit(state.copyWith(lastBackupTime: lastBackup));
  }

  /// Upload backup to Firestore
  Future<void> uploadBackup() async {
    try {
      emit(state.copyWith(status: BackupStatus.backing_up, clearError: true));

      final success = await _backupService.uploadBackup(state.userId);

      if (success) {
        final lastBackup = await _backupService.getLastBackupTime();
        emit(
          state.copyWith(
            status: BackupStatus.success,
            lastBackupTime: lastBackup,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: BackupStatus.error,
            errorMessage: 'Backup failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: BackupStatus.error,
          errorMessage: 'Backup error: $e',
        ),
      );
    }
  }

  /// Restore backup from Firestore
  Future<void> restoreBackup() async {
    try {
      emit(state.copyWith(status: BackupStatus.backing_up, clearError: true));

      final success = await _backupService.restoreBackup(state.userId);

      if (success) {
        final lastBackup = await _backupService.getLastBackupTime();
        emit(
          state.copyWith(
            status: BackupStatus.success,
            lastBackupTime: lastBackup,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: BackupStatus.error,
            errorMessage: 'No backup found or restore failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: BackupStatus.error,
          errorMessage: 'Restore error: $e',
        ),
      );
    }
  }

  /// Reset status to idle
  void resetStatus() {
    emit(state.copyWith(status: BackupStatus.idle, clearError: true));
  }

  /// Get or create a unique user ID for this device
  static String _getOrCreateUserId() {
    const key = 'device_user_id';
    var userId = StorageService.settingsBox.get(key) as String?;

    if (userId == null) {
      userId = const Uuid().v4();
      StorageService.settingsBox.put(key, userId);
    }

    return userId;
  }
}
