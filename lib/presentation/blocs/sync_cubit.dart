import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/services/google_auth_service.dart';
import '../../data/services/google_drive_sync_service.dart';
import '../../data/services/local_backup_service.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus cloudStatus;
  final SyncStatus localStatus;
  final DateTime? lastSyncTime;
  final DateTime? lastLocalBackupTime;
  final String? errorMessage;
  final GoogleSignInAccount? user;

  const SyncState({
    this.cloudStatus = SyncStatus.idle,
    this.localStatus = SyncStatus.idle,
    this.lastSyncTime,
    this.lastLocalBackupTime,
    this.errorMessage,
    this.user,
  });

  SyncState copyWith({
    SyncStatus? cloudStatus,
    SyncStatus? localStatus,
    DateTime? lastSyncTime,
    DateTime? lastLocalBackupTime,
    String? errorMessage,
    GoogleSignInAccount? user,
    bool clearError = false,
  }) {
    return SyncState(
      cloudStatus: cloudStatus ?? this.cloudStatus,
      localStatus: localStatus ?? this.localStatus,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastLocalBackupTime: lastLocalBackupTime ?? this.lastLocalBackupTime,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
    );
  }

  bool get isSignedIn => user != null;
  bool get isSyncing =>
      cloudStatus == SyncStatus.syncing || localStatus == SyncStatus.syncing;
}

class SyncCubit extends Cubit<SyncState> {
  final GoogleAuthService _authService = GoogleAuthService();
  final GoogleDriveSyncService _syncService = GoogleDriveSyncService();
  final LocalBackupService _localBackupService = LocalBackupService();

  SyncCubit() : super(const SyncState()) {
    _init();
  }

  Future<void> _init() async {
    await _authService.init();
    final user = _authService.getCurrentUser();
    final lastSync = await _syncService.getLastSyncTime();
    final lastLocal = await _localBackupService.getLastBackupTime();

    emit(
      state.copyWith(
        user: user,
        lastSyncTime: lastSync,
        lastLocalBackupTime: lastLocal,
      ),
    );
  }

