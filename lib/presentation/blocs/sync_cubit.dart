import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/services/google_auth_service.dart';
import '../../data/services/google_drive_sync_service.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final GoogleSignInAccount? user;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncTime,
    this.errorMessage,
    this.user,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncTime,
    String? errorMessage,
    GoogleSignInAccount? user,
    bool clearError = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
    );
  }

  bool get isSignedIn => user != null;
}

class SyncCubit extends Cubit<SyncState> {
  final GoogleAuthService _authService = GoogleAuthService();
  final GoogleDriveSyncService _syncService = GoogleDriveSyncService();

  SyncCubit() : super(const SyncState()) {
    _init();
  }

  Future<void> _init() async {
    await _authService.init();
    final user = _authService.getCurrentUser();
    final lastSync = await _syncService.getLastSyncTime();

    emit(state.copyWith(user: user, lastSyncTime: lastSync));
  }

  /// Sign in with Google
  Future<void> signIn() async {
    try {
      emit(state.copyWith(status: SyncStatus.syncing, clearError: true));

      final user = await _authService.signIn();

      if (user != null) {
        emit(state.copyWith(status: SyncStatus.success, user: user));
      } else {
        emit(
          state.copyWith(
            status: SyncStatus.error,
            errorMessage: 'Sign-in cancelled or failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: SyncStatus.error,
          errorMessage: 'Sign-in error: $e',
        ),
      );
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      emit(const SyncState(status: SyncStatus.idle));
    } catch (e) {
      emit(
        state.copyWith(
          status: SyncStatus.error,
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
          status: SyncStatus.error,
          errorMessage: 'Please sign in first',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(status: SyncStatus.syncing, clearError: true));

      final success = await _syncService.syncData();

      if (success) {
        final lastSync = await _syncService.getLastSyncTime();
        emit(
          state.copyWith(status: SyncStatus.success, lastSyncTime: lastSync),
        );
      } else {
        emit(
          state.copyWith(status: SyncStatus.error, errorMessage: 'Sync failed'),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: SyncStatus.error,
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
          status: SyncStatus.error,
          errorMessage: 'Please sign in first',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(status: SyncStatus.syncing, clearError: true));

      final success = await _syncService.uploadData();

      if (success) {
        final lastSync = await _syncService.getLastSyncTime();
        emit(
          state.copyWith(status: SyncStatus.success, lastSyncTime: lastSync),
        );
      } else {
        emit(
          state.copyWith(
            status: SyncStatus.error,
            errorMessage: 'Upload failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: SyncStatus.error,
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
          status: SyncStatus.error,
          errorMessage: 'Please sign in first',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(status: SyncStatus.syncing, clearError: true));

      final success = await _syncService.restoreFromCloud();

      if (success) {
        final lastSync = await _syncService.getLastSyncTime();
        emit(
          state.copyWith(status: SyncStatus.success, lastSyncTime: lastSync),
        );
      } else {
        emit(
          state.copyWith(
            status: SyncStatus.error,
            errorMessage: 'No backup found or restore failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: SyncStatus.error,
          errorMessage: 'Restore error: $e',
        ),
      );
    }
  }

  /// Reset status to idle
  void resetStatus() {
    emit(state.copyWith(status: SyncStatus.idle, clearError: true));
  }
}
