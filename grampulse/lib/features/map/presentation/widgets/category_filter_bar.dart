import 'package:flutter/material.dart';
import 'package:grampulse/core/constants/spacing.dart';
import 'package:grampulse/features/map/domain/models/category_model.dart';
import 'package:grampulse/l10n/app_localizations.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;
  
  const CategoryFilterBar({
    Key? key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Spacing.md),
        children: [
          // All category chip
          Padding(
            padding: EdgeInsets.only(right: Spacing.xs),
            child: FilterChip(
              label: Text(context.l10n.all),
              selected: selectedCategoryId == null || selectedCategoryId == 'all',
              onSelected: (_) => onCategorySelected('all'),
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: selectedCategoryId == null || selectedCategoryId == 'all'
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // Category chips
          ...categories.map((category) {
            return Padding(
              padding: EdgeInsets.only(right: Spacing.xs),
              child: FilterChip(
                label: Text(category.name),
                selected: category.id == selectedCategoryId,
                onSelected: (_) => onCategorySelected(category.id),
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedColor: category.color.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: category.id == selectedCategoryId
                      ? category.color
                      : Theme.of(context).colorScheme.onSurface,
                ),
                avatar: Icon(
                  IconData(
                    int.parse(category.iconCode),
                    fontFamily: 'MaterialIcons',
                  ),
                  size: 16,
                  color: category.id == selectedCategoryId
                      ? category.color
                      : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