  /// Sign in with Google
  Future<void> signIn() async {
    try {
      emit(state.copyWith(cloudStatus: SyncStatus.syncing, clearError: true));

      final user = await _authService.signIn();

      if (user != null) {
        emit(state.copyWith(cloudStatus: SyncStatus.success, user: user));
      } else {
        emit(
          state.copyWith(
            cloudStatus: SyncStatus.error,
            errorMessage: 'Sign-in cancelled',
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('SYNC_CUBIT SIGNIN ERROR: $e');
      debugPrint(stack.toString());
      emit(
        state.copyWith(
          cloudStatus: SyncStatus.error,
          errorMessage: 'Sign-in error: $e',
        ),
      );
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      emit(
        state.copyWith(
          cloudStatus: SyncStatus.idle,
          user: null,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          cloudStatus: SyncStatus.error,
          errorMessage: 'Sign-out error: $e',
        ),
      );
    }
  }

  /// Manually trigger sync
  Future<void> syncNow() async {
    if (!state.isSignedIn) {
      emit(
        state.copyWith(
          cloudStatus: SyncStatus.error,
          errorMessage: 'Please sign in first',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(cloudStatus: SyncStatus.syncing, clearError: true));

      final success = await _syncService.syncData();

      if (success) {
        final lastSync = await _syncService.getLastSyncTime();
        emit(
          state.copyWith(
            cloudStatus: SyncStatus.success,
            lastSyncTime: lastSync,
          ),
        );
      } else {
        emit(
          state.copyWith(
            cloudStatus: SyncStatus.error,
            errorMessage: 'Sync failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          cloudStatus: SyncStatus.error,
          errorMessage: 'Sync error: $e',
        ),
      );
    }
  }

  /// Upload backup to Google Drive
  Future<void> uploadBackup() async {
    if (!state.isSignedIn) {
      emit(
        state.copyWith(
          cloudStatus: SyncStatus.error,
          errorMessage: 'Please sign in first',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(cloudStatus: SyncStatus.syncing, clearError: true));

      final success = await _syncService.uploadData();

      if (success) {
        final lastSync = await _syncService.getLastSyncTime();
        emit(
          state.copyWith(
            cloudStatus: SyncStatus.success,
            lastSyncTime: lastSync,
          ),
        );
      } else {
        emit(
          state.copyWith(
            cloudStatus: SyncStatus.error,
            errorMessage: 'Upload failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          cloudStatus: SyncStatus.error,
          errorMessage: 'Upload error: $e',
        ),
      );
    }
  }

  /// Restore backup from Google Drive
  Future<void> restoreBackup() async {
    if (!state.isSignedIn) {
      emit(
        state.copyWith(
          cloudStatus: SyncStatus.error,
          errorMessage: 'Please sign in first',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(cloudStatus: SyncStatus.syncing, clearError: true));

      final success = await _syncService.restoreFromCloud();

      if (success) {
        final lastSync = await _syncService.getLastSyncTime();
        emit(
          state.copyWith(
            cloudStatus: SyncStatus.success,
            lastSyncTime: lastSync,
          ),
        );
      } else {
        emit(
          state.copyWith(
            cloudStatus: SyncStatus.error,
            errorMessage: 'No backup found or restore failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          cloudStatus: SyncStatus.error,
          errorMessage: 'Restore error: $e',
        ),
      );
    }
  }

  /// Create Local Backup (Save As via FilePicker)
  Future<void> createLocalBackup() async {
    try {
      emit(state.copyWith(localStatus: SyncStatus.syncing, clearError: true));

      final tempPath = await _localBackupService.createBackupFile();

      if (tempPath != null) {
        // Read the bytes from the temp file
        final tempFile = File(tempPath);
        final bytes = await tempFile.readAsBytes();

        // Use FilePicker to save the file
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Select where to save the backup',
          fileName: 'expense_tracker_local_backup.json',
          bytes: bytes,
        );

        if (outputFile != null) {
          await _localBackupService.setLastBackupTime(DateTime.now());

          emit(
            state.copyWith(
              localStatus: SyncStatus.success,
              lastLocalBackupTime: DateTime.now(),
            ),
          );
        } else {
          // Cancelled
          emit(state.copyWith(localStatus: SyncStatus.idle));
        }
      } else {
        emit(
          state.copyWith(
            localStatus: SyncStatus.error,
            errorMessage: 'Failed to generate backup file',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          localStatus: SyncStatus.error,
          errorMessage: 'Local backup error: $e',
        ),
      );
    }
  }

  /// Restore Local Backup (via FilePicker)
  Future<void> restoreLocalBackup() async {
    try {
      emit(state.copyWith(localStatus: SyncStatus.syncing, clearError: true));

      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Or specify custom extension if possible
      );

      if (result != null && result.files.single.path != null) {
        final success = await _localBackupService.restoreBackupFromFile(
          result.files.single.path!,
        );

        if (success) {
          final lastLocal = await _localBackupService.getLastBackupTime();
          emit(
            state.copyWith(
              localStatus: SyncStatus.success,
              lastLocalBackupTime: lastLocal,
            ),
          );
        } else {
          emit(
            state.copyWith(
              localStatus: SyncStatus.error,
              errorMessage: 'Failed to restore from the selected file',
            ),
          );
        }
      } else {
        // Cancelled
        emit(state.copyWith(localStatus: SyncStatus.idle));
      }
    } catch (e) {
      emit(
        state.copyWith(
          localStatus: SyncStatus.error,
          errorMessage: 'Local restore error: $e',
        ),
      );
    }
  }

  /// Delete Local Backup
  Future<void> deleteLocalBackup() async {
    try {
      emit(state.copyWith(localStatus: SyncStatus.syncing, clearError: true));

      final success = await _localBackupService.deleteBackup();

      if (success) {
        emit(
          state.copyWith(
            localStatus: SyncStatus.success,
            lastLocalBackupTime: null, // clear the time
          ),
        );
      } else {
        emit(
          state.copyWith(
            localStatus: SyncStatus.error,
            errorMessage: 'Failed to delete local backup',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          localStatus: SyncStatus.error,
          errorMessage: 'Delete backup error: $e',
        ),
      );
    }
  }

  /// Reset status to idle
  void resetStatus() {
    emit(
      state.copyWith(
        cloudStatus: SyncStatus.idle,
        localStatus: SyncStatus.idle,
        clearError: true,
      ),
    );
  }
}
