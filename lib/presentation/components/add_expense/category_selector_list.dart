import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../data/models/category_model.dart';
import '../../screens/category_management_screen.dart';

class CategorySelectorList extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  const CategorySelectorList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CATEGORY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const Gap(12),
        SizedBox(
          height: 54,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length + 1,
            separatorBuilder: (ctx, i) => const Gap(12),
            itemBuilder: (ctx, index) {
              if (index == categories.length) {
                return _CategoryChip(
                  label: 'Manage',
                  icon: Icons.settings_outlined,
                  isSelected: false,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const CategoryManagementScreen()),
                  ),
                  isSpecial: true,
                );
              }

              final cat = categories[index];
              return _CategoryChip(
                label: cat.name,
                iconCode: cat.iconCode,
                isSelected: cat.id == selectedCategoryId,
                onTap: () => onCategorySelected(cat.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final int? iconCode;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSpecial;

  const _CategoryChip({
    required this.label,
    this.iconCode,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest.withOpacity(isSelected ? 1 : 0.4),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ??
                  IconData(
                    iconCode!,
                    fontFamily: 'Lucide',
                    fontPackage: 'lucide_icons_flutter',
                  ),
              size: 20,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
