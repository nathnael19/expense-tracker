import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/storage_service.dart';
import '../../data/models/shortcut_model.dart';

class ShortcutCubit extends Cubit<List<ShortcutModel>> {
  ShortcutCubit() : super([]) {
    _loadShortcuts();
  }

  void _loadShortcuts() {
    try {
      if (StorageService.shortcutBox.isOpen) {
        emit(StorageService.shortcutBox.values.toList());
      }
    } catch (e) {
      emit([]);
    }
  }

  Future<void> addShortcut(ShortcutModel shortcut) async {
    await StorageService.shortcutBox.put(shortcut.id, shortcut);
    emit([...state, shortcut]);
  }

  Future<void> deleteShortcut(String id) async {
    await StorageService.shortcutBox.delete(id);
    emit(state.where((s) => s.id != id).toList());
  }
}
