import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../data/models/shortcut_model.dart';

class ShortcutSection extends StatelessWidget {
  final List<ShortcutModel> shortcuts;
  final ValueChanged<ShortcutModel> onShortcutApplied;
  final VoidCallback onAddShortcut;
  final bool isEditMode;

  const ShortcutSection({
    super.key,
    required this.shortcuts,
    required this.onShortcutApplied,
    required this.onAddShortcut,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditMode) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shortcuts.isNotEmpty) ...[
          const Text(
            'QUICK SHORTCUTS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const Gap(12),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                ...shortcuts.map((shortcut) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ActionChip(
                        label: Text(shortcut.title),
                        avatar: const Icon(Icons.bolt, size: 16),
                        onPressed: () => onShortcutApplied(shortcut),
                      ),
                    )),
                ActionChip(
                  label: const Text('New'),
                  avatar: const Icon(Icons.add_rounded, size: 16),
                  onPressed: onAddShortcut,
                ),
              ],
            ),
          ),
          const Gap(40),
        ] else ...[
          OutlinedButton.icon(
            onPressed: onAddShortcut,
            icon: const Icon(Icons.flash_on_rounded, size: 18),
            label: const Text('Add Quick Shortcut'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const Gap(40),
        ],
      ],
    );
  }
}
